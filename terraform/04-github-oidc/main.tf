provider "aws" {
  region = var.region
  default_tags { tags = { Project = "challenge", ManagedBy = "Terraform" } }
}

variable "region" {
  type    = string
  default = "us-east-1"
}
variable "github_repo" {
  description = "OWNER/REPO do repositorio no GitHub"
  type        = string
  default     = "asfcjr/dd-stack"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

resource "aws_iam_role" "gha_ecr" {
  name = "challenge-gha-ecr"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = aws_iam_openid_connect_provider.github.arn }
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = { "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com" }
        # GitHub emits immutable-ID subjects (repo:owner@ownerId/repo@repoId:...) for this account,
        # so match with wildcards instead of the plain owner/repo form.
        StringLike = { "token.actions.githubusercontent.com:sub" = "repo:${split("/", var.github_repo)[0]}@*/${split("/", var.github_repo)[1]}@*:*" }
      }
    }]
  })
}

resource "aws_iam_role_policy" "gha_ecr" {
  name = "ecr-push"
  role = aws_iam_role.gha_ecr.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Effect = "Allow", Action = "ecr:GetAuthorizationToken", Resource = "*" },
      { Effect = "Allow",
        Action = ["ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage", "ecr:PutImage", "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart", "ecr:CompleteLayerUpload", "ecr:CreateRepository", "ecr:DescribeRepositories"],
      Resource = "*" }
    ]
  })
}

output "gha_role_arn" {
  description = "Use no secret AWS_ROLE_ARN do repo"
  value       = aws_iam_role.gha_ecr.arn
}
