output "cloudfront_urls" {
  value = {
    for key, value in aws_cloudfront_distribution.storage_bucket : key => value.domain_name
  }
}