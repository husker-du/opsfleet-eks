variable "region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

############################################################
# VPC network
############################################################
variable "vpc_cidr" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "num_subnets" {
  description = "Number of private/public subnets"
  type        = number
  default     = 3
}

variable "public_prefix" {
  description = "Prefix of the public subnets CIDR blocks"
  type        = number
  default     = 22
}

variable "private_prefix" {
  description = "Prefix of the private subnets CIDR blocks"
  type        = number
  default     = 18
}

variable "intra_prefix" {
  description = "Prefix of the intra subnets CIDR blocks"
  type        = number
  default     = 24
}

############################################################
# EKS cluster
############################################################
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "cluster_public_access" {
  description = "Indicates whether or not the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "enable_cluster_creator_admin_permissions" {
  description = "Indicates whether or not to add the cluster creator (the identity used by Terraform) as an administrator via"
  type        = bool
  default     = true
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
# Karpenter
#############################################################
variable "karpenter_version" {
  description = "Karpenter's helm chart version"
  type        = string
  default     = "1.3.3"
}

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