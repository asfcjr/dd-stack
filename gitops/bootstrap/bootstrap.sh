#!/usr/bin/env bash
set -euo pipefail

CHART_VERSION="${ARGOCD_CHART_VERSION:-7.7.5}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_APP="${SCRIPT_DIR}/../root-app.yaml"

echo ">> [1/3] Instalando ArgoCD (chart ${CHART_VERSION})"
helm repo add argo https://argoproj.github.io/argo-helm >/dev/null
helm repo update argo >/dev/null
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --version "${CHART_VERSION}" \
  --set configs.params."server\.insecure"=true \
  --wait

echo ">> [2/3] Aplicando o app-of-apps (root-app)"
kubectl apply -f "${ROOT_APP}"

echo ">> [3/3] Senha inicial do admin"
echo -n "admin / "
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d; echo

cat <<'EOF'

Pronto. Acesse a UI:
  kubectl -n argocd port-forward svc/argocd-server 8080:443
  https://localhost:8080  (user: admin)

Acompanhe os apps sincronizando:
  kubectl -n argocd get applications
EOF
