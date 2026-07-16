output "vpc_id" {
  value = aws_vpc.this.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}

output "observability_subnet_ids" {
  description = "IDs of the observability subnets"
  value       = aws_subnet.observability[*].id
}

output "observability_subnet_cidrs" {
  description = "CIDR blocks of the observability subnets"
  value       = aws_subnet.observability[*].cidr_block
}
