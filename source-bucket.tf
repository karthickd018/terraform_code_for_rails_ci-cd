resource "aws_s3_bucket" "source_bucket" {
  force_destroy = true
  bucket        = "rails-store-source-karthickcloud"

}
resource "aws_s3_bucket_versioning" "source_bucket_versioning" {
  bucket = aws_s3_bucket.source_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}