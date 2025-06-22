terraform {
  backend "s3" {
    bucket = "sockshop-tfstate-1234"
    key    = "infrastructure/sockshop.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}

# Define local variables including key name and path
locals {
  key_name = "sockshop-keypair"                # Nom de la clé SSH à créer
  key_path = "./keypair/${local.key_name}.pem" # Chemin pour sauvegarder la clé privée
}

module "network" {
  source               = "./modules/network"
  cluster_name         = var.cluster_name
  network_name         = "sock-shop-network"
  vpc_cidr             = var.vpc_cidr
  az1_pub_subnet_cidr  = "10.0.1.0/24" #var.subnet_cidr
  az2_pub_subnet_cidr  = "10.0.2.0/24" #var.subnet_cidr
  az1_priv_subnet_cidr = "10.0.3.0/24" #var.subnet_cidr
  az2_priv_subnet_cidr = "10.0.4.0/24" #var.subnet_cidr
  cidr_all             = var.cidr_all
  public_az1           = var.availability_zone_1
  public_az2           = var.availability_zone_2
  private_az1          = var.availability_zone_1
  private_az2          = var.availability_zone_2
}

module "eks" {
  source                        = "./modules/eks"
  subnet_ids                    = module.network.private_subnet_ids
  cluster_name                  = var.cluster_name
  eks_node_group_name           = "node_group_sockshop"
  iam_role_name                 = "iam_role_sockshop"
  eks_key_pair                  = local.key_name
  vpc_id                        = module.network.vpc_id
  vpc_cidr                      = var.vpc_cidr
  cidr_all                      = var.cidr_all
  eks_desired_worker_node       = var.desired_worker_node
  eks_min_worker_node           = var.min_worker_node
  eks_max_worker_node           = var.max_worker_node
  eks_worker_node_instance_type = var.worker_node_instance_type
  eks_worker_node_capacity_type = var.worker_node_capacity_type
  eks_version                   = var.eks_version
  aws_region                    = var.region
  account_id                    = var.aws_account_id
  eks_sg                        = module.securitygroup.eks_sg_id
}

module "securitygroup" {
  source   = "./modules/securitygroup"
  cluster_name = var.cluster_name
  vpc_id   = module.network.vpc_id
  vpc_cidr = var.vpc_cidr
  cidr_all = var.cidr_all
  eks_cluster_security_group_id = module.eks.eks_cluster_security_group_id
}

module "aws-ebs-csi-driver" {
  source = "./modules/aws-ebs-csi-driver"
  cluster_name = var.cluster_name
  account_id = var.aws_account_id
  oidc_provider = module.eks.oidc_provider_arn
}

module "velero" {
  source                    = "./modules/velero"
  cluster_name              = module.eks.cluster_name
  account_id                = var.aws_account_id
  oidc_provider             = module.eks.oidc_provider_arn
  velero_backup_bucket_name = var.velero_backup_bucket_name
  region                    = var.region
  depends_on                = [module.eks]
}

module "keypair" {
  source          = "./modules/keypair"
  ds_key_filename = local.key_path
  eks_key_pair    = local.key_name # Passe la variable correcte pour la clé SSH
}
