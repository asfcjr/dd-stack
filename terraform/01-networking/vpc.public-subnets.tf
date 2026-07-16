resource "aws_subnet" "publics" {
  count = length(var.vpc_resources.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.vpc_resources.public_subnets[count.index].cidr_block
  availability_zone       = var.vpc_resources.public_subnets[count.index].availability_zone
  map_public_ip_on_launch = var.vpc_resources.public_subnets[count.index].map_public_ip_on_launch

  tags = {
    Name                     = "${var.vpc_resources.name}-${var.vpc_resources.public_subnets[count.index].name}"
    "kubernetes.io/role/elb" = "1"
    "karpenter.sh/discovery" = var.vpc_resources.eks_cluster_name_tag
    "eks-cluster"            = "true"
  }
}
