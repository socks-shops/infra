# Percona operator
resource "helm_release" "percona_operator" {
  name             = "mongodb-operator"
  namespace        = var.namespace
  create_namespace = true

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-operator"
  version    = var.version

  values = [file("${path.module}/helm/percona/operator-values.yaml")]
}

# Carts MongoDB cluster
resource "helm_release" "carts_db" {
  name      = "carts-db"
  namespace = var.namespace

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-db"
  version    = var.version

  values = [file("${path.module}/helm/percona/carts-db-values.yaml")]
  depends_on = [helm_release.percona_operator]
}

# Orders MongoDB cluster
resource "helm_release" "orders_db" {
  name      = "orders-db"
  namespace = var.namespace

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-db"
  version    = var.version

  values = [file("${path.module}/helm/percona/orders-db-values.yaml")]
  depends_on = [helm_release.percona_operator]
}

# User MongoDB cluster
resource "helm_release" "user_db" {
  name      = "user-db"
  namespace = var.namespace

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "psmdb-db"
  version    = var.version

  values = [file("${path.module}/helm/percona/user-db-values.yaml")]
  depends_on = [helm_release.percona_operator]
}
