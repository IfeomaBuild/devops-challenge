#!/bin/bash
set -euxo pipefail

# Update the system
dnf update -y

# Install Docker and Git
dnf install -y docker git

# Start Docker automatically
systemctl enable --now docker

# Clone the application repository
cd /opt

git clone --branch feature/devops-challenge \
  https://github.com/IfeomaBuild/devops-challenge.git

# Build the actual Python application
cd /opt/devops-challenge/intern-task-app

docker build -t intern-task-app:local .
# Create a systemd service for the application
cat > /etc/systemd/system/intern-task-app.service <<'EOF'
[Unit]
Description=Intern Task Python Application
Requires=docker.service
After=docker.service

[Service]
Type=simple
Restart=always
RestartSec=5
ExecStartPre=-/usr/bin/docker rm -f intern-task-app
ExecStart=/usr/bin/docker run --name intern-task-app -p 8080:8080 intern-task-app:local
ExecStop=/usr/bin/docker stop intern-task-app

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the application
systemctl daemon-reload
systemctl enable --now intern-task-app.service