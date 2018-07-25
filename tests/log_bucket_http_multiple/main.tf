# Test S3 Log Bucket Creation and HTTP Listener
data "aws_availability_zones" "available" {}

provider "aws" {
  version = "~> 1.2"
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
  vpc_id      = "${aws_vpc.test_vpc.id}"

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

resource "aws_subnet" "test_subnet_primary" {
  cidr_block        = "10.0.1.0/24"
  vpc_id            = "${aws_vpc.test_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
}

resource "aws_subnet" "test_subnet_secondary" {
  cidr_block        = "10.0.2.0/24"
  vpc_id            = "${aws_vpc.test_vpc.id}"
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
}

resource "aws_vpc" "test_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "test_gw" {
  vpc_id = "${aws_vpc.test_vpc.id}"
}

module "alb" {
  source = "../../module"

  # Required
  alb_name        = "${random_string.rstring.result}-test-alb"
  security_groups = "${list(aws_security_group.test_sg.id)}"
  subnets         = "${list(aws_subnet.test_subnet_primary.id, aws_subnet.test_subnet_secondary.id)}"

  vpc_id = "${aws_vpc.test_vpc.id}"

  # Optional
  create_logging_bucket = false

  internal_zone_name   = "dev.mupo181ve1jco37.net"
  internal_record_name = "alb.mupo181ve1jco37.net"

  route_53_hosted_zone_id = "Z34VQ0W1VUIFLH"

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

  target_groups = [{
    "name" = "${random_string.rstring.result}-ALB-TargetGroup"

    "backend_protocol" = "HTTP"

    "backend_port" = 80
  }]
}
