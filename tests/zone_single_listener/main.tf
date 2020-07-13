terraform {
  required_version = ">= 0.12"
}

# Test Internal Zone Creation and HTTP Listener
data "aws_availability_zones" "available" {}

provider "aws" {
  version = "~> 2.7"
  region  = "us-west-2"
}

resource "random_string" "rstring" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_security_group" "test_sg" {
  description = "Test SG Group"
  name        = "${random_string.rstring.result}-test-sg-1"
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

  az_count   = 2
  cidr_range = "10.0.0.0/16"
  name       = "${random_string.rstring.result}-test"

  private_cidr_ranges = [
    "10.0.2.0/24",
    "10.0.4.0/24",
  ]

  public_cidr_ranges = [
    "10.0.1.0/24",
    "10.0.3.0/24",
  ]
}

resource "aws_route53_zone" "internal_zone" {
  name = "${random_string.rstring.result}.local"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

module "alb" {
  source = "../../module"

  create_internal_zone_record = true
  create_logging_bucket       = false
  http_listeners_count        = 1
  https_listeners             = []
  https_listeners_count       = 0
  internal_record_name        = "alb.${aws_route53_zone.internal_zone.name}"
  internal_zone_id            = aws_route53_zone.internal_zone.id
  name                        = "${random_string.rstring.result}-test-alb"
  security_groups             = [aws_security_group.test_sg.id]
  subnets                     = module.vpc.public_subnets
  vpc_id                      = module.vpc.vpc_id

  http_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    },
  ]

  tags = {
    LeftSaid  = "George"
    RightSaid = "Fred"
  }

  target_groups = [
    {
      backend_port     = 80
      backend_protocol = "HTTP"
      name             = "${random_string.rstring.result}-ALB-TargetGroup"
    },
  ]
}
