# Networking Outputs
output "vpc_id" {
  description = "VPC ID"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.networking.public_subnet_ids
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "Public ALB DNS name"
  value       = module.compute.public_alb_dns_name
}

# CloudFront Outputs
output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name"
  value       = module.cdn.cloudfront_domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  value       = module.cdn.cloudfront_distribution_id
}

# DNS Outputs
output "website_url" {
  description = "Website URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "https://${module.cdn.cloudfront_domain_name}"
}

output "api_url" {
  description = "API URL"
  value       = var.domain_name != "" ? "https://api.${var.domain_name}" : "https://${module.compute.public_alb_dns_name}"
}

# Database Outputs
output "database_endpoint" {
  description = "Database endpoint"
  value       = module.database.db_instance_endpoint
  sensitive   = true
}

# Storage Outputs
output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = module.storage.bucket_id
}

# Auto Scaling Outputs
output "web_asg_name" {
  description = "Web tier Auto Scaling Group name"
  value       = module.compute.web_asg_name
}

output "app_asg_name" {
  description = "App tier Auto Scaling Group name"
  value       = module.compute.app_asg_name
}

# Instructions
output "deployment_instructions" {
  description = "Next steps"
  value = <<-EOT
  
  ✅ Infrastructure deployed successfully!
  
  📋 Next Steps:
  
  1. Access your application:
     ${var.domain_name != "" ? "https://${var.domain_name}" : "https://${module.cdn.cloudfront_domain_name}"}
  
  2. Upload static assets to S3:
     aws s3 sync ./static-assets s3://${module.storage.bucket_id}/
  
  3. Monitor your infrastructure:
     - CloudWatch Dashboard: https://console.aws.amazon.com/cloudwatch
     - EC2 Auto Scaling: https://console.aws.amazon.com/ec2autoscaling
  
  4. View logs:
     - ALB logs: s3://${module.compute.alb_logs_bucket}/
     - Application logs: CloudWatch Log Groups
  
  5. Database connection (from app tier):
     Endpoint: ${module.database.db_instance_endpoint}
     Credentials are stored in AWS Secrets Manager
  
  💰 Cost optimization tips:
  - Set single_nat_gateway = true to save ~$30/month
  - Use Spot instances for non-production
  - Enable S3 Intelligent-Tiering
  
  EOT
}
