variable "add_waf" {
  description = "Add an existing Regional WAF to the ALB. true | false"
  type        = bool
  default     = false
}

variable "create_internal_zone_record" {
  description = "Create Route 53 internal zone record for the ALB. i.e true | false"
  type        = bool
  default     = false
}

variable "create_logging_bucket" {
  description = "Create a new S3 logging bucket. i.e. true | false"
  type        = bool
  default     = true
}

variable "enable_deletion_protection" {
  description = "If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false."
  type        = bool
  default     = false
}

variable "enable_http2" {
  description = "If true sets HTTP/2 to enabled."
  type        = bool
  default     = true
}

variable "enable_https_redirect" {
  description = "If true and at least one HTTP and one HTTPS listener is created, HTTP listeners will have a redirect rule created to forward all traffic to the first HTTPS listener."
  type        = bool
  default     = false
}

variable "environment" {
  description = "Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test')"
  type        = string
  default     = "Development"
}

variable "extra_ssl_certs_count" {
  description = "The number of extra ssl certs to be added."
  type        = number
  default     = 0
}

variable "extra_ssl_certs" {
  description = "A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Certificates must be in the same region as the ALB. Required key/values: certificate_arn, https_listener_index (the index of the listener within https_listeners which the cert applies toward). [{'certificate_arn', 'arn:aws:iam::123456789012:server-certificate/other_test_cert-123456789012', 'https_listener_index', 1}]"
  type        = list(map(string))
  default     = []
}

variable "http_listeners" {
  description = "List of Maps of HTTP listeners (port, protocol, target_group_index). i.e. [{'port', 80 , 'protocol', 'HTTP'}, {'port', 8080, 'protocol', 'HTTP'}]"
  type        = list(map(string))

  default = [
    {
      port     = 80
      protocol = "HTTP"
    },
  ]
}

variable "http_listeners_count" {
  description = "The number of HTTP listeners to be created."
  type        = number
  default     = 1
}

variable "https_listeners" {
  description = "List of Maps of HTTPS listeners. Certificate must be in the same region as the ALB. (port, certificate_arn, ssl_policy (optional: defaults to ELBSecurityPolicy-2016-08), target_group_index (optional: defaults to 0)) i.e. [{'certificate_arn', 'arn:aws:iam::123456789012:server-certificate/test_cert-123456789012', 'port', 443}]"
  type        = list(map(string))
  default     = []
}

variable "https_listeners_count" {
  description = "The number of HTTPS listeners to be created."
  type        = string
  default     = 0
}

variable "idle_timeout" {
  description = "The idle timeout value, in seconds. The valid range is 1-3600. The default is 60 seconds."
  type        = number
  default     = 60
}

variable "internal_record_name" {
  description = "Record Name for the new Resource Record in the Internal Hosted Zone. i.e. alb.example.com"
  type        = string
  default     = ""
}

variable "internal_zone_id" {
  description = "The Route53 Internal Hosted Zone ID."
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms."
  type        = string
  default     = ""
}

variable "load_balancer_create_timeout" {
  description = "Timeout value when creating the ALB."
  type        = string
  default     = "10m"
}

variable "load_balancer_delete_timeout" {
  description = "Timeout value when deleting the ALB."
  type        = string
  default     = "10m"
}

variable "load_balancer_is_internal" {
  description = "Indicates whether the load balancer is Internet-facing or internal. i.e. true | false"
  type        = bool
  default     = false
}

variable "load_balancer_update_timeout" {
  description = "Timeout value when updating the ALB."
  type        = string
  default     = "10m"
}

variable "logging_bucket_acl" {
  description = "Define ACL for Bucket. Must be either authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write, private, public-read or public-read-write. Via https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl"
  type        = string
  default     = "bucket-owner-full-control"
}

variable "logging_bucket_encyption" {
  description = "Enable default bucket encryption. i.e. AES256 | aws:kms"
  type        = string
  default     = "AES256"
}

variable "logging_bucket_force_destroy" {
  description = "Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true | false"
  type        = bool
  default     = false
}

