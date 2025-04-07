#############################################################
# Mandatory variables
#############################################################
variable "vpc_id" {
  description = "The VPC id"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of IDs of private subnets"
  type        = list(string)

}

variable "public_subnet_ids" {
  description = "List of IDs of public subnets"
  type        = list(string)
}

variable "intra_subnet_ids" {
  description = "List of IDs of intra subnets"
  type        = list(string)
}


#############################################################
# EKS variables
#############################################################
variable "region" {
  description = "AWS region where resources will be deployed"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "karpenter-demo"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "cluster_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via"
  type        = bool
  default     = false
}

variable "system_pool_config" {
  description = "Configuration for EKS system node group"
  type = object({
    name           = string
    ami_type       = string
    instance_types = list(string)
    capacity_type  = string
    min_size       = number
    max_size       = number
    desired_size   = number
  })
  default = {
    name           = "system"
    ami_type       = "BOTTLEROCKET_x86_64"
    instance_types = ["t3.medium"]
    capacity_type  = "ON_DEMAND"
    min_size       = 1
    max_size       = 3
    desired_size   = 2
  }
}

#############################################################
# Karpenter variables
#############################################################
variable "karpenter_wait" {
  description = "Karpenter's helm chart version"
  type        = bool
  default     = false
}

variable "karpenter_namespace" {
  description = "The namespece where to deploy the Karpenter controller"
  type        = string
  default     = "karpenter"
}

variable "karpenter_repository" {
  description = "Repository where to locate the karpenter helm chart"
  type        = string
  default     = "oci://public.ecr.aws/karpenter"
}

variable "karpenter_chart" {
  description = "Name of the karpenter helm chart to be installed"
  type        = string
  default     = "karpenter"
}

variable "karpenter_version" {
  description = "Karpenter's helm chart version"
  type        = string
  default     = "1.3.3"
}

#############################################################
# NGINX ingress controller variables
#############################################################
variable "ingress_wait" {
  description = "Nginx ingress controller's helm chart version"
  type        = bool
  default     = false
}

variable "ingress_namespace" {
  description = "The namespece where to deploy the nginx ingress controller"
  type        = string
  default     = "nginx-ingress"
}

variable "ingress_repository" {
  description = "Repository where to locate the nginx ingress controller helm chart"
  type        = string
  default     = "oci://ghcr.io/nginx/charts"
}

variable "ingress_chart" {
  description = "Name of the nginx ingress controller helm chart to be installed"
  type        = string
  default     = "nginx-ingress"
}

variable "ingress_version" {
  description = "Nginx ingress controller's helm chart version"
  type        = string
  default     = "2.0.1"
}
