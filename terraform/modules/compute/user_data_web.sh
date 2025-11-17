#!/bin/bash
set -e

# Update system
dnf update -y

# Install CloudWatch agent
dnf install -y amazon-cloudwatch-agent

# Install Node.js (for web app)
dnf install -y nodejs npm

# Install Nginx
dnf install -y nginx

# Create application directory
mkdir -p /var/www/html
cd /var/www/html

# Sample web application
cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>${project_name} - ${environment}</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        h1 { color: #232F3E; }
        .info { background: #f0f0f0; padding: 20px; margin: 20px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>${project_name}</h1>
    <h2>Environment: ${environment}</h2>
    <div class="info">
        <p>Instance ID: <span id="instance-id">Loading...</span></p>
        <p>Availability Zone: <span id="az">Loading...</span></p>
        <p>Region: ${region}</p>
    </div>
    <script>
        fetch('http://169.254.169.254/latest/dynamic/instance-identity/document', {
            headers: { 'X-aws-ec2-metadata-token': '' }
        })
        .then(response => response.json())
        .then(data => {
            document.getElementById('instance-id').textContent = data.instanceId;
            document.getElementById('az').textContent = data.availabilityZone;
        })
        .catch(error => console.error('Error fetching metadata:', error));
    </script>
</body>
</html>
EOF

# Configure Nginx
cat > /etc/nginx/conf.d/app.conf <<'EOF'
server {
    listen 80;
    server_name _;
    
    # Verify CloudFront header
    if ($http_x_custom_header != "${verify_header}") {
        return 403;
    }
    
    root /var/www/html;
    index index.html;
    
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
}
EOF

# Start and enable Nginx
systemctl enable nginx
systemctl start nginx

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'EOF'
{
  "metrics": {
    "namespace": "${project_name}/${environment}/WebTier",
    "metrics_collected": {
      "cpu": {
        "measurement": [{"name": "cpu_usage_idle"}],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [{"name": "used_percent"}],
        "metrics_collection_interval": 60,
        "resources": ["*"]
      },
      "mem": {
        "measurement": [{"name": "mem_used_percent"}],
        "metrics_collection_interval": 60
      }
    }
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/nginx/access.log",
            "log_group_name": "/aws/ec2/${project_name}-${environment}/web/nginx-access",
            "log_stream_name": "{instance_id}"
          },
          {
            "file_path": "/var/log/nginx/error.log",
            "log_group_name": "/aws/ec2/${project_name}-${environment}/web/nginx-error",
            "log_stream_name": "{instance_id}"
          }
        ]
      }
    }
  }
}
EOF

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/config.json

echo "Web tier initialization complete"
