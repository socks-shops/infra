variable "namespace" {
  type    = string
  default = "mysql"
}

variable "psmdb-version" {
  type    = string
  default = "1.20.0"
}

variable "percona_mysql_operator_role_arn" {
  description = "ARN du rôle IAM utilisé par mongodb operator via IRSA"
  type        = string
}
