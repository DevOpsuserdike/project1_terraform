resource "aws_s3_bucket" "uploadCSVfilebucket" {
  bucket = "uploadCSVfilebucket20260222" # Must be globally unique

  tags = {
    Name        = "uploadCSVfilebucket"
  }
}