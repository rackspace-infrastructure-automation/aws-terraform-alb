/**
 * # aws-terraform-alb
 *This module deploys an Application Load Balancer with associated resources, such as an unhealthy host count CloudWatch alarm, S3 log bucket, and Route 53 internal zone record.
 *
 *## Basic Usage
 *
 *```
 *module "alb" {
 *  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-alb//?ref=v0.0.9"
 *
 *  alb_name        = "MyALB"
 *  security_groups = ["${module.sg.public_web_security_group_id}"]
 *  subnets         = ["${module.vpc.public_subnets}"]
 *  vpc_id          = "${module.vpc.vpc_id}"
 *
 *  http_listeners_count = 1
 *
 *  http_listeners = [{
 *    port     = 80
 *    protocol = "HTTP"
 *  }]
 *
 *  target_groups_count = 1
 *
 *  target_groups = [{
 *    "name"             = "MyTargetGroup"
 *    "backend_protocol" = "HTTP"
 *    "backend_port"     = 80
 *  }]*
 *}
 *```
 *
 * Full working references are available at [examples](examples)
 *
 */

data "aws_elb_service_account" "main" {}

locals {
  env_list = ["Development", "Integration", "PreProduction", "Production", "QA", "Staging", "Test"]
  acl_list = ["authenticated-read", "aws-exec-read", "bucket-owner-read", "bucket-owner-full-control", "log-delivery-write", "private", "public-read", "public-read-write"]

  bucket_acl  = "${contains(local.acl_list, var.logging_bucket_acl) ? var.logging_bucket_acl:"bucket-owner-full-control"}"
  environment = "${contains(local.env_list, var.environment) ? var.environment:"Development"}"

  default_tags = {
    ServiceProvider = "Rackspace"
    Environment     = "${local.environment}"
  }

  merged_tags = "${merge(local.default_tags, var.alb_tags)}"

  enable_https_redirect = "${var.http_listeners_count > 0 && var.https_listeners_count > 0 && var.enable_https_redirect}"
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "3.5.0"

  # Required values
  load_balancer_name = "${var.alb_name}"
  security_groups    = "${var.security_groups}"
  subnets            = "${var.subnets}"
  vpc_id             = "${var.vpc_id}"

  # Optional Values
  logging_enabled          = "${var.create_logging_bucket || var.logging_bucket_name != "" ? true:false}"
  log_bucket_name          = "${var.create_logging_bucket ? element(concat(aws_s3_bucket_policy.log_bucket_policy.*.bucket, list("")), 0):var.logging_bucket_name}"
  log_location_prefix      = "${var.logging_bucket_prefix}"
  http_tcp_listeners_count = "${var.http_listeners_count}"
  http_tcp_listeners       = "${var.http_listeners}"
  https_listeners_count    = "${var.https_listeners_count}"
  https_listeners          = "${var.https_listeners}"
  target_groups_count      = "${var.target_groups_count}"
  target_groups            = "${var.target_groups}"
  target_groups_defaults   = "${var.target_groups_defaults}"
  enable_http2             = "${var.enable_http2}"

  enable_deletion_protection = "${var.enable_deletion_protection}"
  load_balancer_is_internal  = "${var.load_balancer_is_internal}"

  extra_ssl_certs_count       = "${var.extra_ssl_certs_count}"
  extra_ssl_certs             = "${var.extra_ssl_certs}"
  idle_timeout                = "${var.idle_timeout}"
  listener_ssl_policy_default = "ELBSecurityPolicy-TLS-1-2-2017-01"

  tags = "${local.merged_tags}"
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count        = "${local.enable_https_redirect ? var.http_listeners_count : 0}"
  listener_arn = "${element(module.alb.http_tcp_listener_arns, count.index)}"

  action {
    type = "redirect"

    redirect {
      port        = "${lookup(var.https_listeners[0], "port")}"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "path-pattern"
    values = ["*"]
  }
}

# create s3 bucket if needed
resource "aws_s3_bucket" "log_bucket" {
  count  = "${var.create_logging_bucket ? 1:0}"
  bucket = "${var.logging_bucket_name}"
  acl    = "${local.bucket_acl}"

  force_destroy = "${var.logging_bucket_force_destroy}"

  tags = "${local.merged_tags}"

  server_side_encryption_configuration {
    "rule" {
      "apply_server_side_encryption_by_default" {
        kms_master_key_id = "${var.logging_bucket_encryption_kms_mster_key}"
        sse_algorithm     = "${var.logging_bucket_encyption}"
      }
    }
  }

  #lifecycle_rule {
   # enabled                                = "${var.life_cycle_rule_enabled}"
   # abort_incomplete_multipart_upload_days = "${var.abort_incomplete_multipart_upload_days_count}"
   # prefix                                 = "${var.logging_bucket_prefix}"

   # expiration {
    #  days = "${var.logging_bucket_retention}"
   # }
 # }
  lifecycle_rule = [ "${var.lifecycle_rules}" ]
}

# s3 policy needs to be separate since you can't reference the bucket for the reference.
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  count  = "${var.create_logging_bucket ? 1:0}"
  bucket = "${aws_s3_bucket.log_bucket.id}"

  policy = <<POLICY
{
  "Id": "Policy1529427095432",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "Stmt1529427092463",
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.log_bucket.arn}/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
POLICY
}

# create r53 record with alias
resource "aws_route53_record" "zone_record_alias" {
  count   = "${var.create_internal_zone_record ? 1:0}"
  name    = "${var.internal_record_name}"
  type    = "A"
  zone_id = "${var.route_53_hosted_zone_id}"

  alias {
    evaluate_target_health = true
    name                   = "${module.alb.dns_name}"
    zone_id                = "${module.alb.load_balancer_zone_id}"
  }
}

# enable cloudwatch/RS ticket creation
data "null_data_source" "alarm_dimensions" {
  count = "${var.target_groups_count > 0 ? var.target_groups_count:0}"

  inputs = {
    LoadBalancer = "${element(list(module.alb.load_balancer_arn_suffix), count.index)}"
    TargetGroup  = "${element(module.alb.target_group_arn_suffixes, count.index)}"
  }
}

module "unhealthy_host_count_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.0.1"

  alarm_count              = "${var.target_groups_count > 0 ? var.target_groups_count:0}"
  alarm_description        = "Unhealthy Host count is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.alb_name}_unhealthy_host_count_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = "${data.null_data_source.alarm_dimensions.*.outputs}"
  evaluation_periods       = 10
  metric_name              = "UnHealthyHostCount"
  namespace                = "AWS/ApplicationELB"
  notification_topic       = "${var.notification_topic}"
  period                   = 60
  rackspace_alarms_enabled = "${var.rackspace_alarms_enabled}"
  rackspace_managed        = "${var.rackspace_managed}"
  severity                 = "emergency"
  statistic                = "Maximum"
  threshold                = 1
  unit                     = "Count"
}

# join ec2 instances to target group
resource "aws_lb_target_group_attachment" "target_group_instance" {
  count = "${var.register_instance_targets_count > 0 ? var.register_instance_targets_count:0}"

  # to match the instances to the
  target_group_arn = "${ module.alb.target_group_arns[lookup(var.register_instance_targets[count.index], "target_group_index")]}"
  target_id        = "${ lookup(var.register_instance_targets[count.index], "instance_id") }"
}

resource "aws_wafregional_web_acl_association" "alb_waf" {
  count        = "${var.add_waf ? 1:0}"
  resource_arn = "${module.alb.load_balancer_id}"
  web_acl_id   = "${var.waf_id}"
}
