# IAM role for the Velero service account
resource "aws_iam_role" "velero" {
  name = "${var.cluster_name}-velero-role"
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
            "${replace(var.oidc_provider, "https://", "")}:sub" : "system:serviceaccount:velero:velero"
          }
        }
      }
    ]
  })
}

# Policies for the role
resource "aws_iam_policy" "velero" {
  name        = "${var.cluster_name}-velero-policy"
  description = "IAM policy for Velero backups on EKS"
  # Charge la politique depuis le fichier JSON externe
  policy = jsonencode(jsondecode(replace(
    file("${path.module}/aws_velero_policy.json"),
    "__KMS_KEY_ARN__",
    var.kms_key_arn
  )))
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "velero" {
  policy_arn = aws_iam_policy.velero.arn
  role       = aws_iam_role.velero.name
}
