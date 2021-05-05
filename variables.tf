variable "eks_cluster_name" {
  description = "Name of the EKS cluster to use."
  type        = string
}

variable "grafana_namespace" {
  description = "Name of Grafana namespace."
  type        = string
  default     = "grafana"
}

variable "prometheus_namespace" {
  description = "Name of Prometheus namespace."
  type        = string
  default     = "prometheus"
}

variable "service_account_name" {
  description = "Name of IAM Proxy Service Account."
  type        = string
  default     = "iamproxy-service-account"
}

variable "service_account_iam_role_name" {
  description = "Name of IAM role for the service account"
  type        = string
  default     = "EKS-AMP-ServiceAccount-Role"
}

variable "service_account_iam_role_description" {
  description = "Description of IAM role for the service account"
  type        = string
  default     = "IAM role to be used by a K8s service account with write access to AMP"
}

variable "service_account_iam_policy_name" {
  description = "Name of the service account IAM policy"
  type        = string
  default     = "AWSManagedPrometheusWriteAccessPolicy"
}

variable "create_oidc_iam_provider" {
  description = "Should this module create the required IAM OIDC Provider?"
  type        = bool
  default     = false
}

variable "vpc_endpoint_subnets" {
  description = "List of subnets to place ENI's in for a VPC endpoint for AMP"
  type        = list(string)
  default     = []
}

variable "vpc_endpoint_security_groups" {
  description = "List of security groups for a VPC endpoint for AMP"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "ID for the VPC to create the VPC endpoint in."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Map of tags to apply to tagable resources"
  type        = map(string)
  default     = {}
}

variable "prometheus_workspace_alias" {
  description = "Friendly alias for the Prometheus workspace"
  type        = string
  default     = "Prometheus-Metrics"
}

variable "create_amp_vpc_endpoint" {
  description = "Should this module create a VPC endpoint for Amazon Managed Prometheus?"
  type        = bool
  default     = true
}

variable "create_prometheus_server" {
  description = "Should this module create a Prometheus server statefulset in the EKS cluster for Amazon Managed Prometheus?"
  type        = bool
  default     = true
}
