# Minimum test with no optional vars
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
  name        = "${random_string.rstring.result}-test-sg-0"
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

  alb_name        = "${random_string.rstring.result}-test-alb"
  security_groups = "${list(aws_security_group.test_sg.id)}"
  subnets         = "${list(aws_subnet.test_subnet_primary.id, aws_subnet.test_subnet_secondary.id)}"
  vpc_id          = "${aws_vpc.test_vpc.id}"

  create_logging_bucket       = false
  http_listeners_count        = 0
  target_groups_count         = 0
  create_internal_zone_record = false

  internal_record_name    = ""
  internal_zone_name      = ""
  route_53_hosted_zone_id = ""
}
