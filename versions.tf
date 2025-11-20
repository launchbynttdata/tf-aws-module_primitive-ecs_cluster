# =======================================================================
# ECS SERVICE PRIMITIVE MODULE - VERSIONS
# =======================================================================
# This file defines the required Terraform and provider versions for
# the ECS service primitive module.
# =======================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
