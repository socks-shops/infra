# IAM role for the redis operator Service Account
resource "aws_iam_role" "redis_operator_role" {
  name = "${var.cluster_name}-redis-operator-role"
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
            "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:redis-operator:redis-operator"
          }
        }
      }
    ]
  })
}

# Create policies
resource "aws_iam_policy" "redis_operator_policy" {
  name        = "${var.cluster_name}-redis-operator-policy"
  description = "IAM policy for redis-operator"
  policy = jsonencode(jsondecode(replace(
    file("${path.module}/aws_redis_operator_policy.json"),
    "__KMS_KEY_ARN__",
    var.kms_key_arn
  )))
}

# Attach policies to roles
resource "aws_iam_role_policy_attachment" "redis_operator" {
  policy_arn = aws_iam_policy.redis_operator_policy.arn
  role       = aws_iam_role.redis_operator_role.name
}
