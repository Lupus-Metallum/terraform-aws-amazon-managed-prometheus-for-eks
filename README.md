# terraform-module-template

## Quick start example
``` Terraform
module "eks_prometheus_metrics" {
  source =  "Lupus-Metallum/terraform-aws-amazon-managed-prometheus-for-eks/aws"
  version = 1.0.0

  prometheus_workspace_alias           = "Example-EKS-Metrics"
  eks_cluster_name                     = var.eks_cluster_name
  grafana_namespace                    = "grafana"
  prometheus_namespace                 = "prometheus"
  service_account_name                 = "iamproxy-service-account"
  service_account_iam_role_name        = "EKS-AMP-ServiceAccount-Role"
  service_account_iam_role_description = "IAM role to be used by a K8s service account with write access to AMP"
  service_account_iam_policy_name      = "AWSManagedPrometheusWriteAccessPolicy"
  create_oidc_iam_provider             = false
  create_amp_vpc_endpoint              = true
  create_prometheus_server             = true

  vpc_id = aws_vpc.prod_us_east_1.id
  vpc_endpoint_security_groups = [
    aws_security_group.prod_eks_us_east_1.id
  ]
  vpc_endpoint_subnets = [
    aws_subnet.prod_vpc_edpt_private_us_east_1a.id,
    aws_subnet.prod_vpc_edpt_private_us_east_1b.id,
    aws_subnet.prod_vpc_edpt_private_us_east_1c.id,
    aws_subnet.prod_vpc_edpt_private_us_east_1d.id,
    aws_subnet.prod_vpc_edpt_private_us_east_1e.id,
    aws_subnet.prod_vpc_edpt_private_us_east_1f.id,
  ]

  tags = merge(
    var.default_tags,
    {
      Name = "Prometheus VPC Endpoint"
  })
}
```
