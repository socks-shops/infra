resource "aws_security_group" "eks_sg" {
  name_prefix = "eks-sg-"
  description = "Security Group for the EKS nodes"
  vpc_id      = var.vpc_id

  # Communication Kubelet (Plan de contrôle -> Nœuds)
  ingress {
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
    description     = "Allow kubelet communication from EKS control plane"
  }

  # Communication HTTPS EKS (Plan de contrôle -> Nœuds)
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [var.eks_cluster_security_group_id]
    description     = "Allow HTTPS from EKS control plane to nodes"
  }

  # Accès SSH interne au VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow SSH access from within VPC"
  }

  # Résolution DNS (UDP)
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow DNS resolution"
  }

  # Trafic ALB vers Nœud (port 8079)
  ingress {
    from_port   = 8079
    to_port     = 8079
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow traffic from ALB to EKS node (Sock Shop specific)"
  }

  # Communication Inter-nœuds EKS
  ingress {
    from_port   = 0
    to_port     = 65535 # Ports éphémères et communication inter-pod/inter-nœud
    protocol    = "tcp"
    self        = true
    description = "Allow internal communication between EKS nodes (self-referencing)"
  }

  # Tout trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # Accès Service de Métadonnées (IMDS)
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["169.254.169.254/32"]
    description = "Allow access to instance metadata service (IMDS)"
  }

  tags = {
    Name = "sg-eks"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
