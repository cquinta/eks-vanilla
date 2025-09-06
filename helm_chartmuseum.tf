# ChartMuseum Helm Deployment
# Deploys ChartMuseum as a private Helm chart repository on EKS
# Configured to use S3 as backend storage with Pod Identity authentication

resource "helm_release" "chartmuseum" {
  name       = "chartmuseum"
  repository = "https://chartmuseum.github.io/charts"  # Official ChartMuseum Helm repository
  chart      = "chartmuseum"
  namespace  = "chartmuseum"

  create_namespace = true  # Automatically create the namespace if it doesn't exist

  # Create service account for Pod Identity integration
  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  # Enable AWS SDK configuration loading
  # Required for Pod Identity authentication
  set {
    name  = "env.open.AWS_SDK_LOAD_CONFIG"
    value = "true"
  }

  # Enable ChartMuseum API endpoints
  # Allows chart upload/download operations
  set {
    name  = "env.open.DISABLE_API"
    value = "false"
  }

  # Configure S3 as storage backend
  set {
    name  = "env.open.STORAGE"
    value = "amazon"
  }

  # Disable state files for better performance
  # ChartMuseum will scan S3 directly for charts
  set {
    name  = "env.open.DISABLE_STATEFILES"
    value = "true"
  }

  # S3 bucket configuration
  # Points to the bucket created in s3_chartmuseum.tf
  set {
    name  = "env.open.STORAGE_AMAZON_BUCKET"
    value = aws_s3_bucket.chartmuseum.id
  }

  # AWS region for S3 access
  set {
    name  = "env.open.STORAGE_AMAZON_REGION"
    value = var.region
  }

  # Ensure EKS cluster and Fargate profile are ready
  depends_on = [
    aws_eks_cluster.main,
    aws_eks_fargate_profile.karpenter
  ]
}

resource "aws_s3_object" "linuxtips" {
  bucket = aws_s3_bucket.chartmuseum.id
  key    = "linuxtips-0.1.0.tgz"
  source = "${path.module}/helm/linuxtips-0.1.0.tgz"
  etag   = filemd5("${path.module}/helm/linuxtips-0.1.0.tgz")
}
# Usage after deployment:
# 1. Add ChartMuseum as Helm repository:
#    helm repo add chartmuseum http://chartmuseum.chartmuseum.svc.cluster.local:8080
# 2. Upload charts via API:
#    curl --data-binary "@chart.tgz" http://chartmuseum.chartmuseum.svc.cluster.local:8080/api/charts
# 3. Install charts:
#    helm install my-release chartmuseum/chart-name