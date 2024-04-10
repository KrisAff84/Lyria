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

resource "aws_s3_object" "song_folder" {
  for_each = aws_s3_bucket.storage_bucket
  bucket   = each.value.bucket
  key      = "songs/"
}
