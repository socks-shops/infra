# Create "dev" namespace
resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
}

# Create "staging" namespace
resource "kubernetes_namespace" "staging" {
  metadata {
    name = "staging"
  }
}

# Create "prod" namespace
resource "kubernetes_namespace" "prod" {
  metadata {
    name = "prod"
  }
}

# Create "velero" namespace
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
}

# Create "monitoring" namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}
