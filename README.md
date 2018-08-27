
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| add_waf | Add an existing Regional WAF to the ALB. true | false | string | `false` | no |
| alb_name | A name for the load balancer, which must be unique within your AWS account. | string | - | yes |
| alb_tags | A map of tags to be applied to the ALB. i.e {Environment='Development'} | map | `<map>` | no |
| create_internal_zone_record | Create Route 53 internal zone record for the ALB. i.e true | false | string | `true` | no |
| create_logging_bucket | Create a new S3 logging bucket. i.e. true | false | string | `true` | no |
| enable_deletion_protection | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | string | `false` | no |
| environment | Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test') | string | `Development` | no |
| extra_ssl_certs | A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Certificates must be in the same region as the ALB. Required key/values: certificate_arn, https_listener_index (the index of the listener within https_listeners which the cert applies toward). [{'certificate_arn', 'arn:aws:iam::123456789012:server-certificate/other_test_cert-123456789012', 'https_listener_index', 1}] | list | `<list>` | no |
| extra_ssl_certs_count | The number of extra ssl certs to be added. | string | `0` | no |
| http_listeners | List of Maps of HTTP listeners (port, protocol, target_group_index). i.e. [{'port', 80 , 'protocol', 'HTTP'}, {'port', 8080, 'protocol', 'HTTP'}] | list | `<list>` | no |
| http_listeners_count | The number of HTTP listeners to be created. | string | `1` | no |
| https_listeners | List of Maps of HTTPS listeners. Certificate must be in the same region as the ALB. (port, certificate_arn, ssl_policy (optional: defaults to ELBSecurityPolicy-2016-08), target_group_index (optional: defaults to 0)) i.e. [{'certificate_arn', 'arn:aws:iam::123456789012:server-certificate/test_cert-123456789012', 'port', 443}] | list | `<list>` | no |
| https_listeners_count | The number of HTTPS listeners to be created. | string | `0` | no |
| idle_timeout | The idle timeout value, in seconds. The valid range is 1-3600. The default is 60 seconds. | string | `60` | no |
| internal_record_name | Record Name for the new Resource Record in the Internal Hosted Zone. i.e. alb.aws.com | string | - | yes |
| internal_zone_name | TLD for Internal Hosted Zone. i.e. dev.example.com | string | - | yes |
| load_balancer_is_internal | Indicates whether the load balancer is Internet-facing or internal. i.e. true | false | string | `false` | no |
| logging_bucket_acl | Define ACL for Bucket. Must be either authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write, private, public-read or public-read-write. Via https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl | string | `bucket-owner-full-control` | no |
| logging_bucket_encryption_kms_mster_key | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse_algorithm as aws:kms. | string | `` | no |
| logging_bucket_encyption | Enable default bucket encryption. i.e. AES256 | aws:kms | string | `AES256` | no |
| logging_bucket_force_destroy | Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true | false | string | `false` | no |
| logging_bucket_name | The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). If creating a new logging bucket enter desired bucket name. | string | `` | no |
| logging_bucket_prefix | The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket. Entry must not start with a / or end with one. i.e. 'logs' or 'data/logs' | string | `` | no |
| logging_bucket_retention | The number of days to retain load balancer logs.  Parameter is ignored if not creating a new S3 bucket. i.e. between 1 - 999 | string | `14` | no |
| rackspace_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | string | `true` | no |
| rackspace_ticket_enabled | Specifies whether alarms will generate Rackspace tickets. i.e. true | false | string | `false` | no |
| register_instance_targets | List of Maps with the index of the target group and the instance id being registered with that group. i.e. [{'instance_id' : 'i-052f1856e2a471b74', 'target_group_index' : 0}, {'instance_id' : 'i-0cc4b566324707026', 'target_group_index' : 0}] | list | `<list>` | no |
| register_instance_targets_count | Count of ec2 instances being added to the target groups. | string | `0` | no |
| route_53_hosted_zone_id | The Route53 Internal Hosted Zone ID. | string | - | yes |
| security_groups | A list of EC2 security group ids to assign to this resource. i.e. ['sg-edcd9784', 'sg-edcd9785'] | list | - | yes |
| subnets | A list of at least two IDs of the subnets to associate with the load balancer. i.e ['subnet-abcde012', 'subnet-bcde012a'] | list | - | yes |
| target_groups | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Optional key/values are in the target_groups_defaults variable. i.e. [{'name', 'foo', 'backend_protocol', 'HTTP', 'backend_port', '80'}] | list | `<list>` | no |
| target_groups_count | The number of target groups to create | string | `1` | no |
| target_groups_defaults | Default values for target groups as defined by the list of maps. i.e. [{ 'cookie_duration': 86400, 'deregistration_delay': 300, 'health_check_healthy_threshold': 3, 'health_check_interval': 10, 'health_check_matcher': '200-299', 'health_check_path': '/', 'health_check_port': 'traffic-port', 'health_check_timeout': 5, 'health_check_unhealthy_threshold': 3, 'stickiness_enabled': true, 'target_type': 'instance' }] | list | `<list>` | no |
| vpc_id | The VPC in which your targets are located. i.e. vpc-abcde012 | string | - | yes |
| waf_id | The unique identifier (ID) for the Regional Web Application Firewall (WAF) ACL. i.e. 329d10ec-e221-49d1-9f4b-e1294150d292 | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb_dns_name | The DNS name of the load balancer. |
| http_tcp_listener_arns | The ARN of the TCP and HTTP load balancer listeners created. |
| http_tcp_listener_ids | The IDs of the TCP and HTTP load balancer listeners created. |
| https_listener_arns | The ARNs of the HTTPS load balancer listeners created. |
| https_listener_ids | The IDs of the load balancer listeners created. |
| load_balancer_arn_suffix | ARN suffix of our load balancer - can be used with CloudWatch. |
| load_balancer_id | The ID and ARN of the load balancer we created. |
| load_balancer_zone_id | The zone_id of the load balancer to assist with creating DNS records. |
| logging_bucket_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| logging_bucket_domain_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| logging_bucket_hosted_zone_id | The Route 53 Hosted Zone ID for this bucket's region. |
| logging_bucket_id | The name of the bucket. |
| logging_bucket_region | The AWS region this bucket resides in. |
| logging_bucket_regional_domain_name | The bucket region-specific domain name. The bucket domain name including the region name. |
| target_group_arn_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target_group_arns | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target_group_names | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| unhealthy_host_alarm_id | The ID of the health check. |

