resource "aws_sqs_queue" "my_queue" {
  name                      = "my-standard-queue-terraform"
  delay_seconds             = 0        # 0 to 900 seconds
  max_message_size          = 262144   # Bytes (max 256 KiB)
  message_retention_seconds = 345600   # 4 days (up to 14 days)
  receive_wait_time_seconds = 10       # Enables long polling (0 to 20s)
  sqs_managed_sse_enabled   = true     # Enables server-side encryption

  tags = {
    Name = "my-standard-queue-terraform"
  }
}

