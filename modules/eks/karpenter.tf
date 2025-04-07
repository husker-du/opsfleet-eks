################################################################################
# Karpenter
################################################################################
module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 20.34"

  cluster_name          = module.eks.cluster_name
  enable_v1_permissions = true
  namespace             = var.karpenter_namespace

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix   = false
  node_iam_role_name              = module.eks.cluster_name
  create_pod_identity_association = true

  tags = module.eks_context.tags
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = var.karpenter_namespace
  create_namespace = true
  chart            = var.karpenter_chart
  version          = var.karpenter_version
  repository       = var.karpenter_repository
  wait             = var.karpenter_wait

  values = [
    templatefile("${path.module}/k8s/karpenter/karpenter_values.yaml.tftpl", {
      cluster_name     = module.eks.cluster_name
      cluster_endpoint = module.eks.cluster_endpoint
      queue_name       = module.karpenter.queue_name
    })
  ]

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }
}

################################################################################
# NodePool and EC2NodeClass
################################################################################
resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = templatefile("${path.module}/k8s/karpenter/nodepool.yaml.tftpl", {
    ec2nodeclass_name = kubectl_manifest.karpenter_node_class.name
  })
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = templatefile("${path.module}/k8s/karpenter/nodeclass.yaml.tftpl", {
    cluster_name = module.eks.cluster_name
  })

  depends_on = [
    helm_release.karpenter
  ]
}
