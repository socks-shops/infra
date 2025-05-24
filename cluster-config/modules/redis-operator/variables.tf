variable "namespace" {
  type    = string
  default = "redis"
}

variable "redis-operator-version" {
  type    = string
  default = "0.20.0"
}

variable "redis-version" {
  type    = string
  default = "7.0.12"
}

variable "redis_operator_role_arn" {
  description = "ARN du rôle IAM utilisé par redis operator via IRSA"
  type        = string
}
