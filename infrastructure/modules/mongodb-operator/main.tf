# IAM role for the mongodb operator Service Account
resource "aws_iam_role" "percona_mongodb_role" {
  name = "${var.cluster_name}-percona-mongodb-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${var.account_id}:oidc-provider/${replace(var.oidc_provider, "https://", "")}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:percona-mongodb:percona-mongodb"
          }
        }
      }
    ]
  })
}

# Create policies
resource "aws_iam_policy" "percona_mongodb_policy" {
  name        = "${var.cluster_name}-percona-mongodb-policy"
  description = "IAM policy for percona-mongodb backups on EKS"
  policy = jsonencode(jsondecode(replace(
    file("${path.module}/aws_percona_mongodb_policy.json"),
    "__KMS_KEY_ARN__",
    var.kms_key_arn
  )))
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "percona_mongodb" {
  policy_arn = aws_iam_policy.percona_mongodb_policy.arn
  role       = aws_iam_role.percona_mongodb_role.name
}
