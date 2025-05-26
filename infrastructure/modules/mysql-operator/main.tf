# IAM role for the mysql operator Service Account
resource "aws_iam_role" "percona_mysql_role" {
  name = "${var.cluster_name}-percona-mysql-role"
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
            "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:percona-mysql:percona-mysql"
          }
        }
      }
    ]
  })
}

# Create policies
resource "aws_iam_policy" "percona_mysql_policy" {
  name        = "${var.cluster_name}-percona-mysql-policy"
  description = "IAM policy for percona-mysql backups on EKS"
  policy = templatefile("${path.module}/aws_percona_mysql_policy.json.tpl", {
    account_id = var.account_id
  })
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "percona_mysql" {
  policy_arn = aws_iam_policy.percona_mysql_policy.arn
  role       = aws_iam_role.percona_mysql_role.name
}
