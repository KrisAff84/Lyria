####################################################
#####    Permissions
####################################################

variable "access_key" {
  description = "AWS Access Key"
  default     = ""
  sensitive   = true
}

variable "secret_key" {
  description = "AWS Secret Key"
  default     = ""
  sensitive   = true
}

####################################################
#####    Network
####################################################

variable "aws_region" {
  description = "AWS Region"
  default     = "us-east-2"
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.1.0.0/16"
}
variable "name_prefix" {
  description = "Naming prefix for all resources"
  default     = "lyria-green"
}

####################################################
####    EC2
####################################################

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "ami_main" {
  description = "lyria_v6 image"
  default     = "ami-027d446437564a669"
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

####################################################
#### Certificate
####################################################

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  default     = "arn:aws:acm:us-east-2:835656321421:certificate/7aee737d-0e1f-4311-b1ff-c3b596d85168"
}

variable "ssl_policy" {
  description = "SSL policy for the load balancer"
  default     = "ELBSecurityPolicy-TLS13-1-2-FIPS-2023-04"
}