variable "aws_region" {
  description = "The AWS region to deploy resources"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "The AWS profile to use to create resources"
  default     = "kris84"
}

variable "aws_account_id" {
  description = "The AWS account ID"
  default     = "637423562225"
}

variable "aws_instance_id" {
  description = "The AWS instance ID to manage with policy"
  default     = "i-057ba06636c67355f"
}