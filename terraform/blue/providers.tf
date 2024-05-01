terraform {
  required_version = "~> 1.7.0"
  required_providers {
    aws = {
      version = "~> 5.28.0"
    }
  }
  backend "s3" {
    bucket         = "lyria-terraform-state-2024"
    encrypt        = true
    dynamodb_table = "lyria-state-locks-2024"
    key            = "blue/terraform.tfstate"
    region         = "us-east-1"
    profile        = "kris84"
  }
}