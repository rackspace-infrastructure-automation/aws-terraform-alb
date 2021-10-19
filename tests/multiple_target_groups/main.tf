# Test Internal Zone Creation and HTTP Listener
data "aws_availability_zones" "available" {}

provider "aws" {
  version = "~> 2.70"
  region  = "us-west-2"
}

resource "random_string" "rstring" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_security_group" "test_sg" {
  name        = "${random_string.rstring.result}-test-sg-1"
  description = "Test SG Group"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "vpc" {
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=tf_v0.11"
  az_count            = 2
  cidr_range          = "10.0.0.0/16"
  public_cidr_ranges  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_cidr_ranges = ["10.0.2.0/24", "10.0.4.0/24"]
  vpc_name            = "${random_string.rstring.result}-test"
}

module "alb" {
  source = "../../module"

  # Required
  alb_name        = "${random_string.rstring.result}-test-alb"
  security_groups = "${list(aws_security_group.test_sg.id)}"
  subnets         = "${module.vpc.public_subnets}"

  vpc_id = "${module.vpc.vpc_id}"

  # Optional
  create_logging_bucket = false

  create_internal_zone_record = true
  internal_record_name        = "alb.mupo181ve1jco37.net"
  route_53_hosted_zone_id     = "Z34VQ0W1VUIFLH"

  alb_tags = {
    "RightSaid" = "Fred"
    "LeftSaid"  = "George"
  }

  http_listeners_count = 1

  http_listeners = [{
    port = 80

    protocol = "HTTP"
  }]

  https_listeners_count = 0
  https_listeners       = []

  target_groups_count = 2

  target_groups = [
    {
      "name"             = "${random_string.rstring.result}-Test-TG1"
      "backend_protocol" = "HTTP"
      "backend_port"     = 80
    },
    {
      "name"             = "${random_string.rstring.result}-Test-TG2"
      "backend_protocol" = "HTTP"
      "backend_port"     = 80
    },
  ]
}
