variable "aws_profile" {
    description = "AWS profile to use"
    type        = string
    default     = "kris84"
}

variable "aws_region" {
    description = "AWS region to use"
    type        = string
    default     = "us-east-1"
}

variable "table_name" {
    description = "The name of the DynamoDB table"
    type        = string
    default     = "lyria_song_order"
}

variable "billing_mode" {
    description = "The billing mode for the DynamoDB table"
    type        = string
    default     = "PROVISIONED"
}

variable "read_capacity" {
    description = "The read capacity for the DynamoDB table"
    type        = number
    default     = 20
}

variable "write_capacity" {
    description = "The write capacity for the DynamoDB table"
    type        = number
    default     = 20
}

variable "hash_key" {
    description = "The hash key for the DynamoDB table"
    type        = string
    default     = "song_order"
}

variable "hash_key_type" {
    description = "The hash key type for the DynamoDB table"
    type        = string
    default     = "S"
}