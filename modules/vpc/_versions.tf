terraform {
  required_version = ">= 1.11.0" # Ensure Terraform is at least v1.11.0

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92" # Allows any 5.x version but prevents 6.0+
    }
  }
}
