output "eks_sg_id" {
  description = "The ID of the EKS security group"
  value       = aws_security_group.eks_sg.id
}
