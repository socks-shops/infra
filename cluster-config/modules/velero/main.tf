# Connecte to the cluster the Velero CRDs local-exec
resource "null_resource" "update_kubeconfig" {
  provisioner "local-exec" {
    command = "aws eks --region ${var.region} update-kubeconfig --name ${var.cluster_name}"
  }
}

# Install les CRDs de Velero
resource "null_resource" "velero_crds" {
  provisioner "local-exec" {
    command = "velero install --crds-only --dry-run -o yaml | kubectl apply -f -"
  }

  depends_on = [null_resource.update_kubeconfig]
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
      velero_role_arn           = var.velero_role_arn
    })
  ]

  force_update = true

  depends_on = [null_resource.velero_crds]
}
