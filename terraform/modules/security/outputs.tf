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

output "ec2_web_role_name" {
  description = "Web tier IAM role name"
  value       = aws_iam_role.ec2_web_role.name
}

output "ec2_web_instance_profile_name" {
  description = "Web tier instance profile name"
  value       = aws_iam_instance_profile.ec2_web_profile.name
}

output "ec2_app_role_name" {
  description = "App tier IAM role name"
  value       = aws_iam_role.ec2_app_role.name
}

output "ec2_app_instance_profile_name" {
  description = "App tier instance profile name"
  value       = aws_iam_instance_profile.ec2_app_profile.name
}

output "db_secret_arn" {
  description = "Database credentials secret ARN"
  value       = aws_secretsmanager_secret.db_credentials.arn
}

output "db_secret_name" {
  description = "Database credentials secret name"
  value       = aws_secretsmanager_secret.db_credentials.name
}
