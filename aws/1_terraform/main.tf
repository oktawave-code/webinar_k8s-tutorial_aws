terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
    kubernetes = {
      version = ">= 1.11"
    }
  }

  backend "s3" {
    bucket = "2terraform"
    key    = "tf.state"
    region = "us-east-2"
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region = "us-east-2"
}
