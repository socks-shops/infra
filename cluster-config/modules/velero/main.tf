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

  set {
    name  = "credentials.useSecret"
    value = "false" # IRSA
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "velero"
  }

  # Configuration backupStorageLocations
  set {
    name  = "configuration.backupStorageLocations[0].name"
    value = "aws"
  }
  set {
    name  = "configuration.backupStorageLocations[0].provider"
    value = "aws"
  }
  set {
    name  = "configuration.backupStorageLocations[0].bucket"
    value = var.velero_backup_bucket_name
  }
  set {
    name  = "configuration.backupStorageLocations[0].config.region"
    value = var.region
  }

  # Configuration volumeSnapshotLocations
  set {
    name  = "configuration.volumeSnapshotLocations[0].name"
    value = "aws"
  }
  set {
    name  = "configuration.volumeSnapshotLocations[0].provider"
    value = "aws"
  }
  set {
    name  = "configuration.volumeSnapshotLocations[0].config.region"
    value = var.region
  }

  # Configuration initContainers pour le plugin AWS
  set {
    name  = "initContainers[0].name"
    value = "velero-plugin-for-aws"
  }
  set {
    name  = "initContainers[0].image"
    value = "velero/velero-plugin-for-aws:v1.14.1" # Check version compatibility with Velero Helm chart
  }
  set {
    name  = "initContainers[0].volumeMounts[0].mountPath"
    value = "/target"
  }
  set {
    name  = "initContainers[0].volumeMounts[0].name"
    value = "plugins"
  }

  force_update = true
}
