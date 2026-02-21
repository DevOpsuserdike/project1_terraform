resource "aws_iam_role" "ssm_s3_role" {
  name = "SSM-S3-Access-Role-toec2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

locals {
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
}

resource "aws_iam_role_policy_attachment" "role_attachments" {
  for_each   = toset(local.policy_arns)
  role       = aws_iam_role.ssm_s3_role.SSM-S3-Access-Role-toec2
  policy_arn = each.value
}


resource "aws_iam_instance_profile" "ec2_profile" {
  name = "my-ec2-instance-profile"
  role = aws_iam_role.ssm_s3_role.SSM-S3-Access-Role-toec2
}
