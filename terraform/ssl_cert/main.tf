/*
This file configures the necessary SSL certificate to use with 
the load balancer and CloudFront distribution.
*/

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_acm_certificate" "ssl" {
  domain_name               = var.domain_name
  subject_alternative_names = var.alternate_domains
  validation_method         = "DNS"
  key_algorithm             = var.key_algorithm

  tags = {
    Name    = "SSL Certificate"
    Project = "Lyria"
    Use     = "Load Balancer and CloudFront Distribution"
  }
}

resource "aws_acm_certificate_validation" "ssl" {
  certificate_arn = aws_acm_certificate.ssl.arn
}