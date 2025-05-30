resource "aws_security_group" "eks_sg" {
  name_prefix = "eks-sg-"
  description = "Security Group for the EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8079
    to_port     = 8079
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "Allow traffic from ALB to EKS node"
  }

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr] # Assuming the internal VPC CIDR range
    description = "Allow internal communication between EKS nodes"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "sg-eks"
  }
}

# resource "aws_security_group" "sg_alb" {
#   name_prefix   = "alb-sg-"
#   description   = "Security Group for the ALB"
#   vpc_id        = var.vpc_id

#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow HTTP traffic from all"
#   }

#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow HTTPS traffic from all"
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#     description = "Allow all outbound traffic"
#   }

#   tags = {
#     Name = "sg-alb"
#   }
# }
