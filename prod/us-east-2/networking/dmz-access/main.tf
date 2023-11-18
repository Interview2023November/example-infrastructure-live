data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "app-demo-3-tier-23nov-prod-state"
    key    = "prod/us-east-2/networking/vpc/terraform.tfstate"
    region = "us-east-2"
  }
}

locals {
  name                   = "live-3-tier"
  ssh_port               = 22
  default_lb_target_port = 8080
  lb_port                = 443
  environment            = "prod"
}

resource "aws_security_group" "bastion" {
  name   = "${local.name}-bastion-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.id

  tags = {
    Name        = "${local.name}-bastion-sg"
    Environment = "example"
  }
}

module "bastion" {
  source = "git@github.com:Interview2023November/terraform-aws-modules-general.git//modules/virtual-machines/bastion?ref=v0.1.0"

  name                   = local.name
  ami                    = "ami-0ca34949803acc44e"
  instance_type          = "t3.large"
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = "prod-ssh-key"
  subnet_id              = data.terraform_remote_state.vpc.outputs.dmz_public_subnet_ids[0]
  monitoring             = true

  associate_public_ip_address = true
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_traffic_to_bastion" {
  security_group_id = aws_security_group.bastion.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = local.ssh_port
  ip_protocol = "tcp"
  to_port     = local.ssh_port
}

resource "aws_security_group" "lb" {
  name   = "${local.name}-lb-sg"
  vpc_id = data.terraform_remote_state.vpc.outputs.id

  tags = {
    Name        = "${local.name}-lb-sg"
    Environment = local.environment
  }
}

module "load_balancer" {
  source = "git@github.com:Interview2023November/terraform-aws-modules-general.git//modules/networking/load-balancer?ref=v0.1.0"

  name            = local.name
  environment     = local.environment
  subnets         = data.terraform_remote_state.vpc.outputs.dmz_public_subnet_ids
  vpc_id          = data.terraform_remote_state.vpc.outputs.id
  target_port     = local.default_lb_target_port
  security_groups = [aws_security_group.lb.id]

  certificate_arn = "(REDACTED)"
  zone_id         = "(REDACTED)"
  domain          = "prod.(REDACTED))"
}

resource "aws_vpc_security_group_ingress_rule" "allow_inbound_traffic_to_lb" {
  security_group_id = aws_security_group.lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = local.lb_port
  ip_protocol = "tcp"
  to_port     = local.lb_port
}

module "nat_gateway" {
  source = "git@github.com:Interview2023November/terraform-aws-modules-general.git//modules/networking/nat-gateway?ref=v0.1.0"

  name        = local.name
  environment = local.environment
  subnet_id   = data.terraform_remote_state.vpc.outputs.dmz_public_subnet_ids[0]
}

resource "aws_route" "private_egress" {
  route_table_id         = data.terraform_remote_state.vpc.outputs.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.nat_gateway.id
}
