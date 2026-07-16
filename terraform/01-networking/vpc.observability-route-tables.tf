resource "aws_route_table_association" "observability" {
  count = length(aws_subnet.observability)

  subnet_id = aws_subnet.observability[count.index].id
  route_table_id = var.vpc_resources.observability_subnets[count.index].map_public_ip_on_launch ? aws_route_table.public.id : (
    var.vpc_resources.observability_subnets[count.index].availability_zone == "us-east-1a" ? aws_route_table.private_1a.id : aws_route_table.private_1b.id
  )

  depends_on = [aws_subnet.observability]
}
