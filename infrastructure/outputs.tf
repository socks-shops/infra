output "region" {
  description = "The AWS region"
  value       = var.region
}


################## EKS CLUSTER ##################
#################################################

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_ca" {
  value = module.eks.cluster_auth
}

output "cluster_token" {
  value     = module.eks.cluster_token
  sensitive = true
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "aws_lb_controller_role_arn" {
  value       = module.eks.aws_lb_controller_role_arn
  description = "ARN du rôle IAM pour le AWS Load Balancer Controller"
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "OIDC" {
  value = module.eks.oidc_provider_arn
}


#################### VELERO #####################
#################################################

output "velero_role_arn" {
  value = module.velero.velero_role_arn
}


################# DB OPERATORS ##################
#################################################

output "percona_mongodb_operator_role_arn" {
  value = module.mongodb_operator.percona_mongodb_role_arn
}

output "percona_mysql_operator_role_arn" {
  value = module.mysql_operator.percona_mysql_role_arn
}

output "redis_operator_role_arn" {
  value = module.redis_operator.redis_operator_role_arn
}



################### BUCKETS #####################
#################################################

output "velero_backup_bucket_name" {
  value = var.velero_backup_bucket_name
}
