# 🏗️ Production-Grade 3-Tier AWS Architecture with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-1.5+-623CE4?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Cloud-FF9900?logo=amazon-aws&logoColor=white)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

A complete, production-ready 3-tier web application architecture deployed on AWS using Infrastructure as Code (Terraform). This project demonstrates enterprise-level cloud architecture patterns with high availability, auto-scaling, security best practices, and comprehensive monitoring.

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Deployment](#deployment)
- [Configuration](#configuration)
- [Monitoring](#monitoring)
- [CI/CD Pipeline](#cicd-pipeline)
- [Cost Optimization](#cost-optimization)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

---

## 🏛️ Architecture Overview

This architecture implements a secure, scalable, and highly available 3-tier application using AWS services:

```mermaid
flowchart TD

    A[Internet] --> B[CloudFront CDN]
    B --> C[Route53 DNS]
    C --> D[Public Application Load Balancer]
    D --> E[Web Tier - EC2 Auto Scaling Group]
    E --> F[Internal Application Load Balancer]
    F --> G[App Tier - EC2 Auto Scaling Group]
    G --> H[RDS PostgreSQL - Multi-AZ]
---

### Architecture Components

**Presentation Tier (Web Layer)**
- CloudFront distribution for global content delivery
- Public Application Load Balancer
- Auto Scaling Group with EC2 instances running Nginx
- Deployed across multiple Availability Zones

**Application Tier (Logic Layer)**
- Internal Application Load Balancer
- Auto Scaling Group with EC2 instances running Node.js
- Isolated in private subnets
- Access to database and S3

**Data Tier (Database Layer)**
- RDS PostgreSQL with Multi-AZ deployment
- Automated backups with 7-day retention
- Enhanced monitoring and Performance Insights
- Completely isolated from internet

### Network Architecture

- **VPC**: Custom VPC with `10.0.0.0/16` CIDR block
- **Subnets**: 8 subnets across 2 Availability Zones
  - 2 Public subnets (ALB)
  - 2 Private web subnets (Web tier)
  - 2 Private app subnets (App tier)
  - 2 Database subnets (RDS)
- **NAT Gateways**: High availability with 2 NAT Gateways
- **Security Groups**: Layered security with least privilege access
- **VPC Flow Logs**: Network traffic monitoring

---

## ✨ Features

### High Availability
- ✅ Multi-AZ deployment across 2 availability zones
- ✅ Auto Scaling Groups with health checks
- ✅ RDS Multi-AZ with automatic failover
- ✅ Route53 health checks and DNS failover
- ✅ Cross-zone load balancing

### Security
- ✅ Network isolation with VPC and subnets
- ✅ Security groups with least privilege access
- ✅ IAM roles and policies (no hardcoded credentials)
- ✅ Encryption at rest (RDS, S3, EBS)
- ✅ Encryption in transit (HTTPS, TLS 1.3)
- ✅ AWS Secrets Manager for database credentials
- ✅ VPC Flow Logs for network monitoring
- ✅ CloudFront Origin Access Control (OAC)

### Scalability
- ✅ Auto Scaling based on CPU metrics
- ✅ Application Load Balancers for traffic distribution
- ✅ CloudFront CDN for static content
- ✅ RDS storage autoscaling
- ✅ Configurable min/max instance counts

### Monitoring & Observability
- ✅ CloudWatch dashboards for all tiers
- ✅ CloudWatch alarms for critical metrics
- ✅ ALB access logs to S3
- ✅ Application logs to CloudWatch Logs
- ✅ RDS Enhanced Monitoring
- ✅ VPC Flow Logs

### Infrastructure as Code
- ✅ 100% Terraform (no manual steps)
- ✅ Modular and reusable code
- ✅ Remote state with S3 + DynamoDB locking
- ✅ Multiple environment support (dev/staging/prod)
- ✅ CI/CD with GitHub Actions

### Cost Optimization
- ✅ Single NAT Gateway option for dev/test
- ✅ Configurable instance types
- ✅ S3 lifecycle policies
- ✅ CloudWatch log retention policies
- ✅ RDS autoscaling storage

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| **Infrastructure** | Terraform 1.5+ |
| **Cloud Provider** | AWS (VPC, EC2, RDS, S3, CloudFront, Route53, ALB) |
| **Web Tier** | Nginx, Amazon Linux 2023 |
| **App Tier** | Node.js, Amazon Linux 2023 |
| **Database** | PostgreSQL 15 (RDS Multi-AZ) |
| **Monitoring** | CloudWatch, CloudWatch Logs, CloudWatch Alarms |
| **CI/CD** | GitHub Actions |
| **Security** | IAM, Security Groups, Secrets Manager, ACM |
| **CDN** | CloudFront with Origin Access Control |
| **DNS** | Route53 with health checks |

---

## 📦 Prerequisites

### Required Tools
- [Terraform](https://www.terraform.io/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) >= 2.0
- [Git](https://git-scm.com/)
- AWS Account with admin access

### AWS Credentials
- aws configure
- Enter your Access Key ID
- Enter your Secret Access Key
- Default region: us-east-1
- Default output: json

### Optional (Recommended)
- Domain name for Route53
- SSL certificate in ACM (for HTTPS)

---

## 🚀 Quick Start

### 1. Clone the Repository
- git clone
- https://github.com/Aayushsoni09/3-Tier-AWS-Architecture-Terraform
- cd aws-3tier-production

### 2. Set Up Backend (One-Time)
- Create S3 bucket and DynamoDB table for Terraform state
- cd terraform
- chmod +x ../backend-setup.sh
- ../backend-setup.sh

## Update `terraform/backend.tf` with your bucket name:
terraform {
backend "s3" {
bucket = "your-unique-bucket-name"
key = "production/terraform.tfstate"
region = "us-east-1"
encrypt = true
dynamodb_table = "terraform-state-lock"
}
}

### 3. Configure Variables
- cp terraform.tfvars.example terraform.tfvars
- vim terraform.tfvars

**Minimum required variables:**
project_name = "my-app"
environment = "dev"
db_username = "admin"
db_password = "YourSecurePassword123!"
allowed_ssh_cidr = ["YOUR_IP/32"]


### 4. Deploy Infrastructure
- Initialize Terraform
terraform init

- Review the plan
terraform plan

- Apply the configuration
terraform apply


⏱️ **Deployment time**: ~15-20 minutes

### 5. Access Your Application
- Get the CloudFront URL
terraform output cloudfront_domain_name

- Or custom domain (if configured)
terraform output website_url


---

## 📁 Project Structure
```bash
aws-3tier-production/
├── README.md
├── LICENSE
├── .gitignore
├── backend-setup.sh

├── terraform/
│   ├── main.tf                      # Root module
│   ├── variables.tf                 # Input variables
│   ├── outputs.tf                   # Output values
│   ├── terraform.tfvars.example     # Example configuration
│   ├── backend.tf                   # Remote state config
│   ├── providers.tf                 # Provider configuration
│   ├── monitoring.tf                # CloudWatch dashboards
│
│   ├── modules/
│   │   ├── networking/              # VPC, subnets, routing
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │
│   │   ├── security/                # Security groups, IAM
│   │   │   ├── main.tf
│   │   │   ├── iam.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │
│   │   ├── compute/                 # EC2, ASG, ALB
│   │   │   ├── main.tf
│   │   │   ├── alb.tf
│   │   │   ├── user_data_web.sh
│   │   │   ├── user_data_app.sh
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │
│   │   ├── database/                # RDS PostgreSQL
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │
│   │   ├── storage/                 # S3 buckets
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │
│   │   ├── cdn/                     # CloudFront distribution
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │
│   │   └── dns/                     # Route53 DNS
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│
│   └── environments/
│       ├── dev.tfvars
│       ├── staging.tfvars
│       └── prod.tfvars
│
├── .github/
│   └── workflows/
│       └── terraform.yml            # CI/CD pipeline
│
└── docs/
    ├── ARCHITECTURE.md
    ├── DEPLOYMENT.md
    ├── TROUBLESHOOTING.md
    └── COST_OPTIMIZATION.md
```


---

## ⚙️ Configuration

### Environment-Specific Configurations

**Development**
terraform/environments/dev.tfvars
environment = "dev"
single_nat_gateway = true
db_multi_az = false
web_min_size = 1
web_max_size = 2
app_min_size = 1
app_max_size = 2

**Production**
- terraform/environments/prod.tfvars
- environment = "prod"
- single_nat_gateway = false
- db_multi_az = true
- web_min_size = 2
- web_max_size = 10
- app_min_size = 2
- app_max_size = 10

### Deploy to Specific Environment
- terraform apply -var-file="environments/prod.tfvars"

---

## 📊 Monitoring

### CloudWatch Dashboard
Automatically created dashboard includes:
- ALB request count and response times
- EC2 CPU utilization and network traffic
- RDS CPU, connections, and storage
- CloudFront requests and error rates
- Auto Scaling Group metrics

**Access**: AWS Console → CloudWatch → Dashboards → `{project-name}-{environment}-dashboard`

### Key Metrics & Alarms

| Metric | Threshold | Action |
|--------|-----------|--------|
| ALB Target Response Time | > 1 second | Alert |
| ALB Unhealthy Hosts | > 0 | Alert |
| ALB 5XX Errors | > 10/5min | Alert |
| EC2 CPU High | > 70% | Scale up |
| EC2 CPU Low | < 30% | Scale down |
| RDS CPU | > 80% | Alert |
| RDS Free Storage | < 5GB | Alert |
| Route53 Health Check | Failed | Failover |

### Log Locations
- **ALB Access Logs**: `s3://{project}-{env}-alb-logs/`
- **Application Logs**: CloudWatch Log Groups → `/aws/ec2/{project}-{env}/`
- **VPC Flow Logs**: CloudWatch Log Groups → `/aws/vpc/{project}-{env}`
- **RDS Logs**: CloudWatch Log Groups → `/aws/rds/`

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow

The project includes a complete CI/CD pipeline that:
- ✅ Validates Terraform code on every PR
- ✅ Runs `terraform plan` and posts results to PR
- ✅ Applies changes on merge to `main` branch
- ✅ Requires manual approval for production

### Setup

1. **Add GitHub Secrets**:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `DB_USERNAME`
   - `DB_PASSWORD`

2. **Create Environment**:
   - Go to Settings → Environments → New environment
   - Name: `production`
   - Add protection rules (require approval)

3. **Workflow Triggers**:
   - **Pull Request**: Validation + Plan
   - **Push to main**: Apply (with approval)

### Manual Deployment
- Plan
terraform plan -out=tfplan

- Apply
terraform apply tfplan


---

## 💰 Cost Optimization

### Monthly Cost Estimates

**Development Environment** (~$87/month)
- 2x t3.micro EC2: $15
- 1x db.t3.micro RDS: $15
- 1x NAT Gateway: $32
- ALB: $20
- S3/CloudFront: $5

**Production Environment** (~$314/month)
- 4x t3.small EC2: $60
- 1x db.t3.medium Multi-AZ: $120
- 2x NAT Gateways: $64
- ALB: $40
- S3/CloudFront: $30

**Production with Reserved Instances** (~$200/month)
- 37% savings with 1-year commitment

### Cost-Saving Tips

1. **Use Single NAT Gateway for Dev**
- single_nat_gateway = true # Saves ~$30/month

2. **Right-size Instances**
- Monitor CloudWatch CPU metrics
- Adjust instance types based on actual usage

3. **Reserved Instances**
- 1-year commitment: 40% savings
- 3-year commitment: 60% savings

4. **Spot Instances for Dev/Test**
- Up to 90% savings
- Not recommended for production

5. **Enable S3 Intelligent-Tiering**
- storage_class = "INTELLIGENT_TIERING"
6. **Schedule Non-Production**
- Stop dev environment at 7 PM
- aws autoscaling set-desired-capacity
--auto-scaling-group-name myapp-dev-web-asg
--desired-capacity 0


---

## 🐛 Troubleshooting

### Common Issues

#### Issue: Terraform Init Fails
**Error**: Backend bucket doesn't exist
**Solution**:
./backend-setup.sh
- Or manually create bucket and DynamoDB table

#### Issue: ALB Health Checks Failing
**Error**: Targets showing unhealthy

**Debug**:
- Check target health
aws elbv2 describe-target-health --target-group-arn <arn>

- SSH to instance via Systems Manager
aws ssm start-session --target i-xxxxx

- Test locally
curl localhost/health


#### Issue: Can't Access Application
**Error**: Timeout when accessing CloudFront/ALB

**Checklist**:
- ✅ Security group allows HTTP/HTTPS from internet
- ✅ Route tables configured correctly
- ✅ Internet Gateway attached
- ✅ Instances in correct subnets
- ✅ CloudFront distribution deployed (10-15 min)

#### Issue: High Costs
**Solution**:
- Check running resources
aws ec2 describe-instances --filters "Name=instance-state-name,Values=running"

- Review Cost Explorer in AWS Console
Delete unused EBS volumes, EIPs, NAT Gateways


#### Issue: Database Connection Fails
**Error**: Can't connect to RDS

**Debug**:
- ✅ Check security group allows port 5432 from app tier
- ✅ Verify RDS endpoint in Secrets Manager
- ✅ Test from app tier instance
psql -h <endpoint> -U admin -d appdb


### Getting Help
- 📖 [Full Documentation](./docs/)
- 🐛 [Open an Issue](https://github.com/Aayushsoni09/3-Tier-AWS-Architecture-Terraform/issues)
- 💬 [Discussions](https://github.com/Aayushsoni09/3-Tier-AWS-Architecture-Terraform/discussions)

---

## 🧪 Testing

### Infrastructure Tests
- Validate Terraform syntax
terraform validate

- Check formatting
terraform fmt -check -recursive

- Security scan with tfsec
tfsec terraform/

- Cost estimation with Infracost
infracost breakdown --path terraform/


### Application Tests
Test ALB endpoint
curl -I https://$(terraform output -raw alb_dns_name)

Test health endpoint
curl https://$(terraform output -raw cloudfront_domain_name)/health

Load test with Apache Bench
ab -n 1000 -c 10 https://your-domain.com/

---

## 🧹 Cleanup

### Destroy Infrastructure
- Review what will be destroyed
terraform plan -destroy

- Destroy all resources
terraform destroy

- Confirm when prompted

⚠️ **Warning**: This will delete ALL resources including databases (unless deletion protection is enabled).

### Cost After Cleanup
- S3 buckets with data retention
- CloudWatch logs with retention policies
- Terraform state in S3

**Estimated cost after cleanup**: ~$1-2/month

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork the repository**
2. **Create a feature branch**
- git checkout -b feature/amazing-feature
3. **Commit your changes**
- git commit -m 'Add amazing feature'
4. **Push to the branch**
- git push origin feature/amazing-feature
5. **Open a Pull Request**

### Code Standards
- Follow Terraform style guide
- Run `terraform fmt` before committing
- Add comments for complex logic
- Update documentation

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Aayush Soni**
- GitHub: [@Aayushsoni09](https://github.com/Aayushsoni09)
- LinkedIn: [LinkedIn](https://linkedin.com/in/aayush-soni-09)
- Portfolio: [Portfolio](https://www.monkweb.tech)

---

## 🌟 Acknowledgments

- AWS Architecture Best Practices
- HashiCorp Terraform Documentation
- AWS Well-Architected Framework
- AWS Solutions Library

---

## 📚 Additional Resources

- [AWS 3-Tier Architecture Workshop](https://catalog.workshops.aws/three-tier-architecture)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

---

## 🔖 Tags

`aws` `terraform` `infrastructure-as-code` `devops` `cloud-architecture` `3-tier-architecture` `high-availability` `auto-scaling` `load-balancer` `rds` `cloudfront` `route53` `vpc` `ci-cd` `github-actions` `production-ready`

---

<div align="center">

### ⭐ Star this repository if you found it helpful!

**Made with ❤️ by Cloud Engineers, for Cloud Engineers**

</div>
