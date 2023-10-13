provider "aws" {
  region = "us-east-1"
}

//s3 bucket
resource "aws_s3_bucket" "enterprise_backend_state" {
  bucket = "application-name-backend-state-martut"
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enterprise_versioning" {
  bucket = aws_s3_bucket.enterprise_backend_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enterprise_encryption" {
  bucket = aws_s3_bucket.enterprise_backend_state.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

//locking -dynamo db

resource "aws_dynamodb_table" "enterprise_backend_lock" {
  name = "dev_app_locks"
  billing_mode = "PAY_PER_REQUEST"
  
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}

