provider "aws" {
  profile = "admin-profile"
  region = "us-east-2"
}

data "aws_lb" "current" {
  name = "${var.name_prefix}-elb"
}
resource "aws_route53_record" "main" {
  zone_id = "Z09206903VMHX9SR3PGQF"
  name    = "meettheafflerbaughs.com"
  type    = "A"

  alias {
    name                   = "dv36pe0g9ao18.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "misspelled" {
  zone_id = "Z06032811HZJPQ3EPMZ6P"
  name    = "meetheafflerbaughs.com"
  type    = "A"

  alias {
    name                   = "dv36pe0g9ao18.cloudfront.net"
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }
}

output "elb_dns" {
  value = data.aws_lb.current.dns_name
}
output "elb_zone_id" {
  value = data.aws_lb.current.zone_id
}

