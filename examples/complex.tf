terraform {
  required_version = ">= 0.12"
}

/*
ALB with multiple listeners, target groups, and listener rules routing requests to a listener to different
target groups based on path and host header.
*/

# Test Internal Zone Creation and HTTP Listener
data "aws_availability_zones" "available" {}

provider "aws" {
  version = "~> 2.0"
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
  vpc_id      = module.vpc.vpc_id

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
  source              = "git@github.com:rackspace-infrastructure-automation/aws-terraform-vpc_basenetwork//?ref=v0.0.9"
  az_count            = 2
  cidr_range          = "10.0.0.0/16"
  public_cidr_ranges  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_cidr_ranges = ["10.0.2.0/24", "10.0.4.0/24"]
  vpc_name            = "${random_string.rstring.result}-test"
}

module "alb" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-alb//?ref=v0.0.11"

  # Required
  alb_name        = "${random_string.rstring.result}-test-alb"
  security_groups = [aws_security_group.test_sg.id]
  subnets         = module.vpc.public_subnets

  vpc_id = module.vpc.vpc_id

  # Optional
  create_logging_bucket = false

  create_internal_zone_record = true
  internal_record_name        = "alb.mupo181ve1jco37.net"
  route_53_hosted_zone_id     = "Z34VQ0W1VUIFLH"

  alb_tags = {
    "RightSaid" = "Fred"
    "LeftSaid"  = "George"
  }

  http_listeners_count = 2

  http_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
    {
      port               = 8080
      protocol           = "HTTP"
      target_group_index = 1
    },
  ]

  https_listeners_count = 2

  //  SSL Policies - https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-https-listener.html#describe-ssl-policies
  https_listeners = [
    {
      port               = 443
      certificate_arn    = "arn:aws:acm:us-west-2:123456789012:certificate/12345678-1234-1234-1234-123456789012"
      ssl_policy         = "ELBSecurityPolicy-2016-08"
      target_group_index = 2
    },
    {
      port               = 8443
      certificate_arn    = "arn:aws:acm:us-west-2:123456789012:certificate/12345678-00000-32444-9999-45678901233"
      ssl_policy         = "ELBSecurityPolicy-TLS"
      target_group_index = 3
    },
  ]

  target_groups_count = 4

  target_groups = [
    {
      "name"              = "ComplexTargetGroup0"
      "backend_protocol"  = "HTTP"
      "backend_port"      = 80
      "health_check_path" = "/ui"
    },
    {
      "name"                             = "ComplexTargetGroup1"
      "backend_protocol"                 = "HTTP"
      "backend_port"                     = 8080
      "health_check_matcher"             = "200-299"
      "health_check_timeout"             = 4
      "health_check_unhealthy_threshold" = 2
      "stickiness_enabled"               = false
      "health_check_path"                = "/new_ui"
    },
    {
      "name"              = "ComplexTargetGroup2"
      "backend_protocol"  = "HTTPS"
      "backend_port"      = 443
      "health_check_path" = "/admin"
    },
    {
      "name"              = "ComplexTargetGroup3"
      "backend_protocol"  = "HTTPS"
      "backend_port"      = 8443
      "health_check_path" = "/new_admin"
    },
  ]
}

# Define rules
# https://www.terraform.io/docs/providers/aws/r/lb_listener_rule.html
resource "aws_lb_listener_rule" "host_based_routing" {
  listener_arn = element(module.alb.http_tcp_listener_arns, 0)
  priority     = 99

  action {
    type             = "forward"
    target_group_arn = element(module.alb.target_group_arns, 0)
  }

  condition {
    field  = "host-header"
    values = ["my-service.*.terraform.io"]
  }
}

resource "aws_lb_listener_rule" "path_based_routing" {
  listener_arn = element(module.alb.https_listener_arns, 1)
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = element(module.alb.target_group_arns, 3)
  }

  condition {
    field  = "path-pattern"
    values = ["/static/*"]
  }
}

