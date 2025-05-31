########### SERVICE ACCOUNT CREATION ############
#################################################

# Bitnami génère automatiquement un service account pour l'operator.
# Il ne faut en créer un qu'a partir du moment ou on veut utiliser un bucket S3 pour stocker des backups

# # Create "mongodb" Service Account
# resource "kubernetes_service_account" "mongodb-operator-sa" {
#   metadata {
#     name      = "mongodb-operator-sa"
#     namespace = var.namespace
#     annotations = {
#       "eks.amazonaws.com/role-arn" = var.mongodb_operator_role_arn
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


############### RESTORE DATA IN DB ##############
#################################################

resource "kubernetes_job" "restore_user_db" {
  metadata {
    name      = "restore-user-db"
    namespace = var.env
  }

  spec {
    template {
      metadata {
        name = "restore-user-db"
      }

      spec {
        restart_policy = "OnFailure"

        container {
          name  = "mongorestore"
          image = "socksshop/user-db-restore:latest"

          # Attends que MongoDB soit prêt
          command = ["/bin/sh", "-c"]
          args = [
            <<-EOT
            until nc -z user-db 27017; do echo "Waiting for MongoDB..."; sleep 2; done;
            mongorestore --host user-db --port 27017 --dir /dump --drop
            EOT
          ]
        }
      }
    }
  }

  depends_on = [helm_release.user_db]
}
