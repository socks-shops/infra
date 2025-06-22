output "ebs_csi_driver_role_arn" {
  description = "ARN of the IAM role for the AWS EBS CSI Driver"
  value       = aws_iam_role.ebs_csi_driver.arn
}
