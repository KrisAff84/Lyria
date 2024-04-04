provider "aws" {
  region  = "us-east-2"
  profile = "admin-profile"
}


#######################################
# Records for ELB
#######################################

data "aws_lb" "current" {
  name = "${var.name_prefix}-elb"
}
resource "aws_route53_record" "main" {
  zone_id = var.zone_id_main
  name    = var.A_record_name
  type    = "A"

  alias {
    name                   = data.aws_lb.current.dns_name
    zone_id                = data.aws_lb.current.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "misspelled" {
  zone_id = var.zone_id_misspelled
  name    = var.A_record_name_misspelled
  type    = "A"

  alias {
    name                   = data.aws_lb.current.dns_name
    zone_id                = data.aws_lb.current.zone_id
    evaluate_target_health = true
  }
}

#######################################
# Records for CloudFront to S3 origin
#######################################

resource "aws_route53_record" "cf_s3_origin_main" {
  zone_id = var.zone_id_main
  name    = var.cf_s3_origin_main_name
  type    = "CNAME"
  records = [var.cf_s3_origin_main_record]
  ttl     = var.cf_s3_origin_ttl
}

resource "aws_route53_record" "cf_s3_origin_misspelled" {
  zone_id = var.zone_id_misspelled
  name    = var.cf_s3_origin_misspelled_name
  type    = "CNAME"
  records = [var.cf_s3_origin_misspelled_record]
  ttl     = var.cf_s3_origin_ttl
}

#######################################
# Outputs
#######################################

output "elb_dns" {
  value = data.aws_lb.current.dns_name
}
output "elb_zone_id" {
  value = data.aws_lb.current.zone_id
}
