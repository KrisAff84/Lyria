variable "name_prefix" {
  description = "Naming prefix of current elb"
  default     = "lyria-green"
}

variable "zone_id_main" {
  description = "Route53 zone ID for main domain"
  default     = "Z09206903VMHX9SR3PGQF"
}

variable "zone_id_misspelled" {
  description = "Route53 zone ID for misspelled domain"
  default     = "Z06032811HZJPQ3EPMZ6P"
}

variable "A_record_name" {
  description = "Name of the A record"
  default     = "meettheafflerbaughs.com"
}

variable "A_record_name_misspelled" {
  description = "Name of the A record for the misspelled domain"
  default     = "meetheafflerbaughs.com"
}

variable "cf_s3_origin_main_name" {
  description = "Name of the CloudFront to S3 origin record for the main domain"
  default     = "_7712d544302839ae72944da8902036a5.meettheafflerbaughs.com"
}

variable "cf_s3_origin_misspelled_name" {
  description = "Name of the CloudFront to S3 origin record for the misspelled domain"
  default     = "_a6cf547631e0295dbcb4dfb53dcb2d84.meetheafflerbaughs.com"
}

variable "cf_s3_origin_main_record" {
  description = "Record for the CloudFront to S3 origin for the main domain"
  default     = "_5eabf0c387b879db1720051c2e611680.mhbtsbpdnt.acm-validations.aws"
}

variable "cf_s3_origin_misspelled_record" {
  description = "Record for the CloudFront to S3 origin for the misspelled domain"
  default     = "_cdbb2f322a273066b96e5b0de517fed0.mhbtsbpdnt.acm-validations.aws"
}

variable "cf_s3_origin_ttl" {
  description = "TTL for the CloudFront to S3 origin records"
  default     = "604800"
}