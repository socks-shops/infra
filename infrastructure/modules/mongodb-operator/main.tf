# IAM role for the mongodb operator Service Account
locals {
  oidc_provider_short = split("oidc-provider/", var.oidc_provider)[1]
}

resource "aws_iam_role" "mongodb_operator_role" {
  name = "${var.cluster_name}-mongodb-operator-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${local.oidc_provider_short}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringLike": {
            "${local.oidc_provider_short}:sub": [
              "system:serviceaccount:dev:mongodb-operator-sa",
              "system:serviceaccount:staging:mongodb-operator-sa",
              "system:serviceaccount:prod:mongodb-operator-sa"
            ]
          }
        }
      }
    ]
  })
}

# Create policies
resource "aws_iam_policy" "mongodb_operator_policy" {
  name        = "${var.cluster_name}-mongodb-operator-policy"
  description = "IAM policy for mongodb-operator backups on EKS"
  policy = templatefile("${path.module}/aws_mongodb_operator_policy.json.tpl", {
    account_id = var.account_id
    mongodb_backup_bucket_name = var.mongodb_backup_bucket_name
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "mongodb_operator_policy_attachment" {
  policy_arn = aws_iam_policy.mongodb_operator_policy.arn
  role       = aws_iam_role.mongodb_operator_role.name
}
