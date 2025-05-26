variable "namespace" {
  type    = string
  default = "redis"
}

variable "redis-operator-version" {
  type    = string
  default = "0.14.0"
}

variable "redis-cluster-version" {
  type    = string
  default = "0.14.3"
}

variable "redis_operator_role_arn" {
  description = "ARN du rôle IAM utilisé par redis operator via IRSA"
  type        = string
}

variable "env" {
  type = string
}
