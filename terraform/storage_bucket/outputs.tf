output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.storage_bucket.domain_name
}