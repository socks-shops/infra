# Create the "redis" Service Account
resource "kubernetes_service_account" "redis-operator" {
  metadata {
    name      = "redis"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.redis_operator_role_arn
    }
  }
}

# Install Redis Operator
resource "helm_release" "redis_operator" {
  name       = "redis-operator"
  repository = "https://ot-container-kit.github.io/helm-charts/"
  chart      = "redis-operator"
  version    = var.redis-operator-version

  namespace = var.namespace
}

# Create session Redis cluster
resource "helm_release" "session_db" {
  name      = "session-db"
  namespace = var.namespace

  repository = "https://ot-container-kit.github.io/helm-charts/"
  chart      = "redis"
  version    = var.redis-version # différent de celui de l'operator !

  values     = [file("${path.module}/helm/session-db-values.yaml")]
  depends_on = [helm_release.redis_operator]
}
