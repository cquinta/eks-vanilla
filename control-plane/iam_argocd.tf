resource "aws_eks_pod_identity_association" "argo_server" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "argocd"
  service_account = "argocd-server"
  role_arn        = "arn:aws:iam::707257249187:role/linuxtips-control-plane-argocd"
}

resource "aws_eks_pod_identity_association" "argo_application_controller" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "argocd"
  service_account = "argocd-application-controller"
  role_arn        = "arn:aws:iam::707257249187:role/linuxtips-control-plane-argocd"
}

resource "aws_eks_pod_identity_association" "argo_applicationset_controller" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "argocd"
  service_account = "argocd-applicationset-controller"
  role_arn        = "arn:aws:iam::707257249187:role/linuxtips-control-plane-argocd"
}