variable "cluster_name" {
  description = "sockshop-eks"
}

variable "account_id" {
  description = "AWS Account ID"
}

variable "oidc_provider" {
  type        = string
  description = "ARN de l'OIDC provider EKS"
}
