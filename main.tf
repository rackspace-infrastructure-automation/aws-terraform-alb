/**
 * # aws-terraform-alb
 * This module deploys an Application Load Balancer with associated resources, such as an unhealthy host count CloudWatch alarm, S3 log bucket, and Route 53 internal zone record.
 *
 * ## Basic Usage
 *
 * ```HCL
 * module "alb" {
 *   source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-alb//?ref=v0.12.5"
 *
 *   http_listeners_count = 1
 *   name                 = "MyALB"
 *   security_groups      = ["${module.sg.public_web_security_group_id}"]
 *   subnets              = ["${module.vpc.public_subnets}"]
 *   target_groups_count  = 1
 *   vpc_id               = "${module.vpc.vpc_id}"
 *
 *   http_listeners = [
 *     {
 *       port     = 80
 *       protocol = "HTTP"
 *     },
 *   ]
 *
 *   target_groups = [
 *     {
 *       backend_port     = 80
 *       backend_protocol = "HTTP"
 *       name             = "MyTargetGroup"
 *     }
 *   ]
 * }
 * ```
 *
 * Full working references are available at [examples](examples)
 *
 * ## Terraform 0.12 upgrade
 *
 * Several changes were required while adding terraform 0.12 compatibility.  The following changes should
 * made when upgrading from a previous release to version 0.12.0 or higher.
 *
 * ### Terraform State File
 *
 * During the conversion, we have removed dependency on upstream modules.  This does require some resources to be relocated
 * within the state file.  The following statements can be used to update existing resources.  In each command, `<MODULE_NAME>`
 * should be replaced with the logic name used where the module is referenced.  One block applies to load balancers configured
 * with S3 logging, and the other for those with logging disabled
 *
 * #### ALBs configured with S3 logging
 *
 * ```
 * terraform state mv module.<MODULE_NAME>.module.alb.aws_lb.application module.<MODULE_NAME>.aws_lb.alb
 * terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_target_group.main module.<MODULE_NAME>.aws_lb_target_group.main
 * terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_listener.frontend_http_tcp module.<MODULE_NAME>.aws_lb_listener.http
 * terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_listener.frontend_https module.<MODULE_NAME>.aws_lb_listener.https
 * ```
 *
 * #### ALBs configured with logging disabled
 *
 * ```
 * terraform state mv module.<MODULE_NAME>.module.alb.aws_lb.application_no_logs module.<MODULE_NAME>.aws_lb.alb
 * terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_target_group.main_no_logs module.<MODULE_NAME>.aws_lb_target_group.main
 * terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_listener.frontend_http_tcp_no_logs module.<MODULE_NAME>.aws_lb_listener.http
 * terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_listener.frontend_https_no_logs module.<MODULE_NAME>.aws_lb_listener.https
 * ```
 *
 * ### Module variables
 *
 * The following module variables were updated to better meet current Rackspace style guides:
 *
 * - `alb_name` -> `name`
 * - `alb_tags` -> `tags`
 * - `logging_bucket_encryption_kms_mster_key` -> `kms_key_id`
 * - `route_53_hosted_zone_id` -> `internal_zone_id`
 *
 */

terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = ">= 2.7.0"
  }
}

data "aws_elb_service_account" "main" {}

locals {
  acl_list = ["authenticated-read", "aws-exec-read", "log-delivery-write", "private", "public-read", "public-read-write"]

  bucket_acl = contains(local.acl_list, var.logging_bucket_acl) ? var.logging_bucket_acl : "private"

  default_tags = {
    ServiceProvider = "Rackspace"
    Environment     = var.environment
  }

  merged_tags = merge(var.tags, local.default_tags)

  enable_https_redirect = var.http_listeners_count > 0 && var.https_listeners_count > 0 && var.enable_https_redirect

  target_groups_defaults = var.target_groups_defaults[0]

  access_logs = [
    {
      bucket  = var.logging_bucket_name
      enabled = var.logging_enabled
      prefix  = var.logging_bucket_prefix
    }
  ]
}

