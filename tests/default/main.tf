terraform {
  required_version = ">= 0.12"
}

# Minimum test with no optional vars
data "aws_availability_zones" "available" {}

provider "aws" {
  version = "~> 3.0"
  region  = "us-west-2"
}

resource "random_string" "rstring" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_security_group" "test_sg" {
  description = "Test SG Group"
  name        = "${random_string.rstring.result}-test-sg-0"
  vpc_id      = module.vpc.vpc_id

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }
}

module "vpc" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=master"

  az_count           = 2
  build_nat_gateways = false
  cidr_range         = "10.0.0.0/16"
  name               = "${random_string.rstring.result}-test"

  private_cidr_ranges = [
    "10.0.2.0/24",
    "10.0.4.0/24",
  ]

  public_cidr_ranges = [
    "10.0.1.0/24",
    "10.0.3.0/24",
  ]
}

module "alb" {
  source = "../../module"

  create_logging_bucket = false
  http_listeners_count  = 0
  name                  = "${random_string.rstring.result}-test-alb"
  rackspace_managed     = true
  security_groups       = [aws_security_group.test_sg.id]
  subnets               = module.vpc.public_subnets
  target_groups_count   = 0
  vpc_id                = module.vpc.vpc_id
}
