module "eks_context" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  context    = module.this.context
  attributes = ["cluster", "karpenter"]
}

module "vpc" {
  source = "../../modules/vpc"

  context      = module.this.context
  region       = var.region
  vpc_cidr     = var.vpc_cidr
  cluster_name = module.eks_context.id
}

module "eks" {
  source = "../../modules/eks"

  context                                  = module.eks_context.context
  region                                   = var.region
  cluster_name                             = module.eks_context.id
  cluster_version                          = var.cluster_version
  cluster_public_access                    = var.cluster_public_access
  enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions
  vpc_id                                   = module.vpc.vpc_id
  public_subnet_ids                        = module.vpc.public_subnet_ids
  private_subnet_ids                       = module.vpc.private_subnet_ids
  intra_subnet_ids                         = module.vpc.intra_subnet_ids
  system_pool_config                       = var.system_pool_config
}
