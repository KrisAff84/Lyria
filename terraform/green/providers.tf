terraform {
  required_version = "> 1.6.5"
  required_providers {
    aws = {
      version = "~> 5.28.0"
    }
  }
  backend "s3" {
    bucket         = "lyria-terraform-state"
    encrypt        = true
    dynamodb_table = "lyria-state-locks"
    key            = "green/terraform.tfstate"
    region         = "us-east-2"
    profile        = "admin-profile"
  }
}