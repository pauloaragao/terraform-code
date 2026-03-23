terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.37.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


resource "aws_cloud9_environment_ec2" "example" {
  instance_type = "t2.micro"
  name          = "example-env"
  region        = "us-east-1"
  image_id      = "amazonlinux-2023-x86_64"
}