resource "aws_lb" "alb" {
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
  idle_timeout               = var.idle_timeout
  internal                   = var.load_balancer_is_internal
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = var.name
  security_groups            = var.security_groups
  subnets                    = var.subnets
  tags                       = merge(local.merged_tags, map("Name", var.name))

  dynamic "access_logs" {
    for_each = [for al in local.access_logs : al if al.enabled]

    content {
      bucket  = access_logs.value["bucket"]
      enabled = access_logs.value["enabled"]
      prefix  = access_logs.value["prefix"]
    }
  }

  timeouts {
    create = var.load_balancer_create_timeout
    delete = var.load_balancer_delete_timeout
    update = var.load_balancer_update_timeout
  }

  depends_on = [
    aws_s3_bucket_policy.log_bucket_policy,
  ]
}

resource "aws_lb_target_group" "main" {
  count = var.target_groups_count

  deregistration_delay = lookup(var.target_groups[count.index], "deregistration_delay", lookup(local.target_groups_defaults, "deregistration_delay"))
  name                 = lookup(var.target_groups[count.index], "name")
  port                 = lookup(var.target_groups[count.index], "backend_port")
  protocol             = upper(lookup(var.target_groups[count.index], "backend_protocol"))
  slow_start           = lookup(var.target_groups[count.index], "slow_start", lookup(local.target_groups_defaults, "slow_start"))
  tags                 = merge(local.merged_tags, map("Name", lookup(var.target_groups[count.index], "name")))
  target_type          = lookup(var.target_groups[count.index], "target_type", lookup(local.target_groups_defaults, "target_type"))
  vpc_id               = var.vpc_id

  load_balancing_algorithm_type = lookup(var.target_groups[count.index], "load_balancing_algorithm_type", lookup(local.target_groups_defaults, "load_balancing_algorithm_type"))

  health_check {
    healthy_threshold   = lookup(var.target_groups[count.index], "health_check_healthy_threshold", lookup(local.target_groups_defaults, "health_check_healthy_threshold"))
    interval            = lookup(var.target_groups[count.index], "health_check_interval", lookup(local.target_groups_defaults, "health_check_interval"))
    matcher             = lookup(var.target_groups[count.index], "health_check_matcher", lookup(local.target_groups_defaults, "health_check_matcher"))
    path                = lookup(var.target_groups[count.index], "health_check_path", lookup(local.target_groups_defaults, "health_check_path"))
    port                = lookup(var.target_groups[count.index], "health_check_port", lookup(local.target_groups_defaults, "health_check_port"))
    protocol            = upper(lookup(var.target_groups[count.index], "healthcheck_protocol", lookup(var.target_groups[count.index], "backend_protocol")))
    timeout             = lookup(var.target_groups[count.index], "health_check_timeout", lookup(local.target_groups_defaults, "health_check_timeout"))
    unhealthy_threshold = lookup(var.target_groups[count.index], "health_check_unhealthy_threshold", lookup(local.target_groups_defaults, "health_check_unhealthy_threshold"))
  }

  stickiness {
    cookie_duration = lookup(var.target_groups[count.index], "cookie_duration", lookup(local.target_groups_defaults, "cookie_duration"))
    enabled         = lookup(var.target_groups[count.index], "stickiness_enabled", lookup(local.target_groups_defaults, "stickiness_enabled"))
    type            = "lb_cookie"
  }

  depends_on = [aws_lb.alb]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  count = var.http_listeners_count

  load_balancer_arn = aws_lb.alb.arn
  port              = lookup(var.http_listeners[count.index], "port")
  protocol          = "HTTP"

  default_action {
    target_group_arn = element(aws_lb_target_group.main.*.id, lookup(var.http_listeners[count.index], "target_group_index", count.index))
    type             = "forward"
  }
}

resource "aws_lb_listener" "https" {
  count = var.https_listeners_count

  certificate_arn   = lookup(var.https_listeners[count.index], "certificate_arn")
  load_balancer_arn = aws_lb.alb.arn
  port              = lookup(var.https_listeners[count.index], "port")
  protocol          = "HTTPS"
  ssl_policy        = lookup(var.https_listeners[count.index], "ssl_policy", "ELBSecurityPolicy-TLS-1-2-2017-01")

  default_action {
    target_group_arn = element(aws_lb_target_group.main.*.id, lookup(var.https_listeners[count.index], "target_group_index", count.index))
    type             = "forward"
  }
}

