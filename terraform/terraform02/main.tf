variable "iam_user_name_prefix" {
  default = "my_iam_user"
  type = string # any number bool list map set object tuple
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "my_iam_users" {
  count = 1
  name  = "${var.iam_user_name_prefix}_${count.index}"
}