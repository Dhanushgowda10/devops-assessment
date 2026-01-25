terraform {
  backend "s3" {
    bucket = "terraform-state123212"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = "us-east-1"
}
