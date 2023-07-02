provider "aws" {
  region = "us-east-1"
}

# plan
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "my-s3-bucket-martut-02"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.my_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_iam_user" "my_iam_user" {
  name = "my_iam_user_abc_updated"
}