module "vpc" {
  source = "git@github.com:Interview2023November/terraform-aws-modules-general.git//modules/networking/vpc-3-tier?ref=v0.1.0"

  name        = "live-3-tier"
  environment = "dev"
}
