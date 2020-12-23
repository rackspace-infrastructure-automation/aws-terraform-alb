terraform {
  required_version = ">= 0.12"
}

# Test Target Group, Multiple HTTP, Single SSL, CloudWatch
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
  name        = "${random_string.rstring.result}-test-sg-2"
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

resource "aws_route53_zone" "internal_zone" {
  name = "${random_string.rstring.result}.local"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "test01" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[0]
}

resource "aws_instance" "test02" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id     = module.vpc.public_subnets[1]
}

data "aws_acm_certificate" "cert" {
  domain      = "test.mupo181ve1jco37.net"
  most_recent = true
}

module "alb" {
  source = "../../module"

  create_internal_zone_record     = true
  create_logging_bucket           = false
  enable_https_redirect           = true
  http_listeners_count            = 2
  https_listeners_count           = 1
  internal_record_name            = "alb.${aws_route53_zone.internal_zone.name}"
  internal_zone_id                = aws_route53_zone.internal_zone.id
  name                            = "${random_string.rstring.result}-test-alb"
  rackspace_managed               = true
  register_instance_targets_count = 2
  security_groups                 = [aws_security_group.test_sg.id]
  subnets                         = module.vpc.public_subnets
  vpc_id                          = module.vpc.vpc_id

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

  https_listeners = [
    {
      certificate_arn = data.aws_acm_certificate.cert.arn
      port            = 443
    },
  ]

  register_instance_targets = [
    {
      instance_id        = aws_instance.test01.id
      target_group_index = 0
    },
    {
      instance_id        = aws_instance.test02.id
      target_group_index = 0
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
