resource "helm_release" "chartmuseum" {
  name       = "chartmuseum"
  repository = "https://chartmuseum.github.io/charts"
  chart      = "chartmuseum"
  namespace  = "chartmuseum"

  create_namespace = true

  set =[
    {
    name  = "serviceAccount.create"
    value = "true"
   },
   {
    name  = "env.open.AWS_SDK_LOAD_CONFIG"
    value = "true"
   },

   {
    name  = "env.open.DISABLE_API"
    value = "false"
   },
   {
    name  = "env.open.STORAGE"
    value = "amazon"
   },
   {
    name  = "env.open.DISABLE_STATEFILES"
    value = "true"
   },

   {
    name  = "env.open.STORAGE_AMAZON_BUCKET"
    value = aws_s3_bucket.chartmuseum.id
   },

   {
    name  = "env.open.STORAGE_AMAZON_REGION"
    value = var.region
   }
  ]
  depends_on = [
    aws_eks_cluster.main,
    helm_release.karpenter
  ]
}