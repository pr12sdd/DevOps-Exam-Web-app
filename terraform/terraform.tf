terraform {
  required_providers {
    aws={
      source = "hashicorp/aws"
      version = "6.25.0"
    }
  }

  backend "s3" {
    bucket = "microsvc-bucket123"
    key = "terraform.tfstate"
    region = "us-east-2"
    dynamodb_table = "microsvc-dynamodb"
  }
}