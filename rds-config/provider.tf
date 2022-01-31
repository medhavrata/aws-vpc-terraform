terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-180122"
    key            = "rds-config/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Configure the Terraform Block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws" # this defaults to registry.terraform.io/hashicorp/aws
      version = "~> 3.0"
    }
  }

  required_version = ">= 0.14.9"
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}
