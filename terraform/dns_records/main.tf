provider "aws" {
  region  = "us-east-2"
  profile = "admin-profile"
}


##############################################
# Records for CloudFront to API for Main Site
##############################################

resource "aws_route53_record" "main_A" {
  zone_id = var.zone_id_main
  name    = var.record_name
  type    = "A"

  alias {
    name                   = var.cf_dns_site
    zone_id                = var.cf_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "main_AAAA" {
  zone_id = var.zone_id_main
  name    = var.record_name
  type    = "AAAA"

  alias {
    name                   = var.cf_dns_site
    zone_id                = var.cf_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "misspelled_A" {
  zone_id = var.zone_id_misspelled
  name    = var.record_name_misspelled
  type    = "A"

  alias {
    name                   = var.cf_dns_site
    zone_id                = var.cf_zone_id
    evaluate_target_health = true
  }
}
resource "aws_route53_record" "misspelled_AAAA" {
  zone_id = var.zone_id_misspelled
  name    = var.record_name_misspelled
  type    = "AAAA"

  alias {
    name                   = var.cf_dns_site
    zone_id                = var.cf_zone_id
    evaluate_target_health = true
  }
}

#######################################
# Records for CloudFront to S3 origin
#######################################

# resource "aws_route53_record" "cf_s3_origin_main" {
#   zone_id = var.zone_id_main
#   name    = var.cf_s3_origin_main_name
#   type    = "CNAME"
#   records = [var.cf_s3_origin_main_record]
#   ttl     = var.cf_s3_origin_ttl
# }

# resource "aws_route53_record" "cf_s3_origin_misspelled" {
#   zone_id = var.zone_id_misspelled
#   name    = var.cf_s3_origin_misspelled_name
#   type    = "CNAME"
#   records = [var.cf_s3_origin_misspelled_record]
#   ttl     = var.cf_s3_origin_ttl
# }
