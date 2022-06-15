# aws-terraform-alb
This module deploys an Application Load Balancer with associated resources, such as an unhealthy host count CloudWatch alarm, S3 log bucket, and Route 53 internal zone record.

## Basic Usage

```HCL
module "alb" {
  source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-alb//?ref=v0.12.5"

  http_listeners_count = 1
  name                 = "MyALB"
  security_groups      = ["${module.sg.public_web_security_group_id}"]
  subnets              = ["${module.vpc.public_subnets}"]
  target_groups_count  = 1
  vpc_id               = "${module.vpc.vpc_id}"

  http_listeners = [
    {
      port     = 80
      protocol = "HTTP"
    },
  ]

  target_groups = [
    {
      backend_port     = 80
      backend_protocol = "HTTP"
      name             = "MyTargetGroup"
    }
  ]
}
```

Full working references are available at [examples](examples)

## Terraform 0.12 upgrade

Several changes were required while adding terraform 0.12 compatibility.  The following changes should
made when upgrading from a previous release to version 0.12.0 or higher.

### Terraform State File

During the conversion, we have removed dependency on upstream modules.  This does require some resources to be relocated
within the state file.  The following statements can be used to update existing resources.  In each command, `<MODULE_NAME>`
should be replaced with the logic name used where the module is referenced.  One block applies to load balancers configured
with S3 logging, and the other for those with logging disabled

#### ALBs configured with S3 logging

```
terraform state mv module.<MODULE_NAME>.module.alb.aws_lb.application module.<MODULE_NAME>.aws_lb.alb
terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_target_group.main module.<MODULE_NAME>.aws_lb_target_group.main
terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_listener.frontend_http_tcp module.<MODULE_NAME>.aws_lb_listener.http
terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_listener.frontend_https module.<MODULE_NAME>.aws_lb_listener.https
```

#### ALBs configured with logging disabled

```
terraform state mv module.<MODULE_NAME>.module.alb.aws_lb.application_no_logs module.<MODULE_NAME>.aws_lb.alb
terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_target_group.main_no_logs module.<MODULE_NAME>.aws_lb_target_group.main
terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_listener.frontend_http_tcp_no_logs module.<MODULE_NAME>.aws_lb_listener.http
terraform state mv module.<MODULE_NAME>.module.alb.aws_lb_listener.frontend_https_no_logs module.<MODULE_NAME>.aws_lb_listener.https
```

### Module variables

The following module variables were updated to better meet current Rackspace style guides:

- `alb_name` -> `name`
- `alb_tags` -> `tags`
- `logging_bucket_encryption_kms_mster_key` -> `kms_key_id`
- `route_53_hosted_zone_id` -> `internal_zone_id`

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 2.7.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 2.7.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_unhealthy_host_count_alarm"></a> [unhealthy\_host\_count\_alarm](#module\_unhealthy\_host\_count\_alarm) | git@github.com:rackspace-infrastructure-automation/aws-terraform-cloudwatch_alarm// | v0.12.6 |

## Resources

