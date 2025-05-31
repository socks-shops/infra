# IAM role for the Velero service account
locals {
  oidc_provider_short = split("oidc-provider/", var.oidc_provider)[1]
}

resource "aws_iam_role" "velero" {
  name = "${var.cluster_name}-velero-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::${var.account_id}:oidc-provider/${local.oidc_provider_short}"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          "StringEquals" = {
            "${local.oidc_provider_short}:sub" = "system:serviceaccount:velero:velero"
          }
        }
      }
    ]
  })
}


# Policies for the role
resource "aws_iam_policy" "velero" {
  name        = "${var.cluster_name}-velero-policy"
  description = "IAM policy for Velero backups on EKS"
  # Charge la politique depuis le fichier JSON externe
  policy = templatefile("${path.module}/aws_velero_policy.json.tpl", {
    bucket_name = var.velero_backup_bucket_name,
    region      = var.region
  })
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "velero" {
  policy_arn = aws_iam_policy.velero.arn
  role       = aws_iam_role.velero.name
}


################ BACKUPS BUCKET #################
#################################################

# Create bucket S3 for backups
resource "aws_s3_bucket" "velero_backup" {
  bucket        = var.velero_backup_bucket_name
  force_destroy = true

  tags = {
    Name = "velero-backups"
  }
}

# Activate versioning
resource "aws_s3_bucket_versioning" "velero_backup" {
  bucket = aws_s3_bucket.velero_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Set minimal security
resource "aws_s3_bucket_public_access_block" "velero_backup" {
  bucket = aws_s3_bucket.velero_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
