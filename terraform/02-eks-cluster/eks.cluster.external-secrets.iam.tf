resource "aws_iam_role" "external_secrets" {
  name = "challenge-external-secrets"

  assume_role_policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = "sts:AssumeRoleWithWebIdentity"
      Principal = {
        Federated = aws_iam_openid_connect_provider.kubernetes.arn
      }
      Condition = {
        StringEquals = {
          "${local.eks_oidc_url}:aud" = "sts.amazonaws.com"
          "${local.eks_oidc_url}:sub" = "system:serviceaccount:external-secrets:external-secrets"
        }
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_policy" "external_secrets" {
  name        = "AllowExternalSecretsRead"
  description = "IAM policy for External Secrets Operator to read challenge/* secrets"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"],
        Resource = ["arn:aws:secretsmanager:us-east-1:${data.aws_caller_identity.current.account_id}:secret:challenge/*"],
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "external_secrets" {
  policy_arn = aws_iam_policy.external_secrets.arn
  role       = aws_iam_role.external_secrets.name
}
