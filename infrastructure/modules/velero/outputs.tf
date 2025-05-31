output "velero_role_arn" {
  value = aws_iam_role.velero.arn
}

output "sanitized_oidc" {
  value = replace(var.oidc_provider, "https://", "")
}

output "velero_assume_role_policy" {
  value = aws_iam_role.velero.assume_role_policy
}
