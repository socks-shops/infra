terraform {
  backend "s3" {
    bucket = "sockshop-tfstate-1234"
    key    = "cluster-config/sockshop.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

data "terraform_remote_state" "infrastructure" {
  backend = "s3"
  config = {
    bucket = "sockshop-tfstate-1234"
    key    = "infrastructure/sockshop.tfstate"
    region = "us-east-1"
  }
}

# Create a resource to obtain an authentication token for the EKS cluster
data "aws_eks_cluster_auth" "auth" {
  name = data.terraform_remote_state.infrastructure.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.cluster_ca)
  token                  = data.terraform_remote_state.infrastructure.outputs.cluster_token
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.cluster_ca)
    token                  = data.terraform_remote_state.infrastructure.outputs.cluster_token
  }
}



################### NAMESPACE ###################
#################################################

module "namespaces" {
  source = "./modules/namespaces"
}



########### AWS LB CONTROLLER + SA ##############
#################################################

module "aws_lb_controller_dev" {
  source       = "./modules/aws-lb-controller"
  namespace    = "dev"
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  role_arn     = data.terraform_remote_state.infrastructure.outputs.aws_lb_controller_role_arn
}

module "aws_lb_controller_staging" {
  source       = "./modules/aws-lb-controller"
  namespace    = "staging"
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  role_arn     = data.terraform_remote_state.infrastructure.outputs.aws_lb_controller_role_arn
}

module "aws_lb_controller_prod" {
  source       = "./modules/aws-lb-controller"
  namespace    = "prod"
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  role_arn     = data.terraform_remote_state.infrastructure.outputs.aws_lb_controller_role_arn
}



#################### VELERO #####################
#################################################

module "velero" {
  source                    = "./modules/velero"
  velero_backup_bucket_name = var.velero_backup_bucket_name
  region                    = data.terraform_remote_state.infrastructure.outputs.region
  veloro_role_arn           = data.terraform_remote_state.infrastructure.outputs.velero_role_arn
}


################### OPERATORS ###################
#################################################

module "mongodb_operator" {
  source                            = "./modules/mongodb-operator"
  percona_mongodb_operator_role_arn = data.terraform_remote_state.infrastructure.outputs.percona_mongodb_operator_role_arn
}

module "mysql_operator" {
  source                          = "./modules/mysql-operator"
  percona_mysql_operator_role_arn = data.terraform_remote_state.infrastructure.outputs.percona_mysql_operator_role_arn
}

module "redis_operator" {
  source                  = "./modules/redis-operator"
  redis_operator_role_arn = data.terraform_remote_state.infrastructure.outputs.redis_operator_role_arn
}
