########### SERVICE ACCOUNT CREATION ############
#################################################

# Bitnami génère automatiquement un service account pour l'operator.
# Il ne faut en créer un qu'a partir du moment ou on veut utiliser un bucket S3 pour stocker des backups

# # Create "mongodb" Service Account
# resource "kubernetes_service_account" "percona-mongodb" {
#   metadata {
#     name      = "mongodb"
#     namespace = var.namespace
#     annotations = {
#       "eks.amazonaws.com/role-arn" = var.percona_mongodb_operator_role_arn
#     }
#   }
# }



############### OPERATOR CREATION ###############
#################################################

resource "helm_release" "carts_db" {
  name             = "carts-db"
  namespace        = var.env
  create_namespace = false

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "16.0.0"

  values = [file("${path.module}/helm/carts-db-values.yaml")]
}

resource "helm_release" "orders_db" {
  name             = "orders-db"
  namespace        = var.env
  create_namespace = false

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "16.0.0"

  values = [file("${path.module}/helm/orders-db-values.yaml")]
}

resource "helm_release" "user_db" {
  name             = "user-db"
  namespace        = var.env
  create_namespace = false

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mongodb"
  version    = "16.0.0"

  values = [file("${path.module}/helm/user-db-values.yaml")]
}
