# IAM Role which IAM Instance profile will use
# This contains the trust policy i.e. who can assume the role and 
# the permissions of the role
resource "aws_iam_role" "session_manager_asg" {
  name                = "session-manager-asg"
  assume_role_policy  = data.aws_iam_policy_document.ec2_assume_role_policy.json
  managed_policy_arns = [aws_iam_policy.session_manager_access.arn]
}

# This will all S3 Full Access
resource "aws_iam_policy" "session_manager_access" {
  name = "sessionmanageraccess"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetEncryptionConfiguration"
        ],
        "Resource" : "*"
      }
    ]
  })
}

# This is the IAM Instance profile which has the role and Autoscaling Configuration Template
# will use this profile
resource "aws_iam_instance_profile" "session_manager_access" {
  name = "session_manager_access"
  role = aws_iam_role.session_manager_asg.name
}
