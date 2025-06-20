variable "vpc_id" {
  description = "The ID of the VPC where the security groups will be created."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block of the VPC (for ingress rules)."
  type        = string
}

variable "cidr_all" {
  description = "CIDR block for all outbound traffic (egress)."
  type        = string
  default     = "0.0.0.0/0"
}

variable "eks_cluster_security_group_id" {
  description = "The security group ID of the EKS cluster control plane."
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}
