resource "aws_iam_role_policy_attachment" "lambda_sqs_execution" {
  role       = aws_iam_role.my_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.my_queue.arn
  function_name    = aws_lambda_function.my_lambda2.arn
  
  # Optional: number of messages to send to Lambda in one go (Default: 10)
  batch_size = 10
  
  # Ensure the trigger is active
  enabled = true
}
