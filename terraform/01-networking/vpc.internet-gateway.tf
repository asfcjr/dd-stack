resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags       = merge({ Name = "${var.vpc_resources.name}-${var.vpc_resources.internet_gateway}" }, var.tags)
  depends_on = [aws_vpc.this]
}
