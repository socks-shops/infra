#################################################
############## NAMESPACE CREATION ###############
#################################################

# Create "dev" namespace (required for Service Account and more)
resource "kubernetes_namespace" "dev" {
  metadata {
    name = "dev"
  }
  depends_on = [aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp]
}



#################################################
############## IAM ROLE : MASTER ################
#################################################

# Create IAM role
resource "aws_iam_role" "master" {
  name = "${var.iam_role_name}-master"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "eks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Attach policies to IAM role
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.master.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.master.name
}



#################################################
############## IAM ROLE : WORKER ################
#################################################

# Create IAM role
resource "aws_iam_role" "worker" {
  name = "${var.iam_role_name}-worker"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

# Create a custom IAM policy
resource "aws_iam_policy" "autoscaler" {
  name = "ed-eks-autoscaler-policy"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeTags",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

# Attach policies to IAM role
resource "aws_iam_role_policy_attachment" "autoscaler" {
  policy_arn = aws_iam_policy.autoscaler.arn
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.worker.name
}
resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.worker.name
}
resource "aws_iam_role_policy_attachment" "x-ray" {
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.worker.name
}

resource "aws_iam_role_policy_attachment" "s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.worker.name
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "worker" {
  depends_on = [aws_iam_role.worker]
  name       = "ed-eks-worker-new-profile"
  role       = aws_iam_role.worker.name
}
# NOTE : L’Instance Profile est ce que l'on va attacher aux instances EC2 (ou Node Group) pour qu’elles utilisent le rôle worker et bénéficient des permissions ci-dessus.


#################################################
######### IAM ROLE : AWS LB CONTROLLER ##########
#################################################

# Create IAM role
resource "aws_iam_role" "aws_lb_controller" {
  name = "${var.cluster_name}-aws-lb-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${replace(aws_eks_cluster.sockshop-eks.identity[0].oidc[0].issuer, "https://", "")}"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          "StringEquals" = {
            "${replace(aws_eks_cluster.sockshop-eks.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:dev:aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  depends_on = [aws_iam_openid_connect_provider.eks_oidc_provider, aws_eks_node_group.node-grp,
  aws_eks_cluster.sockshop-eks
  ]
}

# Create OIDC provider
resource "aws_iam_openid_connect_provider" "eks_oidc_provider" {
  url = aws_eks_cluster.sockshop-eks.identity[0].oidc[0].issuer

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "9e99a64e2498cfa1988b8f2e8a9c647c4f5c02d3"
  ]
}

# Create a custom IAM policy
resource "aws_iam_policy" "aws_lb_controller" {
  name        = "AWSLoadBalancerControllerPolicy"
  description = "Policy for the AWS Load Balancer Controller"

  # Charge la politique depuis le fichier JSON externe
  policy = file("${path.module}/aws_lb_controller_policy.json")
  depends_on = [aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp]
}

# Attach IAM policy to IAM role
resource "aws_iam_role_policy_attachment" "aws_lb_controller_attachment" {
  policy_arn = aws_iam_policy.aws_lb_controller.arn
  role       = aws_iam_role.aws_lb_controller.name
  depends_on = [aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp]
}

# Create "aws-load-balancer-controller" service account
resource "kubernetes_service_account" "aws_lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "dev"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_lb_controller.arn
    }
  }

  depends_on = [aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp]
}



#################################################
############ LB CONTROLLER CREATION #############
#################################################

# Install AWS Load Balancer Controller in cluster (dev namespace)
resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.12.0"

  namespace = "dev"

  values = [
    <<EOT
    clusterName: ${var.cluster_name}-VPC
    serviceAccount:
      create: false
      name: aws-load-balancer-controller
    EOT
  ]

  #timeout = 180

  depends_on = [
    kubernetes_service_account.aws_lb_controller,
    aws_iam_role_policy_attachment.aws_lb_controller_attachment,
    aws_eks_cluster.sockshop-eks, aws_eks_node_group.node-grp
  ]
}



#################################################
################# EKS CREATION ##################
#################################################

resource "aws_eks_cluster" "sockshop-eks" {
  name     = "${var.cluster_name}-VPC"
  role_arn = aws_iam_role.master.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = {
    "Name" = "${var.cluster_name}-VPC"
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.AmazonEKSServicePolicy,
    aws_iam_role_policy_attachment.AmazonEKSVPCResourceController,
  ]
}

resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.sockshop-eks.name
  node_group_name = var.eks_node_group_name
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = var.subnet_ids
  capacity_type   = "ON_DEMAND"
  disk_size       = 20
  instance_types  = var.eks_worker_node_instance_type

  remote_access {
    ec2_ssh_key               = var.eks_key_pair
    source_security_group_ids = [var.eks_sg]
  }

  labels = {
    env = "dev"
  }

  scaling_config {
    desired_size = var.eks_desired_worker_node
    max_size     = var.eks_max_worker_node
    min_size     = var.eks_min_worker_node
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}
