terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      # ref: https://registry.terraform.io/providers/hashicorp/aws/latest
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.10"
    }
  }

  # Configure backend via -backend-config files/flags per account and environment.
  # Example:
  # terraform init -backend-config=backend/dev.hcl
  backend "s3" {}
}
