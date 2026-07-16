variable "region" {
  type        = string
  description = "The region to deploy"
  default     = "us-east-1"
}

variable "eks_cluster" {
  type = object({
    name                      = string
    role_name                 = string
    version                   = string
    enabled_cluster_log_types = list(string)
    access_config = object({
      authentication_mode = string
    })
    node_group = object({
      name           = string
      role_name      = string
      instance_types = list(string)
      capacity_type  = string
      ami_type       = string
      scaling_config = object({
        desired_size = number
        max_size     = number
        min_size     = number
      })
    })
  })
  default = {
    name                      = "challenge-cluster"
    role_name                 = "challenge-cluster-role"
    version                   = "1.33"
    enabled_cluster_log_types = ["audit", "api", "authenticator", "controllerManager", "scheduler"]
    access_config = {
      authentication_mode = "API_AND_CONFIG_MAP"
    }
    node_group = {
      name           = "challenge-node-group"
      role_name      = "challenge-node-group-role"
      instance_types = ["t3.medium"]
      capacity_type  = "SPOT"
      ami_type       = "AL2023_x86_64_STANDARD"
      scaling_config = {
        desired_size = 3
        max_size     = 3
        min_size     = 1
      }
    }
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

variable "custom_domain" {
  type    = string
  default = "asfcjr.click"
}
