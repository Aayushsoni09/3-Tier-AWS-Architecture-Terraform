output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = local.zone_id
}

output "name_servers" {
  description = "Name servers for the hosted zone"
  value       = var.create_hosted_zone ? aws_route53_zone.main[0].name_servers : []
}

output "domain_name" {
  description = "Domain name"
  value       = var.domain_name
}

output "cloudfront_record_fqdn" {
  description = "CloudFront record FQDN"
  value       = aws_route53_record.cloudfront_primary.fqdn
}

output "api_record_fqdn" {
  description = "API record FQDN"
  value       = aws_route53_record.api.fqdn
}
