resource "aws_eks_access_entry" "user" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = local.user_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "user" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = local.user_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}