data "aws_subnets" "privates" {
  filter {
    name   = "tag:eks-cluster"
    values = ["true"]
  }

  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }

  filter {
    name   = "tag:Project"
    values = ["challenge"]
  }
}
