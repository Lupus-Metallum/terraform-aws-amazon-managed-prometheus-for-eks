data "aws_caller_identity" "this" {}
data "aws_region" "this" {}
data "aws_eks_cluster" "this" {
  name = var.eks_cluster_name
}
data "tls_certificate" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

locals {
  oidc_provider = replace(data.aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

resource "aws_vpc_endpoint" "prometheus" {
  count              = var.create_amp_vpc_endpoint == true ? 1 : 0
  vpc_endpoint_type  = "Interface"
  vpc_id             = var.vpc_id
  service_name       = "com.amazonaws.${data.aws_region.this.name}.aps-workspaces"
  subnet_ids         = var.vpc_endpoint_subnets
  security_group_ids = var.vpc_endpoint_security_groups

  tags = var.tags
}

resource "aws_prometheus_workspace" "prod_eks_metrics" {
  alias = var.prometheus_workspace_alias
}

data "aws_iam_policy_document" "remote_write_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${local.oidc_provider}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values = [
        "system:serviceaccount:${var.grafana_namespace}:${var.service_account_name}"
      ]
    }
  }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${local.oidc_provider}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider}:sub"
      values = [
        "system:serviceaccount:${var.prometheus_namespace}:${var.service_account_name}"
      ]
    }
  }
}

resource "aws_iam_role" "eks_amp_role" {
  name               = var.service_account_iam_role_name
  description        = var.service_account_iam_role_description
  assume_role_policy = data.aws_iam_policy_document.remote_write_assume.json
}

resource "aws_iam_policy" "amp_write" {
  name        = var.service_account_iam_policy_name
  description = "Permissions to write to all AMP workspaces"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "aps:RemoteWrite",
          "aps:QueryMetrics",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "amp_write" {
  role       = aws_iam_role.eks_amp_role.name
  policy_arn = aws_iam_policy.amp_write.arn
}

resource "aws_iam_openid_connect_provider" "this" {
  count           = var.create_oidc_iam_provider == true ? 1 : 0
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "kubernetes_namespace" "prometheus" {
  count    = var.create_prometheus_server == true ? 1 : 0
  metadata {
    name = var.prometheus_namespace
  }
}
locals {
    args = ["--name", "aps", "--region", data.aws_region.this.name, "--host aps-workspaces.${data.aws_region.this.name}.amazonaws.com", "--port", ":8005"]
}

data "template_file" "prometheus_values" {
  count    = var.create_prometheus_server == true ? 1 : 0
  template = file("${path.module}/src/prometheus-for-amp.values")

  vars = {
    region            = data.aws_region.this.name
    name              = var.service_account_name
    arn               = aws_iam_role.eks_amp_role.arn
    workspace         = aws_prometheus_workspace.prod_eks_metrics.id
  }
}

resource "local_file" "prometheus_values" {
    count    = var.create_prometheus_server == true ? 1 : 0
    content  = data.template_file.prometheus_values[0].rendered
    filename = "${path.module}/values.yaml"
}

resource "helm_release" "prometheus_install" {
  count    = var.create_prometheus_server == true ? 1 : 0
  name         = "prometheus-for-amp"
  repository   = "https://prometheus-community.github.io/helm-charts"
  chart        = "prometheus"
  namespace    = var.prometheus_namespace

}

resource "null_resource" "prometheus_update" {
  count    = var.create_prometheus_server == true ? 1 : 0

  provisioner "local-exec" {
    command     = "helm upgrade --install prometheus-for-amp --values ${path.module}/values.yaml --namespace ${var.prometheus_namespace} --wait prometheus-community/prometheus"
    interpreter = ["/usr/bin/env", "bash", "-c"]
  }

  depends_on = [
    helm_release.prometheus_install,
    local_file.prometheus_values,
  ]
}


