########### SERVICE ACCOUNT CREATION ############
#################################################

# Create "mongodb" Service Account
resource "kubernetes_service_account" "percona-mongodb" {
  metadata {
    name      = "mongodb"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.percona_mongodb_operator_role_arn
    }
  }
}



############### OPERATOR CREATION ###############
#################################################

# Percona operator
resource "helm_release" "percona_operator" {
  name             = "mongodb-operator"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-operator"
  version    = var.psmdb-version

  values = [file("${path.module}/helm/operator-values.yaml")]
}



############## DB CLUSTER CREATION ##############
#################################################

# Carts MongoDB cluster
resource "helm_release" "carts_db" {
  name      = "carts-db"
  namespace = var.namespace

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-db"
  version    = var.psmdb-version

  values     = [file("${path.module}/helm/carts-db-values.yaml")]
  depends_on = [helm_release.percona_operator]
}

# Orders MongoDB cluster
resource "helm_release" "orders_db" {
  name      = "orders-db"
  namespace = var.namespace

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-db"
  version    = var.psmdb-version

  values     = [file("${path.module}/helm/orders-db-values.yaml")]
  depends_on = [helm_release.percona_operator]
}

# User MongoDB cluster
resource "helm_release" "user_db" {
  name      = "user-db"
  namespace = var.namespace

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-db"
  version    = var.psmdb-version

  values     = [file("${path.module}/helm/user-db-values.yaml")]
  depends_on = [helm_release.percona_operator]
}
