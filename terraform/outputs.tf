output "elb_dns_name" {
  description = "DNS name of the ELB"
  value       = aws_lb.elb.dns_name
}