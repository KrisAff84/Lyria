####################################################
#####    Network
####################################################

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "name_prefix" {
  description = "Naming prefix for all resources"
  default     = "lyria"
}

####################################################
####    EC2
####################################################

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_main" {
  description = "Default AMI is Ubuntu 22.04 and runs Docker containers on launch"
  default     = "ami-0665dad4a584996bc"
}

variable "ami_bastion" {
  description = "AMI to be used for bastion host"
  default     = "ami-0e83be366243f524a"
}

variable "key_name" {
  description = "SSH key name"
  default     = "lyria"
}

variable "my_ip" {
  description = "Your IP address"
  default     = "24.162.52.74/32"
}

####################################################
#### Storage Bucket
####################################################

variable "bucket_arn" {
  description = "ARN of the S3 bucket"
  default     = "arn:aws:s3:::lyria-storage"
}