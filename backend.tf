terraform {
  backend "s3" {
    bucket         = "cloudcontainer-terraform-state-1a"
    key            = "terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-lock-table"
    profile        = "my-aws-profile"
  }
}
