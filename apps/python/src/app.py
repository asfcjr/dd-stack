"""
Symbol Prices API - a small but realistic market-data service used to showcase
end-to-end Datadog observability (APM traces + a service map, structured logs
correlated to traces, and custom business metrics).

Each request fans out into simulated dependencies (Postgres, Redis, an upstream
market-data API) via manual ddtrace spans, so the APM flame graph and service
map look like a real distributed system rather than a single Flask process.
"""
import logging
import os
import random
import time
from contextlib import contextmanager

from flask import Flask, jsonify, request, abort
import json_log_formatter

# --- ddtrace tracer -------------------------------------------------------
# Provided by the Datadog admission-controller library injection at runtime and
# pinned in requirements. Imported defensively so the app still serves if the
# tracer is ever unavailable (manual spans simply become no-ops).
try:
    from ddtrace import tracer
    _HAS_TRACE = True
except Exception:  # pragma: no cover
    _HAS_TRACE = False

# --- custom business metrics over the Datadog DogStatsD socket ------------
try:
    from datadog.dogstatsd import DogStatsd

    _dsd_url = os.environ.get("DD_DOGSTATSD_URL", "")
    if _dsd_url.startswith("unix://"):
        statsd = DogStatsd(socket_path=_dsd_url[len("unix://"):], namespace="prices_api")
    else:
        statsd = DogStatsd(namespace="prices_api")
    _HAS_STATSD = True
except Exception:  # pragma: no cover
    _HAS_STATSD = False


app = Flask("python-flask")

# Silence Flask's default access logger; we emit structured JSON ourselves.
logging.getLogger("werkzeug").disabled = True


class TraceContextFilter(logging.Filter):
    """Inject dd.trace_id / dd.span_id into every record so Datadog can pivot
    from a trace straight to its logs. Uses ddtrace's official correlation
    helper, which formats the ids the way the Datadog log pipeline expects."""

    def filter(self, record):
        if _HAS_TRACE:
            ctx = tracer.get_log_correlation_context()
            for key in ("trace_id", "span_id", "service", "env", "version"):
                setattr(record, "dd.{}".format(key), ctx.get(key, ""))
        return True


log = logging.getLogger("python-flask")
log.setLevel(logging.INFO)
_handler = logging.StreamHandler()
_handler.setFormatter(json_log_formatter.VerboseJSONFormatter())
log.addHandler(_handler)
log.addFilter(TraceContextFilter())
log.propagate = False


@contextmanager
def span(name, service, resource=None, span_type=None):
    """Create a child span for a simulated dependency call."""
    if _HAS_TRACE:
        with tracer.trace(name, service=service, resource=resource or name, span_type=span_type):
            yield
    else:
        yield


def _sleep_ms(base_ms, jitter_ms):
    time.sleep((base_ms + random.uniform(0, jitter_ms)) / 1000.0)


def db_query(resource, base_ms, jitter_ms):
    with span("postgres.query", "prices-postgres", resource, "sql"):
        # occasional tail latency, like a real DB under contention
        if random.random() < 0.04:
            _sleep_ms(base_ms * 4, jitter_ms * 3)
        else:
            _sleep_ms(base_ms, jitter_ms)


def cache_get(key, base_ms=2, jitter_ms=5):
    with span("redis.command", "prices-cache", "GET {}".format(key), "redis"):
        _sleep_ms(base_ms, jitter_ms)


def market_data_call(resource, base_ms, jitter_ms):
    with span("http.request", "market-data-api", resource, "http"):
        _sleep_ms(base_ms, jitter_ms)


SYMBOLS = ["AAPL", "MSFT", "GOOG", "AMZN", "TSLA", "NVDA", "META", "NFLX"]


@app.route("/")
def root():
    return "Flask: Hello World"


@app.route("/health")
def health():
    return jsonify(status="ok")


@app.route("/api/symbols")
def list_symbols():
    cache_get("symbols:all")
    log.info("listed symbols", extra={"endpoint": "symbols", "count": len(SYMBOLS)})
    return jsonify(symbols=SYMBOLS)


@app.route("/api/prices/last-price")
def last_price():
    symbol = request.args.get("symbol", random.choice(SYMBOLS))
    cache_get("price:{}".format(symbol))
    db_query("SELECT price FROM ticks WHERE symbol=%s ORDER BY ts DESC LIMIT 1", 8, 22)
    if random.random() < 0.01:
        log.warning("symbol not found", extra={"endpoint": "last-price", "symbol": symbol})
        abort(404)
    price = round(random.uniform(50, 500), 2)
    log.info("served last price", extra={"endpoint": "last-price", "symbol": symbol, "price": price})
    return jsonify(symbol=symbol, price=price)


@app.route("/api/aggregated-prices")
def aggregated_prices():
    with span("aggregate.compute", "python-flask", "aggregate-prices"):
        for sym in random.sample(SYMBOLS, 4):
            db_query(
                "SELECT avg(price) FROM ticks WHERE symbol='{}' AND ts > now()-interval '1h'".format(sym),
                14, 42,
            )
        if random.random() < 0.03:
            log.error("aggregation query timed out", extra={"endpoint": "aggregated-prices"})
            abort(500)
    log.info("computed aggregated prices", extra={"endpoint": "aggregated-prices", "window": "1h"})
    return jsonify(window="1h", symbols=len(SYMBOLS))


@app.route("/api/candles")
def candles():
    symbol = request.args.get("symbol", random.choice(SYMBOLS))
    market_data_call("GET /v1/candles?symbol={}".format(symbol), 25, 130)
    db_query("INSERT INTO candle_cache (symbol, payload) VALUES (%s, %s)", 10, 28)
    if random.random() < 0.02:
        log.error("market-data upstream unavailable", extra={"endpoint": "candles", "symbol": symbol})
        abort(503)
    log.info("served candles", extra={"endpoint": "candles", "symbol": symbol})
    return jsonify(symbol=symbol, interval="1m", points=60)


@app.route("/api/orders", methods=["POST"])
def place_order():
    symbol = random.choice(SYMBOLS)
    qty = random.randint(1, 100)
    # input validation failure
    if random.random() < 0.08:
        log.warning("order validation failed", extra={"endpoint": "orders", "symbol": symbol, "reason": "invalid_quantity"})
        abort(400)
    db_query("INSERT INTO orders (symbol, qty, ts) VALUES (%s, %s, now())", 12, 26)
    # downstream persistence failure
    if random.random() < 0.02:
        log.error("order persistence failed", extra={"endpoint": "orders", "symbol": symbol})
        abort(500)
    value = round(qty * random.uniform(50, 500), 2)
    if _HAS_STATSD:
        statsd.increment("orders.placed", tags=["symbol:{}".format(symbol)])
        statsd.histogram("orders.value_usd", value, tags=["symbol:{}".format(symbol)])
    log.info("order placed", extra={"endpoint": "orders", "symbol": symbol, "qty": qty, "value_usd": value})
    return jsonify(symbol=symbol, qty=qty, value_usd=value), 201


if __name__ == "__main__":
    app.run(host="0.0.0.0", threaded=True)
