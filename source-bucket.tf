resource "random_id" "source_bucket" {
  byte_length = 4
}

resource "aws_s3_bucket" "source_bucket" {
  bucket = "rails-store-source-${random_id.source_bucket.hex}"

}
resource "aws_s3_bucket_versioning" "source_bucket_versioning" {
  bucket = aws_s3_bucket.source_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}