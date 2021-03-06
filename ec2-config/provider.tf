# Configure the S3 backend
terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-180122"
    key            = "ec2-config/terraform.tfstate"
    dynamodb_table = "terraform-state-lock"
    region         = "us-east-1"
    encrypt        = true
  }
}

# Configure the terraform block
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  required_version = ">= 0.14.9"
}

# Configure the provider
provider "aws" {
  region = "us-east-1"
}
