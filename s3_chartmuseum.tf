# ChartMuseum S3 Storage Configuration
# Creates an S3 bucket to store Helm charts for ChartMuseum - a private Helm chart repository
# ChartMuseum allows teams to host and manage their own Helm charts in a centralized location

# Main S3 bucket for storing Helm charts
# Bucket name includes project name and account ID to ensure global uniqueness
resource "aws_s3_bucket" "chartmuseum" {
  bucket = format("%s-%s-chartmuseum", var.project_name, data.aws_caller_identity.current.account_id)
}

# Configure bucket ownership controls
# BucketOwnerPreferred ensures the bucket owner has full control over objects
# This is required for proper ACL configuration in newer AWS provider versions
resource "aws_s3_bucket_ownership_controls" "chartmuseum" {
  bucket = aws_s3_bucket.chartmuseum.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Set bucket ACL to private
# Restricts access to only authorized users/services
# ChartMuseum will use IAM roles/policies for programmatic access
resource "aws_s3_bucket_acl" "chartmuseum" {
  bucket = aws_s3_bucket.chartmuseum.id
  acl    = "private"

  # Ensure ownership controls are applied before setting ACL
  depends_on = [
    aws_s3_bucket_ownership_controls.chartmuseum
  ]
}

# Note: Additional configurations typically needed for production ChartMuseum:
# - aws_s3_bucket_versioning: Enable versioning for chart history
# - aws_s3_bucket_server_side_encryption_configuration: Encrypt charts at rest
# - aws_s3_bucket_public_access_block: Prevent accidental public access
# - IAM policies: Grant ChartMuseum service account access to this bucket