| Name | Type |
|------|------|
| [aws_lb.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_certificate.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_certificate) | resource |
| [aws_lb_listener_rule.redirect_http_to_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.target_group_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |
| [aws_route53_record.zone_record_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.log_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_wafregional_web_acl_association.alb_waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_web_acl_association) | resource |
| [aws_elb_service_account.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/elb_service_account) | data source |
| [aws_iam_policy_document.log_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [null_data_source.alarm_dimensions](https://registry.terraform.io/providers/hashicorp/null/latest/docs/data-sources/data_source) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_waf"></a> [add\_waf](#input\_add\_waf) | Add an existing Regional WAF to the ALB. true \| false | `bool` | `false` | no |
| <a name="input_create_internal_zone_record"></a> [create\_internal\_zone\_record](#input\_create\_internal\_zone\_record) | Create Route 53 internal zone record for the ALB. i.e true \| false | `bool` | `false` | no |
| <a name="input_create_logging_bucket"></a> [create\_logging\_bucket](#input\_create\_logging\_bucket) | Create a new S3 logging bucket. i.e. true \| false | `bool` | `true` | no |
| <a name="input_customer_alarms_cleared"></a> [customer\_alarms\_cleared](#input\_customer\_alarms\_cleared) | Specifies whether alarms will notify customers when returning to an OK status. | `bool` | `false` | no |
| <a name="input_customer_alarms_enabled"></a> [customer\_alarms\_enabled](#input\_customer\_alarms\_enabled) | Specifies whether alarms will notify customers.  Automatically enabled if rackspace\_managed is set to false | `bool` | `false` | no |
| <a name="input_drop_invalid_header_fields"></a> [drop\_invalid\_header\_fields](#input\_drop\_invalid\_header\_fields) | Indicates whether HTTP headers with header fields that are not valid are removed by the load balancer (true) or routed to targets (false). | `bool` | `false` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| <a name="input_enable_http2"></a> [enable\_http2](#input\_enable\_http2) | If true sets HTTP/2 to enabled. | `bool` | `true` | no |
| <a name="input_enable_https_redirect"></a> [enable\_https\_redirect](#input\_enable\_https\_redirect) | If true and at least one HTTP and one HTTPS listener is created, HTTP listeners will have a redirect rule created to forward all traffic to the first HTTPS listener. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test') | `string` | `"Development"` | no |
| <a name="input_extra_ssl_certs"></a> [extra\_ssl\_certs](#input\_extra\_ssl\_certs) | A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Certificates must be in the same region as the ALB. Required key/values: certificate\_arn, https\_listener\_index (the index of the listener within https\_listeners which the cert applies toward). [{'certificate\_arn', 'arn:aws:iam::123456789012:server-certificate/other\_test\_cert-123456789012', 'https\_listener\_index', 1}] | `list(map(string))` | `[]` | no |
| <a name="input_extra_ssl_certs_count"></a> [extra\_ssl\_certs\_count](#input\_extra\_ssl\_certs\_count) | The number of extra ssl certs to be added. | `number` | `0` | no |
| <a name="input_http_listeners"></a> [http\_listeners](#input\_http\_listeners) | List of Maps of HTTP listeners (port, protocol, target\_group\_index). i.e. [{'port', 80 , 'protocol', 'HTTP'}, {'port', 8080, 'protocol', 'HTTP'}] | `list(map(string))` | <pre>[<br>  {<br>    "port": 80,<br>    "protocol": "HTTP"<br>  }<br>]</pre> | no |
| <a name="input_http_listeners_count"></a> [http\_listeners\_count](#input\_http\_listeners\_count) | The number of HTTP listeners to be created. | `number` | `1` | no |
| <a name="input_https_listeners"></a> [https\_listeners](#input\_https\_listeners) | List of Maps of HTTPS listeners. Certificate must be in the same region as the ALB. (port, certificate\_arn, ssl\_policy (optional: defaults to ELBSecurityPolicy-2016-08), target\_group\_index (optional: defaults to 0)) i.e. [{'certificate\_arn', 'arn:aws:iam::123456789012:server-certificate/test\_cert-123456789012', 'port', 443}] | `list(map(string))` | `[]` | no |
| <a name="input_https_listeners_count"></a> [https\_listeners\_count](#input\_https\_listeners\_count) | The number of HTTPS listeners to be created. | `string` | `0` | no |
| <a name="input_idle_timeout"></a> [idle\_timeout](#input\_idle\_timeout) | The idle timeout value, in seconds. The valid range is 1-3600. The default is 60 seconds. | `number` | `60` | no |
| <a name="input_internal_record_name"></a> [internal\_record\_name](#input\_internal\_record\_name) | Record Name for the new Resource Record in the Internal Hosted Zone. i.e. alb.example.com | `string` | `""` | no |
| <a name="input_internal_zone_id"></a> [internal\_zone\_id](#input\_internal\_zone\_id) | The Route53 Internal Hosted Zone ID. | `string` | `""` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. | `string` | `""` | no |
| <a name="input_load_balancer_create_timeout"></a> [load\_balancer\_create\_timeout](#input\_load\_balancer\_create\_timeout) | Timeout value when creating the ALB. | `string` | `"10m"` | no |
| <a name="input_load_balancer_delete_timeout"></a> [load\_balancer\_delete\_timeout](#input\_load\_balancer\_delete\_timeout) | Timeout value when deleting the ALB. | `string` | `"10m"` | no |
| <a name="input_load_balancer_is_internal"></a> [load\_balancer\_is\_internal](#input\_load\_balancer\_is\_internal) | Indicates whether the load balancer is Internet-facing or internal. i.e. true \| false | `bool` | `false` | no |
| <a name="input_load_balancer_update_timeout"></a> [load\_balancer\_update\_timeout](#input\_load\_balancer\_update\_timeout) | Timeout value when updating the ALB. | `string` | `"10m"` | no |
| <a name="input_logging_bucket_acl"></a> [logging\_bucket\_acl](#input\_logging\_bucket\_acl) | Define ACL for Bucket. Must be either authenticated-read, aws-exec-read, log-delivery-write, private, public-read or public-read-write. Via https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl | `string` | `"private"` | no |
| <a name="input_logging_bucket_encyption"></a> [logging\_bucket\_encyption](#input\_logging\_bucket\_encyption) | Enable default bucket encryption. i.e. AES256 \| aws:kms | `string` | `"AES256"` | no |
| <a name="input_logging_bucket_force_destroy"></a> [logging\_bucket\_force\_destroy](#input\_logging\_bucket\_force\_destroy) | Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true \| false | `bool` | `false` | no |
| <a name="input_logging_bucket_name"></a> [logging\_bucket\_name](#input\_logging\_bucket\_name) | The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). If creating a new logging bucket enter desired bucket name. | `string` | `""` | no |
| <a name="input_logging_bucket_prefix"></a> [logging\_bucket\_prefix](#input\_logging\_bucket\_prefix) | The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket. Entry must not start with a / or end with one. i.e. 'logs' or 'data/logs' | `string` | `null` | no |
| <a name="input_logging_bucket_retention"></a> [logging\_bucket\_retention](#input\_logging\_bucket\_retention) | The number of days to retain load balancer logs.  Parameter is ignored if not creating a new S3 bucket. i.e. between 1 - 999 | `number` | `14` | no |
| <a name="input_logging_enabled"></a> [logging\_enabled](#input\_logging\_enabled) | Whether logging for this bucket is enabled. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | A name for the load balancer, which must be unique within your AWS account. | `string` | n/a | yes |
| <a name="input_notification_topic"></a> [notification\_topic](#input\_notification\_topic) | List of SNS Topic ARNs to use for customer notifications. | `list(string)` | `[]` | no |
| <a name="input_rackspace_alarms_enabled"></a> [rackspace\_alarms\_enabled](#input\_rackspace\_alarms\_enabled) | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace\_managed is set to false. | `bool` | `false` | no |
| <a name="input_rackspace_managed"></a> [rackspace\_managed](#input\_rackspace\_managed) | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| <a name="input_register_instance_targets"></a> [register\_instance\_targets](#input\_register\_instance\_targets) | List of Maps with the index of the target group and the instance id being registered with that group. i.e. [{'instance\_id' : 'i-052f1856e2a471b74', 'target\_group\_index' : 0}, {'instance\_id' : 'i-0cc4b566324707026', 'target\_group\_index' : 0}] | `list(map(string))` | `[]` | no |
| <a name="input_register_instance_targets_count"></a> [register\_instance\_targets\_count](#input\_register\_instance\_targets\_count) | Count of ec2 instances being added to the target groups. | `number` | `0` | no |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | A list of EC2 security group ids to assign to this resource. i.e. ['sg-edcd9784', 'sg-edcd9785'] | `list(string)` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | A list of at least two IDs of the subnets to associate with the load balancer. i.e ['subnet-abcde012', 'subnet-bcde012a'] | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to be applied to the ALB. i.e {Environment='Development'} | `map(string)` | `{}` | no |
| <a name="input_target_groups"></a> [target\_groups](#input\_target\_groups) | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Optional key/values are in the target\_groups\_defaults variable. i.e. [{'name', 'foo', 'backend\_protocol', 'HTTP', 'backend\_port', '80'}] | `list(map(string))` | <pre>[<br>  {<br>    "backend_port": 80,<br>    "backend_protocol": "HTTP",<br>    "name": "ALB-TargetGroup"<br>  }<br>]</pre> | no |
| <a name="input_target_groups_count"></a> [target\_groups\_count](#input\_target\_groups\_count) | The number of target groups to create | `number` | `1` | no |
| <a name="input_target_groups_defaults"></a> [target\_groups\_defaults](#input\_target\_groups\_defaults) | Default values for target groups as defined by the list of maps. i.e. [{ 'cookie\_duration': 86400, 'deregistration\_delay': 300, 'health\_check\_healthy\_threshold': 3, 'health\_check\_interval': 10, 'health\_check\_matcher': '200-299', 'health\_check\_path': '/', 'health\_check\_port': 'traffic-port', 'health\_check\_timeout': 5, 'health\_check\_unhealthy\_threshold': 3, 'stickiness\_enabled': true, 'load\_balancing\_algorithm\_type': 'round\_robin', 'target\_type': 'instance' }] | `list(map(string))` | <pre>[<br>  {<br>    "cookie_duration": 86400,<br>    "deregistration_delay": 30,<br>    "health_check_healthy_threshold": 5,<br>    "health_check_interval": 30,<br>    "health_check_matcher": "200-299",<br>    "health_check_path": "/",<br>    "health_check_port": "traffic-port",<br>    "health_check_timeout": 5,<br>    "health_check_unhealthy_threshold": 2,<br>    "load_balancing_algorithm_type": "round_robin",<br>    "slow_start": 0,<br>    "stickiness_enabled": false,<br>    "target_type": "instance"<br>  }<br>]</pre> | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The VPC in which your targets are located. i.e. vpc-abcde012 | `string` | n/a | yes |
| <a name="input_waf_id"></a> [waf\_id](#input\_waf\_id) | The unique identifier (ID) for the Regional Web Application Firewall (WAF) ACL. i.e. 329d10ec-e221-49d1-9f4b-e1294150d292 | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | The DNS name of the load balancer. |
| <a name="output_http_tcp_listener_arns"></a> [http\_tcp\_listener\_arns](#output\_http\_tcp\_listener\_arns) | The ARN of the TCP and HTTP load balancer listeners created. |
| <a name="output_http_tcp_listener_ids"></a> [http\_tcp\_listener\_ids](#output\_http\_tcp\_listener\_ids) | The IDs of the TCP and HTTP load balancer listeners created. |
| <a name="output_https_listener_arns"></a> [https\_listener\_arns](#output\_https\_listener\_arns) | The ARNs of the HTTPS load balancer listeners created. |
| <a name="output_https_listener_ids"></a> [https\_listener\_ids](#output\_https\_listener\_ids) | The IDs of the load balancer listeners created. |
| <a name="output_load_balancer_arn_suffix"></a> [load\_balancer\_arn\_suffix](#output\_load\_balancer\_arn\_suffix) | ARN suffix of our load balancer - can be used with CloudWatch. |
| <a name="output_load_balancer_id"></a> [load\_balancer\_id](#output\_load\_balancer\_id) | The ID and ARN of the load balancer we created. |
| <a name="output_load_balancer_zone_id"></a> [load\_balancer\_zone\_id](#output\_load\_balancer\_zone\_id) | The zone\_id of the load balancer to assist with creating DNS records. |
| <a name="output_logging_bucket_arn"></a> [logging\_bucket\_arn](#output\_logging\_bucket\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_logging_bucket_domain_name"></a> [logging\_bucket\_domain\_name](#output\_logging\_bucket\_domain\_name) | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| <a name="output_logging_bucket_hosted_zone_id"></a> [logging\_bucket\_hosted\_zone\_id](#output\_logging\_bucket\_hosted\_zone\_id) | The Route 53 Hosted Zone ID for this bucket's region. |
| <a name="output_logging_bucket_id"></a> [logging\_bucket\_id](#output\_logging\_bucket\_id) | The name of the bucket. |
| <a name="output_logging_bucket_region"></a> [logging\_bucket\_region](#output\_logging\_bucket\_region) | The AWS region this bucket resides in. |
| <a name="output_logging_bucket_regional_domain_name"></a> [logging\_bucket\_regional\_domain\_name](#output\_logging\_bucket\_regional\_domain\_name) | The bucket region-specific domain name. The bucket domain name including the region name. |
| <a name="output_target_group_arn_suffixes"></a> [target\_group\_arn\_suffixes](#output\_target\_group\_arn\_suffixes) | ARN suffixes of our target groups - can be used with CloudWatch. |
| <a name="output_target_group_arns"></a> [target\_group\_arns](#output\_target\_group\_arns) | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| <a name="output_target_group_names"></a> [target\_group\_names](#output\_target\_group\_names) | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| <a name="output_unhealthy_host_alarm_id"></a> [unhealthy\_host\_alarm\_id](#output\_unhealthy\_host\_alarm\_id) | The ID of the health check. |
