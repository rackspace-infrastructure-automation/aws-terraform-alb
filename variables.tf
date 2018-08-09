variable "alb_name" {
  description = "A name for the load balancer, which must be unique within your AWS account."
  type        = "string"
}

variable "alb_tags" {
  description = "A map of tags to be applied to the ALB. i.e {Environment='Development'}"
  type        = "map"
  default     = {}
}

variable "create_internal_zone_record" {
  description = "Create Route 53 internal zone record for the ALB. i.e true | false"
  type        = "string"
  default     = true
}

variable "create_logging_bucket" {
  description = "Create a new S3 logging bucket. i.e. true | false"
  type        = "string"
  default     = true
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = "string"
  default     = false
}

variable "environment" {
  description = "Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test')"
  type        = "string"
  default     = "Development"
}

variable "extra_ssl_certs_count" {
  description = "The number of extra ssl certs to be added."
  type        = "string"
  default     = 0
}

variable "extra_ssl_certs" {
  description = "A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Certificates must be in the same region as the ALB. Required key/values: certificate_arn, https_listener_index (the index of the listener within https_listeners which the cert applies toward). [{'certificate_arn', 'arn:aws:iam::123456789012:server-certificate/other_test_cert-123456789012', 'https_listener_index', 1}]"
  type        = "list"
  default     = []
}

variable "http_listeners_count" {
  description = "The number of HTTP listeners to be created."
  type        = "string"
  default     = 1
}

variable "http_listeners" {
  description = "List of Maps of HTTP listeners (port, protocol, target_group_index). i.e. [{'port', 80 , 'protocol', 'HTTP'}, {'port', 8080, 'protocol', 'HTTP'}]"
  type        = "list"

  default = [{
    port     = 80
    protocol = "HTTP"
  }]
}

variable "https_listeners_count" {
  description = "The number of HTTPS listeners to be created."
  type        = "string"
  default     = 0
}

variable "https_listeners" {
  description = "List of Maps of HTTPS listeners. Certificate must be in the same region as the ALB. (port, certificate_arn, ssl_policy (optional: defaults to ELBSecurityPolicy-2016-08), target_group_index (optional: defaults to 0)) i.e. [{'certificate_arn', 'arn:aws:iam::123456789012:server-certificate/test_cert-123456789012', 'port', 443}]"
  type        = "list"
  default     = []
}

variable "idle_timeout" {
  description = "The idle timeout value, in seconds. The valid range is 1-3600. The default is 60 seconds."
  type        = "string"
  default     = 60
}

variable "internal_record_name" {
  description = "Record Name for the new Resource Record in the Internal Hosted Zone. i.e. alb.aws.com"
  type        = "string"
}

variable "internal_zone_name" {
  description = "TLD for Internal Hosted Zone. i.e. dev.example.com"
  type        = "string"
}

variable "load_balancer_is_internal" {
  description = "Indicates whether the load balancer is Internet-facing or internal. i.e. true | false"
  type        = "string"
  default     = false
}

variable "logging_bucket_acl" {
  description = "Define ACL for Bucket. Must be either authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write, private, public-read or public-read-write. Via https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl"
  type        = "string"
  default     = "bucket-owner-full-control"
}

variable "logging_bucket_encyption" {
  description = "Enable default bucket encryption. i.e. AES256 | aws:kms"
  type        = "string"
  default     = "AES256"
}

variable "logging_bucket_encryption_kms_mster_key" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms."
  type        = "string"
  default     = ""
}

variable "logging_bucket_force_destroy" {
  description = "Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true | false"
  type        = "string"
  default     = false
}

variable "logging_bucket_name" {
  description = "The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). If creating a new logging bucket enter desired bucket name."
  type        = "string"
  default     = ""
}

variable "logging_bucket_prefix" {
  description = "The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket. Entry must not start with a / or end with one. i.e. 'logs' or 'data/logs'"
  type        = "string"
  default     = ""
}

variable "logging_bucket_retention" {
  description = "The number of days to retain load balancer logs.  Parameter is ignored if not creating a new S3 bucket. i.e. between 1 - 999"
  type        = "string"
  default     = 14
}

variable "rackspace_ticket_enabled" {
  description = "Specifies whether alarms will generate Rackspace tickets. i.e. true | false"
  type        = "string"
  default     = false
}

variable "register_instance_targets_count" {
  description = "Count of ec2 instances being added to the target groups."
  type        = "string"
  default     = 0
}

variable "register_instance_targets" {
  description = "List of Maps with the index of the target group and the instance id being registered with that group. i.e. [{'instance_id' : 'i-052f1856e2a471b74', 'target_group_index' : 0}, {'instance_id' : 'i-0cc4b566324707026', 'target_group_index' : 0}]"
  type        = "list"
  default     = []
}

variable "route_53_hosted_zone_id" {
  description = "The Route53 Internal Hosted Zone ID."
  type        = "string"
}

variable "security_groups" {
  description = "A list of EC2 security group ids to assign to this resource. i.e. ['sg-edcd9784', 'sg-edcd9785']"
  type        = "list"
}

variable "subnets" {
  description = "A list of at least two IDs of the subnets to associate with the load balancer. i.e ['subnet-abcde012', 'subnet-bcde012a']"
  type        = "list"
}

variable "target_groups_count" {
  description = "The number of target groups to create"
  type        = "string"
  default     = 1

variable "target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Optional key/values are in the target_groups_defaults variable. i.e. [{'name', 'foo', 'backend_protocol', 'HTTP', 'backend_port', '80'}]"
  type        = "list"

  default = [{
    "name" = "ALB-TargetGroup"

    "backend_protocol" = "HTTP"

    "backend_port" = 80
  }]
}

variable "target_groups_defaults" {
  description = "Default values for target groups as defined by the list of maps. i.e. [{ 'cookie_duration': 86400, 'deregistration_delay': 300, 'health_check_healthy_threshold': 3, 'health_check_interval': 10, 'health_check_matcher': '200-299', 'health_check_path': '/', 'health_check_port': 'traffic-port', 'health_check_timeout': 5, 'health_check_unhealthy_threshold': 3, 'stickiness_enabled': true, 'target_type': 'instance' }]"
  type        = "list"

  default = [{
    "cookie_duration" = 86400

    "deregistration_delay" = 30

    "health_check_healthy_threshold" = 5

    "health_check_interval" = 30

    "health_check_matcher" = "200-299"

    "health_check_path" = "/"

    "health_check_port" = "traffic-port"

    "health_check_timeout" = 5

    "health_check_unhealthy_threshold" = 2

    "stickiness_enabled" = false

    "target_type" = "instance"
  }]
}

variable "vpc_id" {
  description = "The VPC in which your targets are located. i.e. vpc-abcde012"
  type        = "string"
}
