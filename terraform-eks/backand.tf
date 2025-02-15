terraform {
  backend "s3" {
    name = "dev-region1-terrafrom-state-file"
    region = "ap-southeast-1"
    key = "terraform-module/region1/terraform.state"
    dynamodb_table = "dev-terraform-lock-region1"
    encrypt = true

  }

  required_providers {
    aws = {
        source = "hasicorp/aws"
        version = "~>5.0"
    }
  }
}