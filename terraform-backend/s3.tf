resource "aws_s3_bucket" "mybucket" {
  bucket = "microsvc-bucket123"
  tags = {
    Name="microsvc-bucket123"
  }
}