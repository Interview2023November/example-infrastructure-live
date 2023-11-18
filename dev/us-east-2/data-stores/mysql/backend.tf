terraform {
  backend "s3" {
    bucket = "app-demo-3-tier-23nov-dev-state"
    key    = "dev/us-east-2/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "app-demo-3-tier-23nov-dev-state-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-2"
}
