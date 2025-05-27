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

# Le bloc ci-dessous permet de générer un **jeton d'authentification temporaire** (valide ~15 minutes)
# pour accéder au cluster EKS via l'API Kubernetes.
# Le provider "kubernetes" l'utilise pour s'authentifier lors des opérations Terraform (apply/destroy).
# Ce jeton est généré dynamiquement grâce à la ressource `aws_eks_cluster_auth`.
#
# ⚠️ Attention : comme ce token expire rapidement, un `terraform apply` ou `destroy` trop long
# peut échouer avec des erreurs "Unauthorized" si le token devient invalide en cours d'exécution.
# Dans ce cas, relancer la commande après régénération automatique du token suffit généralement.

data "aws_eks_cluster_auth" "auth" {
  name = data.terraform_remote_state.infrastructure.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.cluster_ca)
  token                  = data.aws_eks_cluster_auth.auth.token
}

provider "helm" {
  kubernetes {
    host                   = data.terraform_remote_state.infrastructure.outputs.cluster_endpoint
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infrastructure.outputs.cluster_ca)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}



################### NAMESPACE ###################
#################################################

module "namespaces" {
  source = "./modules/namespaces"
}



########### AWS LB CONTROLLER + SA ##############
#################################################

module "aws_lb_controller" {
  source       = "./modules/aws-lb-controller"
  namespace    = "kube-system"
  cluster_name = data.terraform_remote_state.infrastructure.outputs.cluster_name
  role_arn     = data.terraform_remote_state.infrastructure.outputs.aws_lb_controller_role_arn
}


################ EBS CSI DRIVER #################
#################################################

module "aws_ebs_csi_driver" {
  source = "./modules/aws-ebs-csi-driver"
}


#################### VELERO #####################
#################################################

module "velero" {
  source                    = "./modules/velero"
  velero_backup_bucket_name = data.terraform_remote_state.infrastructure.outputs.velero_backup_bucket_name
  region                    = data.terraform_remote_state.infrastructure.outputs.region
  veloro_role_arn           = data.terraform_remote_state.infrastructure.outputs.velero_role_arn

  depends_on = [module.namespaces]
}


################### OPERATORS ###################
#################################################

module "mongodb_operator" {
  source = "./modules/mongodb-operator"
  env    = var.env

  depends_on = [module.namespaces]
}

# module "mysql_operator" {
#   source                          = "./modules/mysql-operator"
#   env = var.env
#   percona_mysql_operator_role_arn = data.terraform_remote_state.infrastructure.outputs.percona_mysql_operator_role_arn

#   depends_on = [module.namespaces]
# }

# module "redis_operator" {
#   source                  = "./modules/redis-operator"
#   env                     = var.env
#   redis_operator_role_arn = data.terraform_remote_state.infrastructure.outputs.redis_operator_role_arn

#   depends_on = [module.namespaces]
# }
