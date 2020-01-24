# aws-terraform-alb  
This module deploys an Application Load Balancer with associated resources, such as an unhealthy host count CloudWatch alarm, S3 log bucket, and Route 53 internal zone record.

## Basic Usage

```HCL
module "alb" {
 source = "git@github.com:rackspace-infrastructure-automation/aws-terraform-alb//?ref=v0.12.0"

 http_listeners_count = 1
 name                 = "MyALB"
 security_groups      = ["${module.sg.public_web_security_group_id}"]
 subnets              = ["${module.vpc.public_subnets}"]
 target_groups_count  = 1
 vpc_id               = "${module.vpc.vpc_id}"

 http_listeners = [{
   port     = 80
   protocol = "HTTP"
 }]

 target_groups = [{
   backend_port     = 80
   backend_protocol = "HTTP"
   name             = "MyTargetGroup"
 }]
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

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.1.0 |
| null | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| add\_waf | Add an existing Regional WAF to the ALB. true \| false | `bool` | `false` | no |
| create\_internal\_zone\_record | Create Route 53 internal zone record for the ALB. i.e true \| false | `bool` | `false` | no |
| create\_logging\_bucket | Create a new S3 logging bucket. i.e. true \| false | `bool` | `true` | no |
| enable\_deletion\_protection | If true, deletion of the load balancer will be disabled via the AWS API. This will prevent Terraform from deleting the load balancer. Defaults to false. | `bool` | `false` | no |
| enable\_http2 | If true sets HTTP/2 to enabled. | `bool` | `true` | no |
| enable\_https\_redirect | If true and at least one HTTP and one HTTPS listener is created, HTTP listeners will have a redirect rule created to forward all traffic to the first HTTPS listener. | `bool` | `false` | no |
| environment | Application environment for which this network is being created. one of: ('Development', 'Integration', 'PreProduction', 'Production', 'QA', 'Staging', 'Test') | `string` | `"Development"` | no |
| extra\_ssl\_certs | A list of maps describing any extra SSL certificates to apply to the HTTPS listeners. Certificates must be in the same region as the ALB. Required key/values: certificate\_arn, https\_listener\_index (the index of the listener within https\_listeners which the cert applies toward). [{'certificate\_arn', 'arn:aws:iam::123456789012:server-certificate/other\_test\_cert-123456789012', 'https\_listener\_index', 1}] | `list(map(string))` | `[]` | no |
| extra\_ssl\_certs\_count | The number of extra ssl certs to be added. | `number` | `0` | no |
| http\_listeners | List of Maps of HTTP listeners (port, protocol, target\_group\_index). i.e. [{'port', 80 , 'protocol', 'HTTP'}, {'port', 8080, 'protocol', 'HTTP'}] | `list(map(string))` | <pre>[<br>  {<br>    "port": 80,<br>    "protocol": "HTTP"<br>  }<br>]<br></pre> | no |
| http\_listeners\_count | The number of HTTP listeners to be created. | `number` | `1` | no |
| https\_listeners | List of Maps of HTTPS listeners. Certificate must be in the same region as the ALB. (port, certificate\_arn, ssl\_policy (optional: defaults to ELBSecurityPolicy-2016-08), target\_group\_index (optional: defaults to 0)) i.e. [{'certificate\_arn', 'arn:aws:iam::123456789012:server-certificate/test\_cert-123456789012', 'port', 443}] | `list(map(string))` | `[]` | no |
| https\_listeners\_count | The number of HTTPS listeners to be created. | `string` | `0` | no |
| idle\_timeout | The idle timeout value, in seconds. The valid range is 1-3600. The default is 60 seconds. | `number` | `60` | no |
| internal\_record\_name | Record Name for the new Resource Record in the Internal Hosted Zone. i.e. alb.example.com | `string` | `""` | no |
| internal\_zone\_id | The Route53 Internal Hosted Zone ID. | `string` | `""` | no |
| kms\_key\_id | The AWS KMS master key ID used for the SSE-KMS encryption. This can only be used when you set the value of sse\_algorithm as aws:kms. | `string` | `""` | no |
| load\_balancer\_create\_timeout | Timeout value when creating the ALB. | `string` | `"10m"` | no |
| load\_balancer\_delete\_timeout | Timeout value when deleting the ALB. | `string` | `"10m"` | no |
| load\_balancer\_is\_internal | Indicates whether the load balancer is Internet-facing or internal. i.e. true \| false | `bool` | `false` | no |
| load\_balancer\_update\_timeout | Timeout value when updating the ALB. | `string` | `"10m"` | no |
| logging\_bucket\_acl | Define ACL for Bucket. Must be either authenticated-read, aws-exec-read, bucket-owner-read, bucket-owner-full-control, log-delivery-write, private, public-read or public-read-write. Via https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html#canned-acl | `string` | `"bucket-owner-full-control"` | no |
| logging\_bucket\_encyption | Enable default bucket encryption. i.e. AES256 \| aws:kms | `string` | `"AES256"` | no |
| logging\_bucket\_force\_destroy | Whether all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. ie. true \| false | `bool` | `false` | no |
| logging\_bucket\_name | The name of the S3 bucket for the access logs. The bucket name can contain only lowercase letters, numbers, periods (.), and dashes (-). If creating a new logging bucket enter desired bucket name. | `string` | `""` | no |
| logging\_bucket\_prefix | The prefix for the location in the S3 bucket. If you don't specify a prefix, the access logs are stored in the root of the bucket. Entry must not start with a / or end with one. i.e. 'logs' or 'data/logs' | `string` | n/a | yes |
| logging\_bucket\_retention | The number of days to retain load balancer logs.  Parameter is ignored if not creating a new S3 bucket. i.e. between 1 - 999 | `number` | `14` | no |
| name | A name for the load balancer, which must be unique within your AWS account. | `string` | n/a | yes |
| notification\_topic | List of SNS Topic ARNs to use for customer notifications. | `list(string)` | `[]` | no |
| rackspace\_alarms\_enabled | Specifies whether alarms will create a Rackspace ticket.  Ignored if rackspace\_managed is set to false. | `bool` | `false` | no |
| rackspace\_managed | Boolean parameter controlling if instance will be fully managed by Rackspace support teams, created CloudWatch alarms that generate tickets, and utilize Rackspace managed SSM documents. | `bool` | `true` | no |
| register\_instance\_targets | List of Maps with the index of the target group and the instance id being registered with that group. i.e. [{'instance\_id' : 'i-052f1856e2a471b74', 'target\_group\_index' : 0}, {'instance\_id' : 'i-0cc4b566324707026', 'target\_group\_index' : 0}] | `list(map(string))` | `[]` | no |
| register\_instance\_targets\_count | Count of ec2 instances being added to the target groups. | `number` | `0` | no |
| security\_groups | A list of EC2 security group ids to assign to this resource. i.e. ['sg-edcd9784', 'sg-edcd9785'] | `list(string)` | n/a | yes |
| subnets | A list of at least two IDs of the subnets to associate with the load balancer. i.e ['subnet-abcde012', 'subnet-bcde012a'] | `list(string)` | n/a | yes |
| tags | A map of tags to be applied to the ALB. i.e {Environment='Development'} | `map(string)` | `{}` | no |
| target\_groups | A list of maps containing key/value pairs that define the target groups to be created. Order of these maps is important and the index of these are to be referenced in listener definitions. Optional key/values are in the target\_groups\_defaults variable. i.e. [{'name', 'foo', 'backend\_protocol', 'HTTP', 'backend\_port', '80'}] | `list(map(string))` | <pre>[<br>  {<br>    "backend_port": 80,<br>    "backend_protocol": "HTTP",<br>    "name": "ALB-TargetGroup"<br>  }<br>]<br></pre> | no |
| target\_groups\_count | The number of target groups to create | `number` | `1` | no |
| target\_groups\_defaults | Default values for target groups as defined by the list of maps. i.e. [{ 'cookie\_duration': 86400, 'deregistration\_delay': 300, 'health\_check\_healthy\_threshold': 3, 'health\_check\_interval': 10, 'health\_check\_matcher': '200-299', 'health\_check\_path': '/', 'health\_check\_port': 'traffic-port', 'health\_check\_timeout': 5, 'health\_check\_unhealthy\_threshold': 3, 'stickiness\_enabled': true, 'target\_type': 'instance' }] | `list(map(string))` | <pre>[<br>  {<br>    "cookie_duration": 86400,<br>    "deregistration_delay": 30,<br>    "health_check_healthy_threshold": 5,<br>    "health_check_interval": 30,<br>    "health_check_matcher": "200-299",<br>    "health_check_path": "/",<br>    "health_check_port": "traffic-port",<br>    "health_check_timeout": 5,<br>    "health_check_unhealthy_threshold": 2,<br>    "slow_start": 0,<br>    "stickiness_enabled": false,<br>    "target_type": "instance"<br>  }<br>]<br></pre> | no |
| vpc\_id | The VPC in which your targets are located. i.e. vpc-abcde012 | `string` | n/a | yes |
| waf\_id | The unique identifier (ID) for the Regional Web Application Firewall (WAF) ACL. i.e. 329d10ec-e221-49d1-9f4b-e1294150d292 | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| alb\_dns\_name | The DNS name of the load balancer. |
| http\_tcp\_listener\_arns | The ARN of the TCP and HTTP load balancer listeners created. |
| http\_tcp\_listener\_ids | The IDs of the TCP and HTTP load balancer listeners created. |
| https\_listener\_arns | The ARNs of the HTTPS load balancer listeners created. |
| https\_listener\_ids | The IDs of the load balancer listeners created. |
| load\_balancer\_arn\_suffix | ARN suffix of our load balancer - can be used with CloudWatch. |
| load\_balancer\_id | The ID and ARN of the load balancer we created. |
| load\_balancer\_zone\_id | The zone\_id of the load balancer to assist with creating DNS records. |
| logging\_bucket\_arn | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| logging\_bucket\_domain\_name | The bucket domain name. Will be of format bucketname.s3.amazonaws.com. |
| logging\_bucket\_hosted\_zone\_id | The Route 53 Hosted Zone ID for this bucket's region. |
| logging\_bucket\_id | The name of the bucket. |
| logging\_bucket\_region | The AWS region this bucket resides in. |
| logging\_bucket\_regional\_domain\_name | The bucket region-specific domain name. The bucket domain name including the region name. |
| target\_group\_arn\_suffixes | ARN suffixes of our target groups - can be used with CloudWatch. |
| target\_group\_arns | ARNs of the target groups. Useful for passing to your Auto Scaling group. |
| target\_group\_names | Name of the target group. Useful for passing to your CodeDeploy Deployment Group. |
| unhealthy\_host\_alarm\_id | The ID of the health check. |

