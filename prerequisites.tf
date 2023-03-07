terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = ">= 4.50"
        }
    }
}

# IMPORTANT: go back and reconfigure this to use and ASSUMED ROLE 
provider "aws" {
    region = var.aws_region
}