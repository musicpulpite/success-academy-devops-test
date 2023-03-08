terraform {
  required_version = ">= 1.3"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.50"
    }
  }
}

# IMPORTANT: go back and reconfigure this to use an ASSUMED ROLE  ??
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Purpose = "success-academy-devops-test"
      Env     = var.environment
    }
  }
}

locals {
  lambda_definition_name = "lambda_definition"
}

data "aws_canonical_user_id" "current" {}