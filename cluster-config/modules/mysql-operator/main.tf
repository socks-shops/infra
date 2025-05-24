# Create the "mysql" Service Account
resource "kubernetes_service_account" "percona-mysql" {
  metadata {
    name      = "mysql"
    namespace = "mysql"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.percona_mysql_operator_role_arn
    }
  }
}

# Install MySQL Operator
resource "helm_release" "percona-mysql" {
  name       = "percona-mysql"
  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "pxc-operator"
  version    = "1.17.0"

  namespace = "mysql"
}

# Create catalogue MySQL cluster
resource "helm_release" "catalogue_db" {
  name      = "catalogue-db"
  namespace = "mysql"

  repository = "https://percona.github.io/percona-helm-charts/"
  chart      = "pxc-db"
  version    = "1.17.0" # Même version que l'operator, recommandé

  values     = [file("${path.module}/helm/catalogue-db-values.yaml")]
  depends_on = [helm_release.percona-mysql]
}
