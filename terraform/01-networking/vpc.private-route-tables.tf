resource "aws_route_table" "private_1a" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.vpc_resources.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.us_east_1a[0].id
    }
  }

  tags       = merge({ Name = "${var.vpc_resources.name}-${var.vpc_resources.private_route_table_1a}" }, var.tags)
  depends_on = [aws_vpc.this]
}

resource "aws_route_table_association" "private_associations_1a" {
  subnet_id      = local.private_subnet_1a_id
  route_table_id = aws_route_table.private_1a.id

  depends_on = [aws_route_table.private_1a]
}


resource "aws_route_table" "private_1b" {
  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = var.vpc_resources.enable_nat_gateway ? [1] : []

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.us_east_1b[0].id
    }
  }

  tags       = merge({ Name = "${var.vpc_resources.name}-${var.vpc_resources.private_route_table_1b}" }, var.tags)
  depends_on = [aws_vpc.this]
}

resource "aws_route_table_association" "private_associations_1b" {
  subnet_id      = local.private_subnet_1b_id
  route_table_id = aws_route_table.private_1b.id

  depends_on = [aws_route_table.private_1b]
}
