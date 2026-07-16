terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.8.0"
    }
  }
  backend "s3" {
    bucket         = "tfstate-749698443047"
    key            = "challenge/eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "state-locking-749698443047"
  }
}
