variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "web_subnet_ids" {
  description = "Web tier subnet IDs"
  type        = list(string)
}

variable "app_subnet_ids" {
  description = "App tier subnet IDs"
  type        = list(string)
}

variable "web_security_group_id" {
  description = "Web tier security group ID"
  type        = string
}

variable "app_security_group_id" {
  description = "App tier security group ID"
  type        = string
}

variable "web_instance_profile_name" {
  description = "Web tier IAM instance profile name"
  type        = string
}

variable "app_instance_profile_name" {
  description = "App tier IAM instance profile name"
  type        = string
}

variable "web_target_group_arns" {
  description = "Web tier target group ARNs"
  type        = list(string)
}

variable "app_target_group_arns" {
  description = "App tier target group ARNs"
  type        = list(string)
}

variable "web_instance_type" {
  description = "Web tier instance type"
  type        = string
  default     = "t3.micro"
}

variable "app_instance_type" {
  description = "App tier instance type"
  type        = string
  default     = "t3.micro"
}

variable "web_min_size" {
  description = "Web tier minimum instances"
  type        = number
  default     = 2
}

variable "web_max_size" {
  description = "Web tier maximum instances"
  type        = number
  default     = 6
}

variable "web_desired_capacity" {
  description = "Web tier desired capacity"
  type        = number
  default     = 2
}

variable "app_min_size" {
  description = "App tier minimum instances"
  type        = number
  default     = 2
}

variable "app_max_size" {
  description = "App tier maximum instances"
  type        = number
  default     = 6
}

variable "app_desired_capacity" {
  description = "App tier desired capacity"
  type        = number
  default     = 2
}

variable "db_secret_arn" {
  description = "Database secret ARN"
  type        = string
}

variable "cloudfront_verify_header" {
  description = "CloudFront verification header"
  type        = string
  sensitive   = true
}
variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "Public ALB security group ID"
  type        = string
}

variable "internal_alb_security_group_id" {
  description = "Internal ALB security group ID"
  type        = string
}

variable "private_web_subnet_ids" {
  description = "Private web subnet IDs for internal ALB"
  type        = list(string)
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}
variable "alb_logs_bucket" {
  description = "S3 bucket for ALB access logs"
  type        = string
}
