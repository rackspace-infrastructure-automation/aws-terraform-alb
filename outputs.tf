output "alb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.alb.dns_name
}

output "http_tcp_listener_arns" {
  description = "The ARN of the TCP and HTTP load balancer listeners created."
  value       = aws_lb_listener.http.*.arn
}

output "http_tcp_listener_ids" {
  description = "The IDs of the TCP and HTTP load balancer listeners created."
  value       = aws_lb_listener.http.*.id
}

output "https_listener_arns" {
  description = "The ARNs of the HTTPS load balancer listeners created."
  value       = aws_lb_listener.https.*.arn
}

output "https_listener_ids" {
  description = "The IDs of the load balancer listeners created."
  value       = aws_lb_listener.https.*.id
}

output "load_balancer_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = aws_lb.alb.arn_suffix
}

output "load_balancer_id" {
  description = "The ID and ARN of the load balancer we created."
  value       = aws_lb.alb.id
}

output "load_balancer_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = aws_lb.alb.zone_id
}

output "logging_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = aws_s3_bucket.log_bucket.*.arn
}

output "logging_bucket_domain_name" {
  description = "The bucket domain name. Will be of format bucketname.s3.amazonaws.com."
  value       = aws_s3_bucket.log_bucket.*.bucket_domain_name
}

output "logging_bucket_hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID for this bucket's region."
  value       = aws_s3_bucket.log_bucket.*.hosted_zone_id
}

output "logging_bucket_id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.log_bucket.*.id
}

output "logging_bucket_region" {
  description = "The AWS region this bucket resides in."
  value       = aws_s3_bucket.log_bucket.*.region
}

output "logging_bucket_regional_domain_name" {
  description = "The bucket region-specific domain name. The bucket domain name including the region name."
  value       = aws_s3_bucket.log_bucket.*.bucket_regional_domain_name
}

output "target_group_arn_suffixes" {
  description = "ARN suffixes of our target groups - can be used with CloudWatch."
  value       = aws_lb_target_group.main.*.arn_suffix
}

output "target_group_arns" {
  description = "ARNs of the target groups. Useful for passing to your Auto Scaling group."
  value       = aws_lb_target_group.main.*.arn
}

output "target_group_names" {
  description = "Name of the target group. Useful for passing to your CodeDeploy Deployment Group."
  value       = aws_lb_target_group.main.*.name
}

output "unhealthy_host_alarm_id" {
  description = "The ID of the health check."
  value       = module.unhealthy_host_count_alarm.alarm_id
}