variable "logging_bucket_name" {
  description = "The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). If creating a new logging bucket enter desired bucket name."
  type        = string
  default     = ""
}

variable "logging_bucket_prefix" {
  description = "The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket. Entry must not start with a / or end with one. i.e. 'logs' or 'data/logs'"
  type        = string
  default     = null
}

variable "logging_bucket_retention" {
  description = "The number of days to retain load balancer logs.  Parameter is ignored if not creating a new S3 bucket. i.e. between 1 - 999"
  type        = number
  default     = 14
}

variable "logging_enabled" {
  description = "Whether logging for this bucket is enabled."
  type        = bool
  default     = false
}

variable "name" {
  description = "A name for the load balancer, which must be unique within your AWS account."
  type        = string
}

variable "notification_topic" {
  description = "List of SNS Topic ARNs to use for customer notifications."
  type        = list(string)
  default     = []
}

variable "rackspace_alarms_enabled" {
  description = "Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace_managed is set to false."
  type        = bool
  default     = false
}

variable "rackspace_managed" {
  description = "Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents."
  type        = bool
  default     = true
}

variable "register_instance_targets" {
  description = "List of Maps with the index of the target group and the instance id being registered with that group. i.e. [{'instance_id' : 'i-052f1856e2a471b74', 'target_group_index' : 0}, {'instance_id' : 'i-0cc4b566324707026', 'target_group_index' : 0}]"
  type        = list(map(string))
  default     = []
}

variable "register_instance_targets_count" {
  description = "Count of ec2 instances being added to the target groups."
  type        = number
  default     = 0
}

variable "security_groups" {
  description = "A list of EC2 security group ids to assign to this resource. i.e. ['sg-edcd9784', 'sg-edcd9785']"
  type        = list(string)
}

variable "subnets" {
  description = "A list of at least two IDs of the subnets to associate with the load balancer. i.e ['subnet-abcde012', 'subnet-bcde012a']"
  type        = list(string)
}

variable "tags" {
  description = "A map of tags to be applied to the ALB. i.e {Environment='Development'}"
  type        = map(string)
  default     = {}
}

variable "target_groups" {
  description = "A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Optional key/values are in the target_groups_defaults variable. i.e. [{'name', 'foo', 'backend_protocol', 'HTTP', 'backend_port', '80'}]"
  type        = list(map(string))

  default = [
    {
      "name"             = "ALB-TargetGroup"
      "backend_protocol" = "HTTP"
      "backend_port"     = 80
    },
  ]
}

variable "target_groups_count" {
  description = "The number of target groups to create"
  type        = number
  default     = 1
}

variable "target_groups_defaults" {
  description = "Default values for target groups as defined by the list of maps. i.e. [{ 'cookie_duration': 86400, 'deregistration_delay': 300, 'health_check_healthy_threshold': 3, 'health_check_interval': 10, 'health_check_matcher': '200-299', 'health_check_path': '/', 'health_check_port': 'traffic-port', 'health_check_timeout': 5, 'health_check_unhealthy_threshold': 3, 'stickiness_enabled': true, 'load_balancing_algorithm_type': 'round_robin', 'target_type': 'instance' }]"
  type        = list(map(string))

  default = [
    {
      "cookie_duration"                  = 86400
      "deregistration_delay"             = 30
      "health_check_healthy_threshold"   = 5
      "health_check_interval"            = 30
      "health_check_matcher"             = "200-299"
      "health_check_path"                = "/"
      "health_check_port"                = "traffic-port"
      "health_check_timeout"             = 5
      "health_check_unhealthy_threshold" = 2
      "load_balancing_algorithm_type"    = "round-robin"
      "stickiness_enabled"               = false
      "slow_start"                       = 0
      "target_type"                      = "instance"
    },
  ]
}

variable "vpc_id" {
  description = "The VPC in which your targets are located. i.e. vpc-abcde012"
  type        = string
}

variable "waf_id" {
  description = "The unique identifier (ID) for the Regional Web Application Firewall (WAF) ACL. i.e. 329d10ec-e221-49d1-9f4b-e1294150d292"
  type        = string
  default     = ""
}
