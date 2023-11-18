data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "app-demo-3-tier-23nov-prod-state"
    key    = "prod/us-east-2/networking/vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

locals {
  name        = "live-3-tier"
  db_port     = 3306
  environment = "prod"
  db_name     = "prod_database"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${local.name}-db-subnets"
  subnet_ids = data.terraform_remote_state.vpc.outputs.back_end_private_subnet_ids

  tags = {
    Name        = "${local.name}-db-subnets"
    Environment = local.environment
  }
}

resource "random_string" "username" {
  length  = 16
  special = false
}

resource "random_password" "password" {
  length = 16
}

resource "aws_security_group" "db" {
  name   = "${local.name}-db-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.id

  tags = {
    Name        = "${local.name}-db-sg"
    Environment = local.environment
  }
}

module "database_server" {
  source = "git@github.com:Interview2023November/terraform-aws-modules-general.git//modules/data-stores/mysql?ref=v0.1.0"

  name                   = "${local.name}-db"
  db_username            = random_string.username.result
  db_password            = random_password.password.result
  db_name                = local.db_name
  instance_class         = "db.t2.large"
  port                   = local.db_port
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.db.id]
}

resource "aws_vpc_security_group_egress_rule" "allow_db_access_to_nat" {
  security_group_id = aws_security_group.db.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
