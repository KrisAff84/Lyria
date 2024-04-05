output "elb_dns_name" {
  description = "DNS name of the ELB"
  value       = aws_lb.elb.dns_name
}

output "api_endpoint" {
  description = "API endpoint"
  value       = aws_apigatewayv2_api.lyria.api_endpoint
}