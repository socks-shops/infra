# Plugin AWS EBS CSI Driver pour que Kubernetes puisse créer/attacher des volumes
resource "helm_release" "aws_ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  version    = "2.44.0"
  values     = [
    yamlencode({
      controller = {
        serviceAccount = {
          create      = true
          name        = "ebs-csi-controller-sa"
          annotations = {
            "eks.amazonaws.com/role-arn" = var.ebs_csi_driver_role_arn
          }
        }
      }

      storageClasses = [
        {
          name                  = "gp3"
          isDefaultClass        = true
          reclaimPolicy         = "Delete"
          volumeBindingMode     = "WaitForFirstConsumer"
          allowVolumeExpansion  = true
          parameters = {
            type   = "gp3"
            fsType = "ext4"
          }
        }
      ]
    })
  ]
}
