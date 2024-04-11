variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name_prefix" {
  description = "The prefix name of all resources"
  type        = string
  default     = "lyria"
}

#######################################################
# CloudFront Distribution
#######################################################

variable "cache_policy_id" {
  description = "The ID of the cache policy"
  type        = string
  default     = "658327ea-f89d-4fab-a63d-7e88639e58f6" # CachingOptimized
}

variable "origin_request_policy_id" {
  description = "The ID of the origin request policy"
  type        = string
  default     = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf" # CORS-S3Origin
}

variable "response_headers_policy_id" {
  description = "The ID of the response headers policy"
  type        = string
  default     = "eaab4381-ed33-4a86-88ca-d9558dc6cd63" # CORS-with-preflight-and-SecurityHeadersPolicy
}