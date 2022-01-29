# IAM Role which IAM Instance profile will use
# This contains the trust policy i.e. who can assume the role and 
# the permissions of the role
resource "aws_iam_role" "s3_asg" {
  name                = "s3-asg"
  assume_role_policy  = data.aws_iam_policy_document.ec2_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.s3_full_access.arn]
}

# This will all S3 Full Access
resource "aws_iam_policy" "s3_full_access" {
  name = "s3fullaccess"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

# This is the IAM Instance profile which has the role and Autoscaling Configuration Template
# will use this profile
resource "aws_iam_instance_profile" "s3_access_profile" {
  name = "s3_access_profile"
  role = aws_iam_role.s3_asg.name
}
