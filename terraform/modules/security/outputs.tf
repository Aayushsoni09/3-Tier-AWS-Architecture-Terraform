output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "web_tier_security_group_id" {
  description = "Web Tier Security Group ID"
  value       = aws_security_group.web_tier.id
}

output "internal_alb_security_group_id" {
  description = "Internal ALB Security Group ID"
  value       = aws_security_group.internal_alb.id
}

output "app_tier_security_group_id" {
  description = "App Tier Security Group ID"
  value       = aws_security_group.app_tier.id
}

output "database_security_group_id" {
  description = "Database Security Group ID"
  value       = aws_security_group.database.id
}

output "bastion_security_group_id" {
  description = "Bastion Security Group ID"
  value       = aws_security_group.bastion.id
}
