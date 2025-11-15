terraform {
  backend "s3" {
    bucket = "tf-3tier-state-bucket"
    key = "production/terraform.tf-state"
    region = "ap-south-1"
    encrypt = true
    dynamodb_table = "terraform-state-lock"
  }
}