terraform {
  backend "s3" {
    bucket = "app-demo-3-tier-23nov-prod-state"
    key    = "prod/us-east-2/networking/vpc/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "app-demo-3-tier-23nov-prod-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}
