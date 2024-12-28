locals {
    vpc_endpoint_configuration = {
        s3 = {
            service_name = "com.amazonaws.${var.aws_region}.s3",
            name_tag = "${var.name_prefix}-bucket-endpoint"
        },
        dynamodb = {
            service_name = "com.amazonaws.${var.aws_region}.dynamodb",
            name_tag = "${var.name_prefix}-dynamodb-endpoint"
        }
    }
}