resource "aws_lb_listener_certificate" "https" {
  count = var.extra_ssl_certs_count

  certificate_arn = lookup(var.extra_ssl_certs[count.index], "certificate_arn")
  listener_arn    = element(aws_lb_listener.https.*.arn, lookup(var.extra_ssl_certs[count.index], "https_listener_index"))
}

resource "aws_lb_listener_rule" "redirect_http_to_https" {
  count = local.enable_https_redirect ? var.http_listeners_count : 0

  listener_arn = element(aws_lb_listener.http.*.arn, count.index)

  action {
    type = "redirect"

    redirect {
      port        = var.https_listeners[0]["port"]
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}

# create s3 bucket if needed
resource "aws_s3_bucket" "log_bucket" {
  count = var.create_logging_bucket ? 1 : 0

  acl           = local.bucket_acl
  bucket        = var.logging_bucket_name
  force_destroy = var.logging_bucket_force_destroy
  tags          = local.merged_tags

  lifecycle_rule {
    enabled = true
    prefix  = var.logging_bucket_prefix

    expiration {
      days = var.logging_bucket_retention
    }
  }

  lifecycle_rule {
    abort_incomplete_multipart_upload_days = 7
    enabled                                = true
    id                                     = "rax-cleanup-incomplete-mpu-objects"

    expiration {}
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_id
        sse_algorithm     = var.logging_bucket_encyption
      }
    }
  }
}

# s3 policy needs to be separate since you can't reference the bucket for the reference.

data "aws_iam_policy_document" "log_bucket_policy" {
  count = var.create_logging_bucket ? 1 : 0

  statement {
    actions   = ["s3:PutObject"]
    effect    = "Allow"
    resources = ["${aws_s3_bucket.log_bucket[0].arn}/*"]

    principals {
      identifiers = [data.aws_elb_service_account.main.arn]
      type        = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  count = var.create_logging_bucket ? 1 : 0

  bucket = aws_s3_bucket.log_bucket[0].id
  policy = data.aws_iam_policy_document.log_bucket_policy[0].json
}

# create r53 record with alias
resource "aws_route53_record" "zone_record_alias" {
  count = var.create_internal_zone_record ? 1 : 0

  name    = var.internal_record_name
  type    = "A"
  zone_id = var.internal_zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_lb.alb.dns_name
    zone_id                = aws_lb.alb.zone_id
  }
}

# enable cloudwatch/RS ticket creation
data "null_data_source" "alarm_dimensions" {
  count = var.target_groups_count > 0 ? var.target_groups_count : 0

  inputs = {
    LoadBalancer = aws_lb.alb.arn_suffix
    TargetGroup  = element(aws_lb_target_group.main.*.arn_suffix, count.index)
  }
}

module "unhealthy_host_count_alarm" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm//?ref=v0.12.6"

  alarm_count              = var.target_groups_count > 0 ? var.target_groups_count : 0
  alarm_description        = "Unhealthy Host count is greater than or equal to threshold, creating ticket."
  alarm_name               = "${var.name}_unhealthy_host_count_alarm"
  comparison_operator      = "GreaterThanOrEqualToThreshold"
  dimensions               = data.null_data_source.alarm_dimensions.*.outputs
  evaluation_periods       = 10
  metric_name              = "UnHealthyHostCount"
  namespace                = "AWS/ApplicationELB"
  notification_topic       = var.notification_topic
  period                   = 60
  rackspace_alarms_enabled = var.rackspace_alarms_enabled
  rackspace_managed        = var.rackspace_managed
  severity                 = "emergency"
  statistic                = "Maximum"
  threshold                = 1
  unit                     = "Count"
}

# join ec2 instances to target group
resource "aws_lb_target_group_attachment" "target_group_instance" {
  count = var.register_instance_targets_count > 0 ? var.register_instance_targets_count : 0

  target_group_arn = aws_lb_target_group.main.*.arn[var.register_instance_targets[count.index]["target_group_index"]]
  target_id        = var.register_instance_targets[count.index]["instance_id"]
}

resource "aws_wafregional_web_acl_association" "alb_waf" {
  count = var.add_waf ? 1 : 0

  resource_arn = aws_lb.alb.id
  web_acl_id   = var.waf_id
}
