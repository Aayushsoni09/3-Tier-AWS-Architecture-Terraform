# Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Web Tier Launch Template
resource "aws_launch_template" "web_tier" {
  name_prefix   = "${var.project_name}-${var.environment}-web-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.web_instance_type

  iam_instance_profile {
    name = var.web_instance_profile_name
  }

  vpc_security_group_ids = [var.web_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data_web.sh", {
    project_name     = var.project_name
    environment      = var.environment
    region          = data.aws_region.current.name
    verify_header   = var.cloudfront_verify_header
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-web-instance"
      Tier = "Web"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.project_name}-${var.environment}-web-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Web Tier Auto Scaling Group
resource "aws_autoscaling_group" "web_tier" {
  name                = "${var.project_name}-${var.environment}-web-asg"
  vpc_zone_identifier = var.web_subnet_ids
  target_group_arns   = var.web_target_group_arns
  health_check_type   = "ELB"
  health_check_grace_period = 300
  min_size            = var.web_min_size
  max_size            = var.web_max_size
  desired_capacity    = var.web_desired_capacity

  launch_template {
    id      = aws_launch_template.web_tier.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-web-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "Web"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Web Tier Scaling Policies
resource "aws_autoscaling_policy" "web_scale_up" {
  name                   = "${var.project_name}-${var.environment}-web-scale-up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_tier.name
}

resource "aws_autoscaling_policy" "web_scale_down" {
  name                   = "${var.project_name}-${var.environment}-web-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.web_tier.name
}

# Web Tier CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "web_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-web-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale up when CPU exceeds 70%"
  alarm_actions       = [aws_autoscaling_policy.web_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_tier.name
  }
}

resource "aws_cloudwatch_metric_alarm" "web_cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-web-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale down when CPU below 30%"
  alarm_actions       = [aws_autoscaling_policy.web_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.web_tier.name
  }
}

# App Tier Launch Template
resource "aws_launch_template" "app_tier" {
  name_prefix   = "${var.project_name}-${var.environment}-app-"
  image_id      = data.aws_ami.amazon_linux_2023.id
  instance_type = var.app_instance_type

  iam_instance_profile {
    name = var.app_instance_profile_name
  }

  vpc_security_group_ids = [var.app_security_group_id]

  user_data = base64encode(templatefile("${path.module}/user_data_app.sh", {
    project_name  = var.project_name
    environment   = var.environment
    region       = data.aws_region.current.name
    db_secret_arn = var.db_secret_arn
  }))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2 only
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-${var.environment}-app-instance"
      Tier = "Application"
    }
  }

  tag_specifications {
    resource_type = "volume"
    tags = {
      Name = "${var.project_name}-${var.environment}-app-volume"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# App Tier Auto Scaling Group
resource "aws_autoscaling_group" "app_tier" {
  name                = "${var.project_name}-${var.environment}-app-asg"
  vpc_zone_identifier = var.app_subnet_ids
  target_group_arns   = var.app_target_group_arns
  health_check_type   = "ELB"
  health_check_grace_period = 300
  min_size            = var.app_min_size
  max_size            = var.app_max_size
  desired_capacity    = var.app_desired_capacity

  launch_template {
    id      = aws_launch_template.app_tier.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-app-asg"
    propagate_at_launch = true
  }

  tag {
    key                 = "Tier"
    value               = "Application"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# App Tier Scaling Policies
resource "aws_autoscaling_policy" "app_scale_up" {
  name                   = "${var.project_name}-${var.environment}-app-scale-up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_tier.name
}

resource "aws_autoscaling_policy" "app_scale_down" {
  name                   = "${var.project_name}-${var.environment}-app-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app_tier.name
}

# App Tier CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "${var.project_name}-${var.environment}-app-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Scale up when CPU exceeds 70%"
  alarm_actions       = [aws_autoscaling_policy.app_scale_up.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_tier.name
  }
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_low" {
  alarm_name          = "${var.project_name}-${var.environment}-app-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30
  alarm_description   = "Scale down when CPU below 30%"
  alarm_actions       = [aws_autoscaling_policy.app_scale_down.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app_tier.name
  }
}

# Data source for current region
data "aws_region" "current" {}
