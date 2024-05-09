/* 
This file configures the buckets and CloudFront distributions used for the 
storage of audio and image files for Lyria. It is useful to configure the 
storage buckets separately from the rest of the infrastructure so that the 
same storage buckets can be used during development, or when re-deploying 
the application to a different environment. 
*/

################################################
# Provider Configuration
################################################

provider "aws" {
  region  = var.aws_region
  profile = "kris84"
}

################################################
# S3 Bucket
################################################

resource "aws_s3_bucket" "storage_bucket" {
  for_each      = toset(["dev", "prod"])
  force_destroy = false
  bucket        = "${var.name_prefix}-storage-2024-${each.key}"
  tags = {
    project = var.name_prefix
    use     = "audio_and_image_storage"
    env     = each.key
  }
}

resource "aws_s3_bucket_public_access_block" "storage_bucket_public_access_block" {
  for_each                = aws_s3_bucket.storage_bucket
  bucket                  = each.value.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "storage_bucket_policy" {
  for_each   = aws_s3_bucket.storage_bucket
  bucket     = each.value.bucket
  depends_on = [aws_cloudfront_distribution.storage_bucket]
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "PolicyForLoggingAndCloudFront",

    Statement = [
      {
        Sid    = "AllowLogging",
        Effect = "Allow",
        Principal = {
          "Service" : "logging.s3.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${each.value.arn}/*"
      },
      {
        Sid    = "AllowCloudFrontGetObject",
        Effect = "Allow",
        Principal = {
          "Service" : "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${each.value.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" : [
              "${aws_cloudfront_distribution.storage_bucket.arn}"
            ]
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_logging" "storage_bucket_logging" {
  for_each      = aws_s3_bucket.storage_bucket
  bucket        = each.value.bucket
  target_bucket = var.log_bucket
  target_prefix = "${element(split("_", each.key), 3)}_storage_bucket_server_access"
  target_object_key_format {
    partitioned_prefix {
      partition_date_source = "EventTime"
    }
  }
}

# Creates Folder Structure
resource "aws_s3_object" "prod_folder_structure" {
  bucket = aws_s3_bucket.storage_bucket["prod"].bucket
  key    = "songs/"
}

resource "aws_s3_object" "dev_folder_structure" {
  bucket = aws_s3_bucket.storage_bucket["dev"].bucket
  key    = "dev/songs/"
}


#######################################################
# CloudFront Distribution
# For serving audio and image files from storage bucket
#######################################################

resource "aws_cloudfront_origin_access_control" "storage_bucket" {
  for_each                          = aws_s3_bucket.storage_bucket
  name                              = "storage_bucket_oac_${each.key}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "storage_bucket" {
  comment         = "Serves audio and image files from storage buckets"
  price_class     = "PriceClass_All"
  http_version    = "http2and3"
  enabled         = true
  is_ipv6_enabled = true
  origin {
    domain_name              = aws_s3_bucket.storage_bucket["dev"].bucket_regional_domain_name
    origin_id                = "dev"
    origin_access_control_id = aws_cloudfront_origin_access_control.storage_bucket["dev"].id
    origin_path              = ""
  }
  origin {
    domain_name              = aws_s3_bucket.storage_bucket["prod"].bucket_regional_domain_name
    origin_id                = "prod"
    origin_access_control_id = aws_cloudfront_origin_access_control.storage_bucket["prod"].id
    origin_path              = ""
  }
  default_cache_behavior {
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    target_origin_id           = "prod"
    cache_policy_id            = var.cache_policy_id
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    compress                   = true
  }
  ordered_cache_behavior {
    path_pattern               = "/dev/*"
    target_origin_id           = "dev"
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    cache_policy_id            = var.cache_policy_id
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    compress                   = true
  }
  logging_config {
    bucket          = var.log_bucket_endpoint
    include_cookies = false
    prefix          = "cloudfront-files"
  }

  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    project = var.name_prefix
    use     = "bucket_objects"
  }
}
