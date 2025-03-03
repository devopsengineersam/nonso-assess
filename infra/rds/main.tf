terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.89.0"
    }
  }
  backend "s3" {
    bucket = "nonso-assess-tf-bucket"
    key = "nonso-assess-tf-bucket/rds"
    region = "us-east-1"
  }
}

provider "aws" {
    region = "us-east-1"
}