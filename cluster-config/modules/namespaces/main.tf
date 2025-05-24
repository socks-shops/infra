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

# Create "mongodb" namespace
resource "kubernetes_namespace" "mongodb" {
  metadata {
    name = "mongodb"
  }
}

# Create "mysql" namespace
resource "kubernetes_namespace" "mysql" {
  metadata {
    name = "mysql"
  }
}

# Create "redis" namespace
resource "kubernetes_namespace" "redis" {
  metadata {
    name = "redis"
  }
}

# Create "velero" namespace
resource "kubernetes_namespace" "velero" {
  metadata {
    name = "velero"
  }
}
