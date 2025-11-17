output "web_asg_id" {
  description = "Web tier Auto Scaling Group ID"
  value       = aws_autoscaling_group.web_tier.id
}

output "web_asg_name" {
  description = "Web tier Auto Scaling Group name"
  value       = aws_autoscaling_group.web_tier.name
}

output "app_asg_id" {
  description = "App tier Auto Scaling Group ID"
  value       = aws_autoscaling_group.app_tier.id
}

output "app_asg_name" {
  description = "App tier Auto Scaling Group name"
  value       = aws_autoscaling_group.app_tier.name
}

output "web_launch_template_id" {
  description = "Web tier launch template ID"
  value       = aws_launch_template.web_tier.id
}

output "app_launch_template_id" {
  description = "App tier launch template ID"
  value       = aws_launch_template.app_tier.id
}

output "public_alb_dns_name" {
  description = "Public ALB DNS name"
  value       = aws_lb.public.dns_name
}

output "public_alb_arn" {
  description = "Public ALB ARN"
  value       = aws_lb.public.arn
}

output "internal_alb_dns_name" {
  description = "Internal ALB DNS name"
  value       = aws_lb.internal.dns_name
}

output "web_target_group_arn" {
  description = "Web tier target group ARN"
  value       = aws_lb_target_group.web.arn
}

output "app_target_group_arn" {
  description = "App tier target group ARN"
  value       = aws_lb_target_group.app.arn
}
