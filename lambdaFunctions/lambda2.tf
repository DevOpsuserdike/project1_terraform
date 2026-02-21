resource "aws_iam_role" "lambda2_exec" {
  name = "lambda2_role_terraform"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

locals {
  managed_policies = [
    "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
    "arn:aws:iam::aws:policy/AmazonSQSReadOnlyAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole",
    "arn:aws:iam::aws:policy/AmazonSSMFullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
  ]
}

resource "aws_iam_role_policy_attachment" "attachments" {
  for_each   = toset(local.managed_policies)
  role       = aws_iam_role.lambda2_exec.lambda2_role_terraform
  policy_arn = each.value
}


# Attach basic execution policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "lambda2_logs" {
  role       = aws_iam_role.lambda2_exec.lambda2_role_terraform
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "custom_json_policy" {
  name = "custom-lambda-ssm-sqs-policy"
  role       = aws_iam_role.lambda2_exec.lambda2_role_terraform

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:us-west-2:800762100652:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-west-2:800762100652:log-group:/aws/lambda/lambda2:*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sqs:ReceiveMessage",
                "sqs:DeleteMessage",
                "sqs:GetQueueAttributes"
            ],
            "Resource": "arn:aws:sqs:us-west-2:800762100652:sqs"
        },
        {
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": "arn:aws:sns:us-west-2:800762100652:topic1"
        },
        {
            "Effect": "Allow",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::s3-json-receive/sqs-messages/*.json"
        }
    ]
})
}


data "archive_file" "lambda2_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda2_function.py"
  output_path = "${path.module}/lambda2_function_payload.zip"
}

resource "aws_lambda_function" "my_lambda2" {
  filename      = data.archive_file.lambda2_zip.output_path
  function_name = "lambda2_function"
  role          = aws_iam_role.lambda2_exec.arn
  handler       = "index.handler"
  runtime       = "python3.12"

  # This triggers a redeploy if the code's hash changes
  source_code_hash = data.archive_file.lambda2_zip.output_base64sha256
}

