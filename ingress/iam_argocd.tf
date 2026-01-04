data "aws_iam_policy_document" "argocd_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "argocd" {
  assume_role_policy = data.aws_iam_policy_document.argocd_assume_role.json
  name               = "linuxtips-control-plane-argocd"
}

data "aws_iam_policy_document" "argocd_policy" {
  version = "2012-10-17"

  statement {

    effect = "Allow"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]

    resources = [
      "*"
    ]

  }

}

resource "aws_iam_policy" "argocd_policy" {
  name        = format("%s-argocd-policy", "linuxtips-control-plane")
  path        = "/"
  description = var.project_name

  policy = data.aws_iam_policy_document.argocd_policy.json
}

resource "aws_iam_policy_attachment" "argocd_policy" {
  name = "argocd_policy"

  roles = [aws_iam_role.argocd.name]

  policy_arn = aws_iam_policy.argocd_policy.arn
}

