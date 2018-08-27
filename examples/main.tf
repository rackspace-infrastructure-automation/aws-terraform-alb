provider "aws" {
  version = "~> 1.2"
  region  = "us-west-2"
}

module "alb" {
  source = "git@github.com/rackspace-infrastructure-automation/aws-terraform-alb//?ref=v0.0.1"

  #################
  #      ALB      #
  #################

  alb_name = "ALB Name"
  alb_tags = {
    RightSaid = "Fred"
    LeftSaid  = "George"
  }
  enable_deletion_protection = false
  environment                = "Staging"
  extra_ssl_certs_count      = 3
  extra_ssl_certs = [{
    certificate_arn      = "arn:aws:acm:<region>:<account>:certificate/<uuid>"
    https_listener_index = 0
  },
    {
      certificate_arn      = "arn:aws:acm:<region>:<account>:certificate/<uuid>"
      https_listener_index = 0
    },
    {
      certificate_arn      = "arn:aws:acm:<region>:<account>:certificate/<uuid>"
      https_listener_index = 0
    },
  ]
  http_listeners_count = 2
  http_listeners = [{
    port = 80

    protocol = "HTTP"
  },
    {
      port     = 8080
      protocol = "HTTP"
    },
  ]
  https_listeners_count = 1
  https_listeners = [{
    port            = 443
    certificate_arn = "arn:aws:acm:<region>:<account>:certificate/<uuid>"
  }]
  idle_timeout                    = 60
  security_groups                 = ["sg-<uuid>"]
  load_balancer_is_internal       = false
  register_instance_targets_count = 2
  register_instance_targets = [{
    "instance_id" = "i-<uuid>"

    "target_group_index" = 0
  },
    {
      "instance_id" = "i-<uuid>"

      "target_group_index" = 0
    },
  ]
  subnets             = ["subnet-<uuid>", "subnet-<uuid>"]
  target_groups_count = 1
  target_groups = [{
    "name" = "NewALB-TG"

    "backend_protocol" = "HTTP"

    "backend_port" = 80
  }]
  vpc_id = "vpc-<uuid>"

  #################
  #  CloudWatch   #
  #################

  rackspace_managed = true

  #################
  #   Route 53    #
  #################

  internal_record_name    = "alb.example.com"
  internal_zone_name      = "dev.example.com"
  route_53_hosted_zone_id = "<zone_id>"

  #################
  #      S3       #
  #################

  create_logging_bucket                   = true
  logging_bucket_acl                      = "bucket-owner-full-control"
  logging_bucket_encyption                = "AES256"
  logging_bucket_encryption_kms_mster_key = ""
  logging_bucket_name                     = "<bucket_name>"
  logging_bucket_retention                = 14
  #################
  #      WAF      #
  #################
  add_waf = true
  waf_id = "<waf_id>"
}
