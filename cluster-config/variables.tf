#################################################
############## BUCKETS VARIABLES ################
#################################################

variable "mongodb_backup_bucket_name" {
  default = "sockshop-mongo-backups-bucket"
}

variable "mysql_backup_bucket_name" {
  default = "sockshop-mysql-backups-bucket"
}

variable "velero_backup_bucket_name" {
  default = "sockshop-velero-backups-bucket"
}
