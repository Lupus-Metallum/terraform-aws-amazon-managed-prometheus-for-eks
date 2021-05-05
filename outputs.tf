output "iam_role_arn" {
    value = aws_iam_role.eks_amp_role.arn
}

output "prometheus_workspace_id" {
    value = aws_prometheus_workspace.prod_eks_metrics.id
}

output "prometheus_workspace_arn" {
    value = aws_prometheus_workspace.prod_eks_metrics.arn
}

output "prometheus_workspace_endpoint" {
    value = aws_prometheus_workspace.prod_eks_metrics.prometheus_endpoint
}
