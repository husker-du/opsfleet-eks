
##############################################################
# Null label contexts
##############################################################
module "eks_context" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context    = module.this.context
  attributes = ["cluster", "karpenter"]
}

################################################################################
# EKS cluster
################################################################################
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.34"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Give the Terraform identity admin access to the cluster
  # which will allow it to deploy resources into the cluster
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  cluster_endpoint_public_access           = var.cluster_public_access

  vpc_id                   = var.vpc_id
  control_plane_subnet_ids = var.intra_subnet_ids
  subnet_ids               = var.private_subnet_ids

  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        tolerations = [
          # Allow CoreDNS to run on the same nodes as the Karpenter controller
          # for use during cluster creation when Karpenter nodes do not yet exist
          {
            key    = "CriticalAddonsOnly"
            value  = "true"
            effect = "NoSchedule"
          }
        ]
      })
    }
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  eks_managed_node_groups = {
    # Node group to allocate karpenter controller and coreDNS
    system = {
      ami_type       = var.system_pool_config.ami_type
      instance_types = var.system_pool_config.instance_types

      min_size     = var.system_pool_config.min_size
      max_size     = var.system_pool_config.max_size
      desired_size = var.system_pool_config.desired_size

      labels = {
        # Used to ensure Karpenter runs on nodes that it does not manage
        "CriticalAddonsOnly" = "true"
      }

      taints = {
        # The pods that do not tolerate this taint should run on nodes
        # created by Karpenter
        karpenter = {
          key    = "CriticalAddonsOnly"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      }
    }
  }

  node_security_group_tags = merge(module.eks_context.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  })

  tags = module.eks_context.tags
}

module "disabled_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.34"

  create = false
}
