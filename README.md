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

<!-- BEGIN_TF_DOCS -->

<img src="https://raw.githubusercontent.com/Lupus-Metallum/brand/master/images/logo.jpg" width="400"/>

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.1.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 1.11 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.1.2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | ~> 1.11 |
| <a name="provider_local"></a> [local](#provider\_local) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_template"></a> [template](#provider\_template) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.amp_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.eks_amp_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.amp_write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_prometheus_workspace.prod_eks_metrics](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace) | resource |
| [aws_vpc_endpoint.prometheus](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [helm_release.prometheus_install](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.prometheus](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [local_file.prometheus_values](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.prometheus_update](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_iam_policy_document.remote_write_assume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [template_file.prometheus_values](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Name of the EKS cluster to use. | `string` | n/a | yes |
| <a name="input_create_amp_vpc_endpoint"></a> [create\_amp\_vpc\_endpoint](#input\_create\_amp\_vpc\_endpoint) | Should this module create a VPC endpoint for Amazon Managed Prometheus? | `bool` | `true` | no |
| <a name="input_create_oidc_iam_provider"></a> [create\_oidc\_iam\_provider](#input\_create\_oidc\_iam\_provider) | Should this module create the required IAM OIDC Provider? | `bool` | `false` | no |
| <a name="input_create_prometheus_server"></a> [create\_prometheus\_server](#input\_create\_prometheus\_server) | Should this module create a Prometheus server statefulset in the EKS cluster for Amazon Managed Prometheus? | `bool` | `true` | no |
| <a name="input_grafana_namespace"></a> [grafana\_namespace](#input\_grafana\_namespace) | Name of Grafana namespace. | `string` | `"grafana"` | no |
| <a name="input_prometheus_namespace"></a> [prometheus\_namespace](#input\_prometheus\_namespace) | Name of Prometheus namespace. | `string` | `"prometheus"` | no |
| <a name="input_prometheus_workspace_alias"></a> [prometheus\_workspace\_alias](#input\_prometheus\_workspace\_alias) | Friendly alias for the Prometheus workspace | `string` | `"Prometheus-Metrics"` | no |
| <a name="input_service_account_iam_policy_name"></a> [service\_account\_iam\_policy\_name](#input\_service\_account\_iam\_policy\_name) | Name of the service account IAM policy | `string` | `"AWSManagedPrometheusWriteAccessPolicy"` | no |
| <a name="input_service_account_iam_role_description"></a> [service\_account\_iam\_role\_description](#input\_service\_account\_iam\_role\_description) | Description of IAM role for the service account | `string` | `"IAM role to be used by a K8s service account with write access to AMP"` | no |
| <a name="input_service_account_iam_role_name"></a> [service\_account\_iam\_role\_name](#input\_service\_account\_iam\_role\_name) | Name of IAM role for the service account | `string` | `"EKS-AMP-ServiceAccount-Role"` | no |
| <a name="input_service_account_name"></a> [service\_account\_name](#input\_service\_account\_name) | Name of IAM Proxy Service Account. | `string` | `"iamproxy-service-account"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags to apply to tagable resources | `map(string)` | `{}` | no |
| <a name="input_vpc_endpoint_security_groups"></a> [vpc\_endpoint\_security\_groups](#input\_vpc\_endpoint\_security\_groups) | List of security groups for a VPC endpoint for AMP | `list(string)` | `[]` | no |
| <a name="input_vpc_endpoint_subnets"></a> [vpc\_endpoint\_subnets](#input\_vpc\_endpoint\_subnets) | List of subnets to place ENI's in for a VPC endpoint for AMP | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID for the VPC to create the VPC endpoint in. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | n/a |
| <a name="output_prometheus_workspace_arn"></a> [prometheus\_workspace\_arn](#output\_prometheus\_workspace\_arn) | n/a |
| <a name="output_prometheus_workspace_endpoint"></a> [prometheus\_workspace\_endpoint](#output\_prometheus\_workspace\_endpoint) | n/a |
| <a name="output_prometheus_workspace_id"></a> [prometheus\_workspace\_id](#output\_prometheus\_workspace\_id) | n/a |
<!-- END_TF_DOCS -->