resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.5.0"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.karpenter.arn
  }

  set {
    name  = "settings.clusterName"
    value = var.project_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = aws_eks_cluster.main.endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.nodes.name
  }


  set {
    name  = "settings.interruptionQueue"
    value = aws_sqs_queue.karpenter.name
  }

  set {
    name  = "serviceMonitor.enabled"
    value = "true"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_fargate_profile.karpenter,
    aws_iam_instance_profile.nodes,
    aws_iam_role.eks_nodes_role,
    aws_iam_role.karpenter

  ]

}