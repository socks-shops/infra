variable "velero_backup_bucket_name" {
  type = string
}

variable "region" {
  description = "Région AWS"
  type        = string
}

variable "veloro_role_arn" {
  description = "ARN du rôle IAM utilisé par Velero via IRSA"
  type        = string
}
