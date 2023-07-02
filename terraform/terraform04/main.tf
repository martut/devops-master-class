variable "users" {
  default = {
    ravel : { country : "NL", department : "ABC" },
    tom : { country : "USA", department : "QWE" },
    marcin : { country : "Poland", department : "ASD" },
  }
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_user" "my_iam_users" {
  for_each = var.users
  name     = each.key
  tags = {
    #    country: each.value
    country : each.value.country
    department : each.value.department
  }
}