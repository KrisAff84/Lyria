/* 
Creates necessary credentials for CI/CD pipeline:
- IAM user
- IAM policy
- IAM user policy attachment
- IAM access key
*/

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
resource "aws_iam_user" "lyria_dev" {
  name = "lyria_dev"
}

resource "aws_iam_policy" "lyria_dev_policy" {
  name        = "lyria_dev_policy"
  description = "Provides necessary permissions for CI/CD pipeline to manage instances and images"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "ec2:StartInstances",
          "ec2:CreateTags",
          "ec2:CreateImage",
          "ec2:StopInstances"
        ],
        "Resource" : [
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:instance/${var.aws_instance_id}"
        ]
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : [
          "ec2:DetachVolume",
          "ec2:DescribeImages",
          "ec2:DeleteVolume",
          "ec2:DeregisterImage",
          "ec2:DescribeInstances",
          "ec2:DeleteSnapshot",
          "ec2:CreateTags",
          "ec2:CreateImage",
          "ec2:DescribeInstanceStatus"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "VisualEditor2",
        "Effect" : "Allow",
        "Action" : "ec2:DescribeInstanceStatus",
        "Resource" : [
          "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:instance/${var.aws_instance_id}"
        ]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.lyria_dev.name
  policy_arn = aws_iam_policy.lyria_dev_policy.arn
}

resource "aws_iam_access_key" "lyria_dev" {
  user = aws_iam_user.lyria_dev.name
}

resource "local_file" "access_key" {
  filename = "access_key.txt"
  content = jsonencode({
    "access_key_id" : "${aws_iam_access_key.lyria_dev.id}",
    "secret_access_key" : "${aws_iam_access_key.lyria_dev.secret}"
  })
  file_permission = "0600"
}