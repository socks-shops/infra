variable "account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "operators_role_arns" {
  description = "Liste des ARNs des rôles IAM qui peuvent utiliser la clé KMS"
  type        = list(string)
}
