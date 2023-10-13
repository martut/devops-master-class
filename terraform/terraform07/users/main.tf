variable app_name {
  default = "app-dev-users"
}

terraform {
  backend "s3" {
    bucket = "application-name-backend-state-martut"
    #key = "app-dev-users"
    key = "dev/app/users/backend_state"
    region = "us-east-1"
    dynamodb_table = "dev_app_locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "my_iam_user" {
  name = "${terraform.workspace}_my_iam_user_abc"
}