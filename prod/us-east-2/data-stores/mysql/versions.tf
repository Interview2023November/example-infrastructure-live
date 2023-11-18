terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.25"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
