# Hosted Zone (create new or use existing)
resource "aws_route53_zone" "main" {
  count = var.create_hosted_zone ? 1 : 0
  name  = var.domain_name

  tags = {
    Name        = "${var.project_name}-${var.environment}-hosted-zone"
    Environment = var.environment
  }
}

data "aws_route53_zone" "existing" {
  count   = var.create_hosted_zone ? 0 : 1
  zone_id = var.hosted_zone_id
}

locals {
  zone_id = var.create_hosted_zone ? aws_route53_zone.main[0].zone_id : data.aws_route53_zone.existing[0].zone_id
}

# CloudFront Primary Record (Active)
resource "aws_route53_record" "cloudfront_primary" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "cloudfront-primary"
  
  health_check_id = var.enable_health_checks ? aws_route53_health_check.cloudfront[0].id : null
  
  failover_routing_policy {
    type = "PRIMARY"
  }

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# ALB Failover Record (Secondary)
resource "aws_route53_record" "alb_secondary" {
  zone_id = local.zone_id
  name    = var.domain_name
  type    = "A"

  set_identifier = "alb-secondary"
  
  failover_routing_policy {
    type = "SECONDARY"
  }

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Health Check for CloudFront
resource "aws_route53_health_check" "cloudfront" {
  count             = var.enable_health_checks ? 1 : 0
  fqdn              = var.cloudfront_domain_name
  port              = 443
  type              = "HTTPS"
  resource_path     = "/health"
  failure_threshold = 3
  request_interval  = 30

  tags = {
    Name = "${var.project_name}-${var.environment}-cloudfront-health"
  }
}

# CloudWatch Alarm for Health Check
resource "aws_cloudwatch_metric_alarm" "health_check" {
  count               = var.enable_health_checks ? 1 : 0
  alarm_name          = "${var.project_name}-${var.environment}-route53-health-check-failed"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HealthCheckStatus"
  namespace           = "AWS/Route53"
  period              = 60
  statistic           = "Minimum"
  threshold           = 1
  alarm_description   = "Alert when Route53 health check fails"

  dimensions = {
    HealthCheckId = aws_route53_health_check.cloudfront[0].id
  }
}

# WWW subdomain
resource "aws_route53_record" "www" {
  zone_id = local.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}

# API subdomain pointing to ALB
resource "aws_route53_record" "api" {
  zone_id = local.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}
