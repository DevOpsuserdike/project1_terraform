resource "aws_s3_bucket" "s3jsonuploadbucket" {
  bucket = "s3jsonuploadbucket20260222"

  tags = {
    Name = "s3jsonuploadbucket_terraform"
  }
}