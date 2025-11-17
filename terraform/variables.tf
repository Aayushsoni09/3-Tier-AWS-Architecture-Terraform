# General Variables
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "aws-3tier"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Project owner"
  type        = string
  default     = "DevOps Team"
}

# Network Variables
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Compute Variables
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

# Database Variables
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = true
}

# DNS Variables
variable "domain_name" {
  description = "Domain name for Route53"
  type        = string
  default     = ""
}

variable "create_hosted_zone" {
  description = "Create new Route53 hosted zone"
  type        = bool
  default     = false
}

variable "hosted_zone_id" {
  description = "Existing Route53 hosted zone ID"
  type        = string
  default     = ""
}

# SSL Certificate
variable "acm_certificate_arn" {
  description = "ACM certificate ARN for HTTPS"
  type        = string
  default     = ""
}

# Security
variable "allowed_ssh_cidr" {
  description = "CIDR blocks allowed for SSH"
  type        = list(string)
  default     = []
}

# Cost Optimization
variable "single_nat_gateway" {
  description = "Use single NAT Gateway (cost optimization)"
  type        = bool
  default     = false
}
