variable "region" {
  type        = string
  description = "The region to deploy"
  default     = "us-east-1"
}

variable "vpc_resources" {
  type = object({
    name                      = string
    cidr_block                = string
    internet_gateway          = string
    public_route_table_name   = string
    private_route_table_1a    = string
    private_route_table_1b    = string
    enable_nat_gateway        = bool
    nat_gateway_1a            = string
    nat_gateway_1b            = string
    elastic_ip_nat_gateway_1a = string
    elastic_ip_nat_gateway_1b = string
    eks_cluster_name_tag      = string

    public_subnets = list(object({
      name                    = string,
      cidr_block              = string,
      availability_zone       = string,
      map_public_ip_on_launch = bool,
    }))

    private_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    }))

    observability_subnets = list(object({
      name                    = string
      cidr_block              = string
      availability_zone       = string
      map_public_ip_on_launch = bool
    }))
  })

  default = {
    name                      = "challenge-vpc"
    cidr_block                = "10.0.0.0/20"
    internet_gateway          = "igw"
    public_route_table_name   = "public-rt"
    private_route_table_1a    = "private-rt-1a"
    private_route_table_1b    = "private-rt-1b"
    enable_nat_gateway        = false
    nat_gateway_1a            = "nat-1a"
    nat_gateway_1b            = "nat-1b"
    elastic_ip_nat_gateway_1a = "eip-nat-1a"
    elastic_ip_nat_gateway_1b = "eip-nat-1b"
    eks_cluster_name_tag      = "challenge-cluster"

    public_subnets = [
      {
        name                    = "public-1a"
        availability_zone       = "us-east-1a"
        cidr_block              = "10.0.0.0/24"
        map_public_ip_on_launch = true
      },
      {
        name                    = "public-1b"
        availability_zone       = "us-east-1b"
        cidr_block              = "10.0.1.0/24"
        map_public_ip_on_launch = true
      }
    ]

    private_subnets = [
      {
        name                    = "private-1a"
        availability_zone       = "us-east-1a"
        cidr_block              = "10.0.2.0/24"
        map_public_ip_on_launch = false,
      },
      {
        name                    = "private-1b"
        availability_zone       = "us-east-1b"
        cidr_block              = "10.0.3.0/24"
        map_public_ip_on_launch = false,
      }
    ]

    observability_subnets = [
      {
        name                    = "observability-public-1a"
        availability_zone       = "us-east-1a"
        cidr_block              = "10.0.4.0/24"
        map_public_ip_on_launch = true
      },
      {
        name                    = "observability-public-1b"
        availability_zone       = "us-east-1b"
        cidr_block              = "10.0.5.0/24"
        map_public_ip_on_launch = true
      }
    ]
  }
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply"
  default = {
    ManagedBy = "Terraform"
    Project   = "challenge"
  }
}
