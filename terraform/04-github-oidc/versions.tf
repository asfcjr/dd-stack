terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "s3" {
    bucket         = "tfstate-749698443047"
    key            = "challenge/github-oidc/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "state-locking-749698443047"
  }
}
