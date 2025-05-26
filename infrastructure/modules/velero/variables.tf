variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
}

variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "oidc_provider" {
  type        = string
  description = "ARN de l'OIDC provider EKS"
}

variable "velero_backup_bucket_name" {
  type = string
}

variable "region" {
  description = "Région AWS"
  type        = string
}
