terraform {
  required_version = "> 0.12"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.48.0"
    }
  }

  backend "s3" {
    bucket = "tf-state-bucket-rate-limiter"
    key    = "state/terraform.tfstate"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
}
