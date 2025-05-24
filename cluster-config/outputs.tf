output "cluster_token" {
  value     = data.aws_eks_cluster_auth.auth.token
  sensitive = true
}

# output "cluster_auth" {
#   value = module.eks.cluster_certificate_authority_data
# }
