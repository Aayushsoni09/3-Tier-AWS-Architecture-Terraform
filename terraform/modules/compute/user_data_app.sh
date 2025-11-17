#!/bin/bash
set -e

# Update system
dnf update -y

# Install CloudWatch agent
dnf install -y amazon-cloudwatch-agent

# Install Node.js
dnf install -y nodejs npm

# Install PostgreSQL client
dnf install -y postgresql15

# Install jq for JSON parsing
dnf install -y jq

# Create application directory
mkdir -p /opt/app
cd /opt/app

# Get database credentials from Secrets Manager
aws secretsmanager get-secret-value \
    --secret-id ${db_secret_arn} \
    --region ${region} \
    --query SecretString \
    --output text > /opt/app/db-credentials.json

# Sample Node.js API application
cat > /opt/app/server.js <<'EOFJS'
const http = require('http');
const { Client } = require('pg');
const fs = require('fs');

// Read database credentials
const dbCreds = JSON.parse(fs.readFileSync('/opt/app/db-credentials.json', 'utf8'));

const dbClient = new Client({
  host: dbCreds.host,
  port: dbCreds.port,
  database: dbCreds.dbname,
  user: dbCreds.username,
  password: dbCreds.password,
});

// Connect to database
dbClient.connect().catch(err => console.error('Database connection error:', err));

const server = http.createServer((req, res) => {
  if (req.url === '/health') {
    res.writeHead(200, { 'Content-Type': 'text/plain' });
    res.end('healthy\n');
  } else if (req.url === '/api/info') {
    const metadata = require('http').request({
      host: '169.254.169.254',
      path: '/latest/dynamic/instance-identity/document'
    }, (metaRes) => {
      let data = '';
      metaRes.on('data', chunk => data += chunk);
      metaRes.on('end', () => {
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
          message: 'App Tier Response',
          instance: JSON.parse(data),
          timestamp: new Date().toISOString()
        }));
      });
    });
    metadata.end();
  } else {
    res.writeHead(404);
    res.end('Not Found\n');
  }
});

const PORT = 8080;
server.listen(PORT, () => {
  console.log(`App tier server running on port ${PORT}`);
});
EOFJS

# Create package.json
cat > /opt/app/package.json <<'EOF'
{
  "name": "app-tier",
  "version": "1.0.0",
  "dependencies": {
    "pg": "^8.11.0"
  }
}
EOF

# Install dependencies
npm install

# Create systemd service
cat > /etc/systemd/system/app-tier.service <<'EOF'
[Unit]
Description=App Tier Service
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/app
ExecStart=/usr/bin/node /opt/app/server.js
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Start application
systemctl enable app-tier
systemctl start app-tier

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/config.json <<'EOF'
{
  "metrics": {
    "namespace": "${project_name}/${environment}/AppTier",
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
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/${project_name}-${environment}/app/system",
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

echo "App tier initialization complete"
