variable "namespace" {
  type        = string
  description = "Nom du namespace Kubernetes (dev, staging, prod, etc.)"
}

variable "role_arn" {
  type        = string
  description = "ARN du rôle IAM utilisé par aws-load-balancer-controller"
}

variable "cluster_name" {
  type = string
}
