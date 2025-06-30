# Self-Hosted Runners for Financial Institutions

This guide provides comprehensive instructions for setting up and managing GitHub Actions self-hosted runners in financial services environments with strict security and compliance requirements.

## Overview

Self-hosted runners provide:
- **Data Residency**: Keep sensitive data within your infrastructure
- **Network Security**: Run jobs within your secure network perimeter
- **Compliance**: Meet regulatory requirements for data processing
- **Custom Software**: Access to proprietary tools and databases
- **Performance**: Optimized hardware for specific workloads

## Prerequisites

### Hardware Requirements
- **Minimum**: 2 vCPU, 8GB RAM, 50GB storage
- **Recommended**: 4 vCPU, 16GB RAM, 100GB SSD
- **Enterprise**: 8 vCPU, 32GB RAM, 200GB NVMe SSD

### Software Requirements
- Ubuntu 20.04 LTS or RHEL 8+
- Docker Engine 20.10+
- Git 2.30+
- Java 17+ (for Spring Boot applications)
- Maven 3.8+

### Network Requirements
- Outbound HTTPS (443) to GitHub.com
- Outbound HTTPS (443) to api.github.com
- Outbound HTTPS (443) to *.actions.githubusercontent.com
- Internal connectivity to your artifact repositories

## Installation

### 1. Prepare the Runner Environment

```bash
# Create dedicated user for runner
sudo useradd -m -s /bin/bash github-runner
sudo usermod -aG docker github-runner

# Create runner directory
sudo mkdir -p /opt/github-runner
sudo chown github-runner:github-runner /opt/github-runner
```

### 2. Download and Configure Runner

```bash
# Switch to runner user
sudo su - github-runner

# Navigate to runner directory
cd /opt/github-runner

# Download latest runner
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Verify download
echo "29fc8cf2dab4c195bb147384e7e2c94cfd4d4022c793b346a6175435265aa278  actions-runner-linux-x64-2.311.0.tar.gz" | shasum -a 256 -c

# Extract files
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz
```

### 3. Register Runner

```bash
# Configure runner (use token from GitHub repo settings)
./config.sh --url https://github.com/YOUR_ORG/YOUR_REPO --token YOUR_REGISTRATION_TOKEN

# Configure as service
sudo ./svc.sh install
sudo ./svc.sh start
```

## Security Hardening

### 1. Network Security

```bash
# Configure firewall (UFW example)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

# Restrict outbound connections to GitHub only
sudo ufw allow out 443 to github.com
sudo ufw allow out 443 to api.github.com
sudo ufw allow out 443 to *.actions.githubusercontent.com
```

### 2. System Hardening

```bash
# Disable unnecessary services
sudo systemctl disable cups
sudo systemctl disable avahi-daemon
sudo systemctl disable bluetooth

# Configure automatic security updates
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Set up log monitoring
sudo apt install auditd
sudo systemctl enable auditd
```

### 3. Container Security

```bash
# Configure Docker security
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "userns-remap": "default",
  "no-new-privileges": true,
  "seccomp-profile": "/etc/docker/seccomp.json",
  "log-driver": "syslog",
  "log-opts": {
    "syslog-address": "tcp://your-siem:514"
  }
}
EOF

sudo systemctl restart docker
```

## Runner Configuration for Financial Services

### 1. Create Custom Runner Image

```dockerfile
# Dockerfile for Financial Services Runner
FROM ubuntu:20.04

# Install required packages
RUN apt-get update && apt-get install -y \
    curl \
    git \
    jq \
    wget \
    unzip \
    docker.io \
    openjdk-17-jdk \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Install security tools
RUN apt-get update && apt-get install -y \
    clamav \
    rkhunter \
    chkrootkit \
    && rm -rf /var/lib/apt/lists/*

# Configure security scanning
RUN freshclam

# Create runner user
RUN useradd -m -s /bin/bash runner
RUN usermod -aG docker runner

# Set up runner directory
WORKDIR /home/runner
USER runner

# Download and install GitHub runner
RUN curl -o actions-runner-linux-x64.tar.gz -L \
    https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz \
    && tar xzf ./actions-runner-linux-x64.tar.gz \
    && rm actions-runner-linux-x64.tar.gz

COPY entrypoint.sh /home/runner/
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
```

### 2. Environment Variables Configuration

```bash
# Create secure environment configuration
cat <<EOF > /opt/github-runner/.env
# Database connections (encrypted)
DATABASE_URL_ENCRYPTED="encrypted_connection_string"
DATABASE_KEY_PATH="/secure/keys/db.key"

# API Keys (using GitHub secrets)
EXTERNAL_API_KEY_NAME="PROD_API_KEY"

# Compliance settings
AUDIT_LOG_LEVEL="INFO"
AUDIT_LOG_PATH="/var/log/financial-app/audit.log"
DATA_RETENTION_DAYS="2555"  # 7 years for financial records

# Security settings
ENCRYPTION_KEY_PATH="/secure/keys/encryption.key"
TLS_CERT_PATH="/secure/certs/financial-app.crt"
TLS_KEY_PATH="/secure/keys/financial-app.key"
EOF

# Secure the environment file
chmod 600 /opt/github-runner/.env
chown github-runner:github-runner /opt/github-runner/.env
```

## Monitoring and Maintenance

### 1. Health Monitoring

