#Terraform Block
terraform {
    required_version = "~> 1.5"  #allows 1.5.4
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

# Provider Block
provider "aws" {
    region = var.aws_region
}