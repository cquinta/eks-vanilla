# ChartMuseum IAM Configuration
# Creates IAM role and policies for ChartMuseum to access S3 bucket
# Uses EKS Pod Identity for secure service account authentication

# Trust policy for ChartMuseum IAM role
# Allows EKS pods to assume this role using Pod Identity
data "aws_iam_policy_document" "chartmuseum_role" {
  version = "2012-10-17"

  statement {
    effect = "Allow"

    # EKS Pod Identity service principal
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    # Required actions for Pod Identity authentication
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

# IAM role for ChartMuseum service
# Will be assumed by ChartMuseum pods via Pod Identity
resource "aws_iam_role" "chartmuseum_role" {
  assume_role_policy = data.aws_iam_policy_document.chartmuseum_role.json
  name               = format("%s-chartmuseum", var.project_name)
}

# IAM policy document for S3 access
# Grants full S3 permissions on the ChartMuseum bucket
data "aws_iam_policy_document" "chartmuseum_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    
    # Full S3 access - consider restricting to specific actions in production:
    # s3:GetObject, s3:PutObject, s3:DeleteObject, s3:ListBucket
    actions = [
      "s3:*",
    ]

    # Access to ChartMuseum bucket and all objects within it
    resources = [
      format("%s/*", aws_s3_bucket.chartmuseum.arn),  # Objects in bucket
      aws_s3_bucket.chartmuseum.arn,                   # Bucket itself
    ]
  }
}

# Create the IAM policy from the policy document
resource "aws_iam_policy" "chartmuseum_policy" {
  name        = format("%s-chartmuseum", var.project_name)
  path        = "/"
  description = "Policy for ChartMuseum S3 access"

  policy = data.aws_iam_policy_document.chartmuseum_policy.json
}

# Attach the policy to the IAM role
resource "aws_iam_policy_attachment" "chartmuseum" {
  name = "chartmuseum"
  roles = [
    aws_iam_role.chartmuseum_role.name
  ]

  policy_arn = aws_iam_policy.chartmuseum_policy.arn
}

# EKS Pod Identity Association
# Links the Kubernetes service account to the IAM role
# Enables ChartMuseum pods to automatically assume the IAM role
resource "aws_eks_pod_identity_association" "chartmuseum" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "chartmuseum"           # Kubernetes namespace
  service_account = "chartmuseum"           # Kubernetes service account name
  role_arn        = aws_iam_role.chartmuseum_role.arn
}

# Security Note: The s3:* permission is broad for development.
# For production, consider using least-privilege permissions:
# - s3:GetObject, s3:PutObject, s3:DeleteObject for chart operations
# - s3:ListBucket for listing charts
# - s3:GetBucketLocation for bucket access