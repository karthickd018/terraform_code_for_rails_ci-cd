resource "aws_s3_bucket" "artifact_bucket" {
  force_destroy = true
  bucket        = "rails-store-artifacts-karthickcloud"
}
resource "aws_s3_bucket_versioning" "artifact_bucket_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}