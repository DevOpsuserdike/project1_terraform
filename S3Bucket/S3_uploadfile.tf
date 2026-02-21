resource "aws_s3_bucket" "uploadCSVfilebucket" {
  bucket = "uploadCSVfilebucket20260222" # Must be globally unique

  tags = {
    Name        = "uploadCSVfilebucket_terraform"
    
  }
}

output "uploadCSVfilebucketarn" {
  value = aws_s3_bucket.s3jsonuploadbucket.arn
}