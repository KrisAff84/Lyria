output "elb_dns_name" {
  description = "DNS name of the ELB"
  value       = aws_lb.elb.dns_name
}

output "api_endpoint" {
  description = "API endpoint"
  value       = aws_apigatewayv2_api.lyria.api_endpoint
}

output "cloudfront_url" {
  description = "Cloudfront URL for the main site"
  value       = aws_cloudfront_distribution.api.domain_name
}

output "cloudfront_zone_id" {
  description = "Cloudfront zone ID for main site"
  value       = aws_cloudfront_distribution.api.hosted_zone_id
}