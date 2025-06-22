locals {
  oidc_provider_short = split("oidc-provider/", var.oidc_provider)[1]
}

resource "aws_iam_role" "ebs_csi_driver" {
  name = "${var.cluster_name}-ebs-csi-driver-role"

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
          "StringEquals" = {
            "${local.oidc_provider_short}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ebs_csi_driver_custom_policy" {
  name        = "${var.cluster_name}-ebs-csi-driver-policy"
  description = "IAM policy for EBS CSI Driver on EKS"
  policy      = templatefile("${path.module}/json/aws_ebs_csi_driver_policy.json.tpl", {
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
  policy_arn = aws_iam_policy.ebs_csi_driver_custom_policy.arn
  role       = aws_iam_role.ebs_csi_driver.name
}

# data "aws_iam_policy" "ebs_csi_driver_managed_policy" {
#   name = "AmazonEBSCSIDriverPolicy"
# }

# resource "aws_iam_role_policy_attachment" "ebs_csi_driver" {
#   policy_arn = data.aws_iam_policy.ebs_csi_driver_managed_policy.arn
#   role       = aws_iam_role.ebs_csi_driver.name
# }
