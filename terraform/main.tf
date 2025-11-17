# Networking Module
module "networking" {
  source = "./modules/networking"

  project_name       = var.project_name
  environment        = var.environment
  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  
  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway
}

# Security Module
module "security" {
  source = "./modules/security"

  project_name      = var.project_name
  environment       = var.environment
  vpc_id           = module.networking.vpc_id
  vpc_cidr         = module.networking.vpc_cidr
  allowed_ssh_cidr = var.allowed_ssh_cidr
  
  s3_bucket_arn    = module.storage.bucket_arn
  db_username      = var.db_username
  db_password      = var.db_password
  db_endpoint      = module.database.db_instance_endpoint
  db_port          = module.database.db_instance_port
  db_name          = module.database.db_instance_name
}

# Database Module
module "database" {
  source = "./modules/database"

  project_name         = var.project_name
  environment          = var.environment
  subnet_ids           = module.networking.database_subnet_ids
  security_group_ids   = [module.security.database_security_group_id]
  
  database_name        = var.db_name
  master_username      = var.db_username
  master_password      = var.db_password
  instance_class       = var.db_instance_class
  multi_az            = var.db_multi_az
  
  deletion_protection  = var.environment == "prod" ? true : false
  skip_final_snapshot = var.environment != "prod" ? true : false
}

# Storage Module
module "storage" {
  source = "./modules/storage"
  project_name  = var.project_name
  environment   = var.environment
  force_destroy = var.environment != "prod" ? true : false
}

# Compute Module (includes ALB)
module "compute" {
  source = "./modules/compute"
  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  
  # Subnets
  public_subnet_ids      = module.networking.public_subnet_ids
  web_subnet_ids         = module.networking.private_web_subnet_ids
  app_subnet_ids         = module.networking.private_app_subnet_ids
  private_web_subnet_ids = module.networking.private_web_subnet_ids
  
  # Security Groups
  alb_security_group_id          = module.security.alb_security_group_id
  web_security_group_id          = module.security.web_tier_security_group_id
  internal_alb_security_group_id = module.security.internal_alb_security_group_id
  app_security_group_id          = module.security.app_tier_security_group_id
  
  # IAM
  web_instance_profile_name = module.security.ec2_web_instance_profile_name
  app_instance_profile_name = module.security.ec2_app_instance_profile_name
  
  # Instance Configuration
  web_instance_type = var.web_instance_type
  app_instance_type = var.app_instance_type
  
  # Auto Scaling
  web_min_size         = var.web_min_size
  web_max_size         = var.web_max_size
  web_desired_capacity = var.web_min_size
  app_min_size         = var.app_min_size
  app_max_size         = var.app_max_size
  app_desired_capacity = var.app_min_size
  
  # Database
  db_secret_arn = module.security.db_secret_arn
  
  # CloudFront verification
  cloudfront_verify_header = module.cdn.origin_verify_header
  
  # SSL
  acm_certificate_arn = var.acm_certificate_arn
  
  # Target Groups (output from this module's ALB resources)
  web_target_group_arns = [module.compute.web_target_group_arn]
  app_target_group_arns = [module.compute.app_target_group_arn]
}

# CDN Module
module "cdn" {
  source = "./modules/cdn"

  project_name          = var.project_name
  environment           = var.environment
  s3_bucket_domain_name = module.storage.bucket_domain_name
  s3_bucket_id          = module.storage.bucket_id
  s3_bucket_arn         = module.storage.bucket_arn
  alb_dns_name          = module.compute.public_alb_dns_name
  
  domain_name         = var.domain_name
  acm_certificate_arn = var.acm_certificate_arn
  
  price_class = var.environment == "prod" ? "PriceClass_All" : "PriceClass_100"
}

# DNS Module
module "dns" {
  count  = var.domain_name != "" ? 1 : 0
  source = "./modules/dns"

  project_name              = var.project_name
  environment               = var.environment
  domain_name               = var.domain_name
  create_hosted_zone        = var.create_hosted_zone
  hosted_zone_id            = var.hosted_zone_id
  
  cloudfront_domain_name    = module.cdn.cloudfront_domain_name
  cloudfront_hosted_zone_id = module.cdn.cloudfront_hosted_zone_id
  
  alb_dns_name              = module.compute.public_alb_dns_name
  alb_zone_id               = module.compute.public_alb_zone_id
  
  enable_health_checks      = var.environment == "prod" ? true : false
}
