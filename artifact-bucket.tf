resource "random_id" "artifact_bucket" {
  byte_length = 4
}

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "rails-store-artifacts-${random_id.artifact_bucket.hex}"
}
resource "aws_s3_bucket_versioning" "artifact_bucket_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}