```bash
# Create monitoring script
cat <<EOF > /opt/github-runner/monitor.sh
#!/bin/bash
# GitHub Runner Health Monitor

LOG_FILE="/var/log/github-runner-monitor.log"

# Check runner service status
if ! systemctl is-active --quiet actions.runner.YOUR_ORG-YOUR_REPO.YOUR_RUNNER; then
    echo "$(date): Runner service is not active" >> $LOG_FILE
    systemctl restart actions.runner.YOUR_ORG-YOUR_REPO.YOUR_RUNNER
fi

# Check disk space
DISK_USAGE=$(df /opt/github-runner | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    echo "$(date): High disk usage: ${DISK_USAGE}%" >> $LOG_FILE
fi

# Check memory usage
MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
if [ $MEM_USAGE -gt 90 ]; then
    echo "$(date): High memory usage: ${MEM_USAGE}%" >> $LOG_FILE
fi

# Check Docker status
if ! docker info > /dev/null 2>&1; then
    echo "$(date): Docker is not responding" >> $LOG_FILE
    systemctl restart docker
fi
EOF

chmod +x /opt/github-runner/monitor.sh

# Add to crontab
echo "*/5 * * * * /opt/github-runner/monitor.sh" | sudo crontab -u github-runner -
```

### 2. Log Management

```bash
# Configure log rotation
cat <<EOF | sudo tee /etc/logrotate.d/github-runner
/var/log/github-runner/*.log {
    daily
    rotate 90
    compress
    delaycompress
    missingok
    notifempty
    copytruncate
    postrotate
        systemctl restart rsyslog
    endscript
}
EOF
```

### 3. Security Scanning

```bash
# Automated security scanning script
cat <<EOF > /opt/github-runner/security-scan.sh
#!/bin/bash
# Daily Security Scan

SCAN_DATE=$(date +%Y%m%d)
SCAN_LOG="/var/log/security-scan-${SCAN_DATE}.log"

echo "Starting security scan at $(date)" > $SCAN_LOG

# ClamAV scan
echo "Running antivirus scan..." >> $SCAN_LOG
clamscan -r /opt/github-runner --log=$SCAN_LOG

# Rootkit scan
echo "Running rootkit scan..." >> $SCAN_LOG
rkhunter --check --skip-keypress --report-warnings-only >> $SCAN_LOG

# System integrity check
echo "Checking system integrity..." >> $SCAN_LOG
aide --check >> $SCAN_LOG

echo "Security scan completed at $(date)" >> $SCAN_LOG
EOF

chmod +x /opt/github-runner/security-scan.sh

# Schedule daily security scan
echo "0 2 * * * /opt/github-runner/security-scan.sh" | sudo crontab -u github-runner -
```

## Scaling Strategies

### 1. Auto-Scaling with Kubernetes

```yaml
# kubernetes-runner-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: github-runner
  namespace: github-runners
spec:
  replicas: 3
  selector:
    matchLabels:
      app: github-runner
  template:
    metadata:
      labels:
        app: github-runner
    spec:
      containers:
      - name: runner
        image: your-registry/github-runner:latest
        env:
        - name: GITHUB_TOKEN
          valueFrom:
            secretKeyRef:
              name: github-secrets
              key: runner-token
        - name: GITHUB_REPOSITORY
          value: "YOUR_ORG/YOUR_REPO"
        resources:
          requests:
            memory: "2Gi"
            cpu: "1"
          limits:
            memory: "4Gi"
            cpu: "2"
        volumeMounts:
        - name: docker-socket
          mountPath: /var/run/docker.sock
        - name: runner-data
          mountPath: /opt/github-runner
      volumes:
      - name: docker-socket
        hostPath:
          path: /var/run/docker.sock
      - name: runner-data
        persistentVolumeClaim:
          claimName: runner-data-pvc
```

### 2. Load Balancing

```bash
# HAProxy configuration for multiple runners
cat <<EOF > /etc/haproxy/haproxy.cfg
global
    daemon

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend github_runners
    bind *:8080
    default_backend runners

backend runners
    balance roundrobin
    server runner1 10.0.1.10:8080 check
    server runner2 10.0.1.11:8080 check
    server runner3 10.0.1.12:8080 check
EOF
```

## Troubleshooting

### Common Issues

1. **Runner Registration Fails**
   ```bash
   # Check network connectivity
   curl -I https://api.github.com
   
   # Verify token validity
   curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user
   ```

2. **Jobs Not Starting**
   ```bash
   # Check runner status
   sudo systemctl status actions.runner.YOUR_ORG-YOUR_REPO.YOUR_RUNNER
   
   # Check logs
   sudo journalctl -u actions.runner.YOUR_ORG-YOUR_REPO.YOUR_RUNNER -f
   ```

3. **Docker Issues**
   ```bash
   # Check Docker daemon
   sudo systemctl status docker
   
   # Test Docker functionality
   docker run hello-world
   ```

### Performance Optimization

```bash
# Optimize runner performance
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_ratio=15' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## Compliance Considerations

### 1. Data Residency
- Ensure runners are deployed in approved geographic regions
- Configure data processing to comply with local regulations

### 2. Audit Logging
- Enable comprehensive audit logging for all runner activities
- Configure log forwarding to centralized SIEM systems

### 3. Access Controls
- Implement role-based access controls for runner management
- Regular access reviews and privilege audits

### 4. Incident Response
- Develop incident response procedures for runner compromise
- Regular security drills and runner recovery testing