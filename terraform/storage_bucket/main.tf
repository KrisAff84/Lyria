/* This file configures the bucket used for the 
storage of audio and image files for Lyria. It is
useful to configure the storage bucket separately
so that the same storage bucket can be used during
testing, or when re-deploying the application to a
different environment */

################################################
# Provider Configuration
################################################

provider "aws" {
  region  = "us-east-1"
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
  for_each = aws_s3_bucket.storage_bucket
  bucket   = each.value.bucket
  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowLogging"
        Effect = "Allow"
        Principal = {
          "Service" : "logging.s3.amazonaws.com"
        },
        Action = "s3:PutObject"

        Resource = "${each.value.arn}/*"

      },
      {
        Sid    = "AllowCloudFrontGetObject"
        Effect = "Allow"
        Principal = {
          "Service" : "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${each.value.arn}/*",
        # Condition = {
        #   StringEquals = {
        #     "AWS:SourceArn": var.cloudfront_arn
        #   }
        # }


      }
    ]
  })
}

# Creates Folder for Songs
resource "aws_s3_object" "song_folder" {
  for_each = aws_s3_bucket.storage_bucket
  bucket   = each.value.bucket
  key      = "songs/"
}


#######################################################
# CloudFront Distribution
# For serving audio and image files from storage bucket
#######################################################

resource "aws_cloudfront_distribution" "storage_bucket_distribution" {
  for_each = aws_s3_bucket.storage_bucket
  comment  = "Serves audio and image files from storage bucket"
  origin {
    domain_name = each.value.bucket_regional_domain_name
    origin_id   = each.value.id
  }

  enabled         = true
  is_ipv6_enabled = true

  default_cache_behavior {
    viewer_protocol_policy     = "redirect-to-https"
    allowed_methods            = ["GET", "HEAD", "OPTIONS"]
    cached_methods             = ["GET", "HEAD", "OPTIONS"]
    target_origin_id           = each.value.bucket_regional_domain_name
    cache_policy_id            = var.cache_policy_id
    origin_request_policy_id   = var.origin_request_policy_id
    response_headers_policy_id = var.response_headers_policy_id
    compress                   = true

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    project = var.name_prefix
    use     = "audio_and_image_storage"
    env     = each.key
  }
}