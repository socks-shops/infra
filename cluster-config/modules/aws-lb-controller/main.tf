# Create an AWS Load Balancer Controller service account
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = var.role_arn
    }
  }
}

# Install AWS Load Balancer Controller in cluster
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller-${var.namespace}"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.12.0"

  namespace = var.namespace

  values = [
    <<EOT
    clusterName: ${var.cluster_name}
    serviceAccount:
      create: false
      name: aws-load-balancer-controller
    EOT
  ]

  depends_on = [kubernetes_service_account.aws_lb_controller]
}
