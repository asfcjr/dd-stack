resource "aws_vpc" "this" {
  cidr_block = var.vpc_resources.cidr_block

  tags = { Name = var.vpc_resources.name }
}