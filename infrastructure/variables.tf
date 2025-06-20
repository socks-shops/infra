
variable "region" {
  description = "AWS Region"
  default     = "us-east-1"
}

variable "aws_account_id" {
  default = "472454369658"
}

variable "iam_role_name" {
  default = "iam_role_sockshop"
}



#################################################
################# EKS VARIABLES #################
#################################################

variable "cluster_name" {
  description = "Nom du cluster EKS"
  default     = "sockshop-eks"
}


#################################################
################# VPC VARIABLES #################
#################################################

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "worker_node_instance_type" {
  # default = ["m6a.2xlarge", "m5.2xlarge"] # for original microservices resources values ( 1 node )
  default = ["t3.large", "t3a.large"] # for optimised microservices resources values ( 2 nodes )
}

variable "worker_node_capacity_type" {
  description = "values: ON_DEMAND, SPOT"
  default     = "SPOT"
}

variable "eks_version" {
  default = "1.32"
}

variable "eks_key_pair" {
  description = "Nom de la clé SSH"
  default     = "sockshop-keypair" # Le nom de la clé SSH
}

variable "backup_time_window" {
  default = "07:00-09:00"
}

variable "desired_worker_node" {
  default = 2
}

variable "max_worker_node" {
  default = 5
}

variable "min_worker_node" {
  default = 2
}

variable "subnet_cidr" {
  default = "10.0.0.0/24"
}

variable "cidr_all" {
  default = "0.0.0.0/0"
}

variable "availability_zone_1" {
  default = "us-east-1a"
}

variable "availability_zone_2" {
  default = "us-east-1b"
}


#################################################
################# ALB VARIABLES #################
#################################################

variable "alb_name" {
  description = "Nom du Load Balancer"
  default     = "socks-shop-lb"
}


variable "certificate_arn" {
  description = "ARN du certificat SSL pour HTTPS"
  type        = string
  default     = "arn:aws:acm:us-east-1:471744311643:certificate/a230a5d9-f1c9-4e21-b87e-4ad4ec11901e"
}


#################################################
############## ROUTE 53 VARIABLES ###############
#################################################

variable "domain_name" {
  description = "Nom de domaine"
  default     = "datascientets-socks-shop.com"
}

variable "subdomain_name" {
  description = "Sous-domaine à créer"
  type        = string
  default     = "www.datascientets-socks-shop.com"
}



#################################################
############## BUCKETS VARIABLES ################
#################################################

variable "mongodb_backup_bucket_name" {
  default = "sockshop-mongo-backups-bucket-1234"
}

variable "mysql_backup_bucket_name" {
  default = "sockshop-mysql-backups-bucket-1234"
}

variable "velero_backup_bucket_name" {
  default = "sockshop-velero-backups-bucket-1234"
}
