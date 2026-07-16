data "terraform_remote_state" "cluster_stack" {
  backend = "s3"

  config = {
    bucket         = "tfstate-749698443047"
    key            = "challenge/eks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "state-locking-749698443047"
  }
}
