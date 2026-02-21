resource "aws_lambda_permission" "allow_s3_trigger" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda1.lambda1_function
  principal     = "s3.amazonaws.com"
  source_arn    = resource.aws_s3_bucket.uploadCSVfilebucket.output.uploadCSVfilebucketarn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.uploadCSVfilebucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda1.arn
    events              = ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
    
    # Prefix and Suffix filters
    filter_prefix = "newdata"
    filter_suffix = ".csv"
  }

  # Ensure permission is created before the notification
  depends_on = [aws_lambda_permission.allow_s3_trigger]
}

