# Test Target Group, Multiple HTTP, Single SSL, CloudWatch
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
  name        = "${random_string.rstring.result}-test-sg-2"
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
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=master"
  az_count            = 2
  cidr_range          = "10.0.0.0/16"
  public_cidr_ranges  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_cidr_ranges = ["10.0.2.0/24", "10.0.4.0/24"]
  vpc_name            = "${random_string.rstring.result}-test"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "test01" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${module.vpc.public_subnets[0]}"
}

resource "aws_instance" "test02" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id     = "${module.vpc.public_subnets[1]}"
}

module "alb" {
  source = "../../module"

  # Required
  alb_name        = "${random_string.rstring.result}-test-alb"
  security_groups = "${list(aws_security_group.test_sg.id)}"
  subnets         = "${module.vpc.public_subnets}"
  vpc_id          = "${module.vpc.vpc_id}"

  # Optional
  create_logging_bucket = false

  alb_tags = {
    "RightSaid" = "Fred"
    "LeftSaid"  = "George"
  }

  enable_https_redirect = true
  http_listeners_count  = 2

  http_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    },
    {
      port     = 8080
      protocol = "HTTP"
    },
  ]

  https_listeners_count = 1

  https_listeners = [
    {
      certificate_arn = "arn:aws:acm:us-west-2:891714082543:certificate/9b73ad15-9963-42dd-a0f4-b3679810131b"
      port            = 443
    },
  ]

  rackspace_managed = true

  create_internal_zone_record = true
  internal_record_name        = "alb.mupo181ve1jco37.net"
  route_53_hosted_zone_id     = "Z34VQ0W1VUIFLH"

  register_instance_targets_count = 2

  register_instance_targets = [
    {
      instance_id        = "${aws_instance.test01.id}"
      target_group_index = 0
    },
    {
      instance_id        = "${aws_instance.test02.id}"
      target_group_index = 0
    },
  ]

  target_groups = [{
    "name" = "${random_string.rstring.result}-ALB-TargetGroup"

    "backend_protocol" = "HTTP"

    "backend_port" = 80
  }]
}
