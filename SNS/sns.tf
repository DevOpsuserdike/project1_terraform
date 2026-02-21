resource "aws_sns_topic" "sns-topic" {
  name = "user-topic-terraform" # Replace with your desired topic name
}

# Subscribe an email endpoint to the SNS topic
resource "aws_sns_topic_subscription" "user_updates_email_sub" {
  topic_arn = aws_sns_topic.sns-topic.sns_topic_arn
  protocol  = "email"
  endpoint  = "dikesiddheshcoep14@gmail.com"
}

# Output the SNS topic ARN
output "sns_topic_arn" {
  value = aws_sns_topic.sns-topic.arn
}
