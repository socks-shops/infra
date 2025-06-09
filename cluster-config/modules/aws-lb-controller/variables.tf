variable "role_arn" {
  type        = string
  description = "ARN du rôle IAM utilisé par aws-load-balancer-controller"
}

variable "cluster_name" {
  type = string
}
