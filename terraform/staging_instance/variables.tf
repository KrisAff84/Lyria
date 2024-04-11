variable "name_prefix" {
  description = "The prefix to use for the name of the resources created"
  type        = string
  default     = "lyria"
}

variable "aws_profile" {
  description = "The AWS profile to use for the AWS provider"
  type        = string
  default     = "kris84"
}

variable "aws_region" {
  description = "The AWS region to use for the AWS provider"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The type of instance to launch"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "The AMI to use for the instance"
  type        = string
  default     = "ami-080e1f13689e07408"
}

variable "key_name" {
  description = "The name of the key pair to use for the instance"
  type        = string
  default     = "lyria_2024"
}

variable "my_ip" {
  description = "Your IP address"
  default     = "24.162.52.74/32"
}