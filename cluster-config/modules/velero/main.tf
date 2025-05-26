# Create Service Account Velero
resource "kubernetes_service_account" "velero" {
  metadata {
    name      = "velero"
    namespace = "velero"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.veloro_role_arn
    }
  }
}

# Install Velero
resource "helm_release" "velero" {
  name       = "velero"
  repository = "https://vmware-tanzu.github.io/helm-charts"
  chart      = "velero"
  version    = "10.0.0"
  namespace  = "velero"

  values = [
    templatefile("${path.module}/helm/velero-values.yaml.tmpl", {
      velero_backup_bucket_name = var.velero_backup_bucket_name
      region                    = var.region
    })
  ]

  force_update = true
}
