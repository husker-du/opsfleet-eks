# Set common variables for the environment. This is automatically pulled in in the root terragrunt.hcl configuration to
# feed forward to the child modules.
locals {
  # Null label naming convention
  stage = "dev"

  # EKS
  cluster_name = "demo-dev-karpenter"
}
