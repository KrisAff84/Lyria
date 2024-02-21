####### Need to add data source for current ELB ##########

resource "aws_route53_record" "main" {
  zone_id = "Z09206903VMHX9SR3PGQF"
  name    = "meettheafflerbaughs.com"
  type    = "A"

  alias {
    name                   = aws_lb.elb.dns_name
    zone_id                = aws_lb.elb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "misspelled" {
  zone_id = "Z06032811HZJPQ3EPMZ6P"
  name    = "meetheafflerbaughs.com"
  type    = "A"

  alias {
    name                   = aws_lb.elb.dns_name
    zone_id                = aws_lb.elb.zone_id
    evaluate_target_health = true
  }
}