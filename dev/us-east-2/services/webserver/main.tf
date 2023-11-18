data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "app-demo-3-tier-23nov-dev-state"
    key    = "dev/us-east-2/networking/vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "dmz" {
  backend = "s3"

  config = {
    bucket = "app-demo-3-tier-23nov-dev-state"
    key    = "dev/us-east-2/networking/dmz-access/terraform.tfstate"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "data" {
  backend = "s3"

  config = {
    bucket = "app-demo-3-tier-23nov-dev-state"
    key    = "dev/us-east-2/data-stores/mysql/terraform.tfstate"
    region = "us-east-2"
  }
}

locals {
  name           = "live-3-tier"
  db_port        = data.terraform_remote_state.data.outputs.port
  environment    = "dev"
  db_address     = data.terraform_remote_state.data.outputs.address
  db_username    = data.terraform_remote_state.data.outputs.db_username
  db_password    = data.terraform_remote_state.data.outputs.db_password
  webserver_port = 8080
}

resource "aws_security_group" "app" {
  name   = "${local.name}-app-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.id

  tags = {
    Name        = "${local.name}-app-sg"
    Environment = local.environment
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_db_access_from_private_front_end" {
  security_group_id = data.terraform_remote_state.data.outputs.db_security_group_id

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = local.db_port
  ip_protocol                  = "tcp"
  to_port                      = local.db_port
}

resource "aws_vpc_security_group_egress_rule" "allow_private_front_end_access_to_db" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = data.terraform_remote_state.data.outputs.db_security_group_id
  from_port                    = local.db_port
  ip_protocol                  = "tcp"
  to_port                      = local.db_port
}

module "webserver" {
  source = "git@github.com:Interview2023November/terraform-aws-modules-general.git//modules/virtual-machines/webserver?ref=v0.1.0"

  name                   = "${local.name}-webserver"
  ami                    = "ami-0a4a145b049f27673"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app.id]
  key_name               = "dev-ssh-key"
  # Detailed monitoring is not needed in dev
  monitoring = false
  subnet_id  = data.terraform_remote_state.vpc.outputs.front_end_private_subnet_id

  user_data = <<EOF
#!/bin/bash
/home/ubuntu/i_am_a_webserver.sh ${local.db_address} ${local.db_port} ${local.db_username} ${local.db_password}
EOF
}

resource "aws_vpc_security_group_ingress_rule" "allow_webserver_access_from_lb" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = data.terraform_remote_state.dmz.outputs.lb_security_group_id
  from_port                    = local.webserver_port
  ip_protocol                  = "tcp"
  to_port                      = local.webserver_port
}

resource "aws_vpc_security_group_egress_rule" "allow_lb_access_to_webserver" {
  security_group_id = data.terraform_remote_state.dmz.outputs.lb_security_group_id

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = local.webserver_port
  ip_protocol                  = "tcp"
  to_port                      = local.webserver_port
}

resource "aws_vpc_security_group_egress_rule" "allow_webserver_access_to_nat" {
  security_group_id = aws_security_group.app.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_lb_target_group_attachment" "webserver" {
  target_group_arn = data.terraform_remote_state.dmz.outputs.target_group_arn
  target_id        = module.webserver.id
  port             = local.webserver_port
}
