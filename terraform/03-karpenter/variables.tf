variable "region" {
  type        = string
  description = "The region to deploy the S3 bucket"
  default     = "us-east-1"
}

variable "karpenter" {
  type = object({
    controller_role_name   = string
    controller_policy_name = string
  })
  default = {
    controller_role_name   = "KarpenterControllerRole"
    controller_policy_name = "KarpenterControllerPolicy"
  }
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the S3 bucket"
  default = {
    ManagedBy = "Terraform"
    Project   = "challenge"
  }
}
