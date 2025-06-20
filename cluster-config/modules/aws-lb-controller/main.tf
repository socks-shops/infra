# Create an AWS Load Balancer Controller service account
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.role_arn
    }
  }
}

# Install AWS Load Balancer Controller in cluster
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.13.0"

  namespace = "kube-system"

  values = [
    <<EOT
    region: ${var.region}
    vpcId: ${var.vpc_id}

    image:
      repository: 602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller

    serviceAccount:
      create: false
      name: aws-load-balancer-controller

    clusterName: ${var.cluster_name}
    EOT
  ]

  depends_on = [kubernetes_service_account.aws_lb_controller]
}
