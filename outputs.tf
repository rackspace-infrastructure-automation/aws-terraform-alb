#################
#      ALB      #
#################

output "alb_dns_name" {
  value       = aws_lb.alb.dns_name
  description = "The DNS name of the load balancer."
}

output "http_tcp_listener_arns" {
  value       = aws_lb_listener.http.*.arn
  description = "The ARN of the TCP and HTTP load balancer listeners created."
}

output "http_tcp_listener_ids" {
  value       = aws_lb_listener.http.*.id
  description = "The IDs of the TCP and HTTP load balancer listeners created."
}

output "https_listener_arns" {
  value       = aws_lb_listener.https.*.arn
  description = "The ARNs of the HTTPS load balancer listeners created."
}

output "https_listener_ids" {
  value       = aws_lb_listener.https.*.id
  description = "The IDs of the load balancer listeners created."
}

output "load_balancer_arn_suffix" {
  value       = aws_lb.alb.arn_suffix
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
}

output "load_balancer_id" {
  value       = aws_lb.alb.id
  description = "The ID and ARN of the load balancer we created."
}

output "load_balancer_zone_id" {
  value       = aws_lb.alb.zone_id
  description = "The zone_id of the load balancer to assist with creating DNS records."
}

output "target_group_arn_suffixes" {
  value       = aws_lb_target_group.main.*.arn_suffix
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
}

output "target_group_arns" {
  value       = aws_lb_target_group.main.*.arn
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
}

output "target_group_names" {
  value       = aws_lb_target_group.main.*.name
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
}

#################
#      S3       #
#################

output "logging_bucket_id" {
  value       = aws_s3_bucket.log_bucket.*.id
  description = "The name of the bucket."
}

output "logging_bucket_arn" {
  value       = aws_s3_bucket.log_bucket.*.arn
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
}

output "logging_bucket_domain_name" {
  value       = aws_s3_bucket.log_bucket.*.bucket_domain_name
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
}

output "logging_bucket_regional_domain_name" {
  value       = aws_s3_bucket.log_bucket.*.bucket_regional_domain_name
  description = "The bucket region-specific domain name. The bucket domain name including the region name."
}

output "logging_bucket_hosted_zone_id" {
  value       = aws_s3_bucket.log_bucket.*.hosted_zone_id
  description = "The Route 53 Hosted Zone ID for this bucket's region."
}

output "logging_bucket_region" {
  value       = aws_s3_bucket.log_bucket.*.region
  description = "The AWS region this bucket resides in."
}

#################
#  CloudWatch   #
#################

output "unhealthy_host_alarm_id" {
  value       = module.unhealthy_host_count_alarm.alarm_id
  description = "The ID of the health check."
}

