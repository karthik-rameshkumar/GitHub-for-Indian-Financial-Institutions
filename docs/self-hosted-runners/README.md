# Self-hosted Runner Configuration for Indian Financial Institutions

## Overview
This document provides comprehensive guidance for setting up and configuring self-hosted GitHub Actions runners in Indian Financial Institution environments, addressing regulatory compliance, security requirements, and operational constraints.

## Regulatory Considerations

### RBI IT Framework Compliance
- **Data Localization**: Runners must be hosted within Indian territory
- **Network Isolation**: Segregated networks for different environments
- **Audit Trail**: Complete logging of all runner activities
- **Access Controls**: Role-based access with MFA enforcement

### SEBI IT Governance
- **System Audit**: Regular auditing of runner configurations
- **Risk Management**: Continuous monitoring and risk assessment
- **Change Management**: Documented approval process for runner changes

## Self-hosted Runner Architecture

### Network Topology
```
┌─────────────────────────────────────────────────────────────┐
│                    DMZ (Demilitarized Zone)                │
│  ┌─────────────────┐    ┌─────────────────┐                │
│  │   GitHub        │    │    Runner       │                │
│  │   Connectivity  │────│    Proxy        │                │
│  │   Gateway       │    │    Server       │                │
│  └─────────────────┘    └─────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                                │
                                │ Encrypted VPN
                                │
┌─────────────────────────────────────────────────────────────┐
│                Internal Network (On-premises)              │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │    Dev       │  │     UAT      │  │  Production  │     │
│  │   Runners    │  │   Runners    │  │   Runners    │     │
│  │              │  │              │  │              │     │
│  │ bfsi-dev-01  │  │ bfsi-uat-01  │  │ bfsi-prod-01 │     │
│  │ bfsi-dev-02  │  │ bfsi-uat-02  │  │ bfsi-prod-02 │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Runner Labels for Environment Segregation
- `bfsi-secure`: Security-focused operations
- `bfsi-build`: Application build processes
- `bfsi-quality`: Code quality and testing
- `bfsi-approval`: Approval and governance workflows
- `bfsi-docker`: Container operations
- `bfsi-deploy-dev`: Development deployments
- `bfsi-deploy-uat`: UAT deployments
- `bfsi-deploy-prod`: Production deployments
- `bfsi-audit`: Audit and compliance reporting

## Installation and Configuration

### Prerequisites
- **Operating System**: Ubuntu 20.04 LTS or RHEL 8+ (hardened)
- **Security**: CIS Benchmark compliant configuration
- **Network**: Outbound HTTPS access to github.com
- **Storage**: Minimum 100GB for build artifacts and logs
- **Monitoring**: Integration with SIEM/SOC systems

### Runner Installation Script
```bash
#!/bin/bash
# BFSI Self-hosted Runner Installation Script
# Compliant with RBI IT Framework and security requirements

set -euo pipefail

# Configuration
RUNNER_VERSION="2.311.0"
RUNNER_USER="github-runner"
RUNNER_HOME="/opt/github-runner"
LOG_DIR="/var/log/github-runner"

# Security hardening
echo "Applying security hardening..."
sudo apt-get update && sudo apt-get upgrade -y
sudo ufw enable
sudo ufw allow 22/tcp
sudo ufw allow out 443/tcp

# Create dedicated user
sudo useradd -m -s /bin/bash ${RUNNER_USER}
sudo mkdir -p ${RUNNER_HOME} ${LOG_DIR}
sudo chown ${RUNNER_USER}:${RUNNER_USER} ${RUNNER_HOME} ${LOG_DIR}

# Download and install runner
cd ${RUNNER_HOME}
sudo -u ${RUNNER_USER} curl -o actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz \
  -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Verify checksum (security requirement)
sudo -u ${RUNNER_USER} echo "EXPECTED_CHECKSUM  actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz" | sha256sum -c

# Extract runner
sudo -u ${RUNNER_USER} tar xzf actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

# Install dependencies
sudo ./bin/installdependencies.sh

echo "Runner installation completed. Please configure with organization token."
```

### Runner Configuration for BFSI Environment
```bash
#!/bin/bash
# Configuration script for BFSI compliance

# Configure runner with organization
sudo -u ${RUNNER_USER} ./config.sh \
  --url https://github.com/your-bfsi-org \
  --token ${GITHUB_RUNNER_TOKEN} \
  --name "bfsi-secure-runner-$(hostname)" \
  --labels "bfsi-secure,bfsi-build,linux,x64" \
  --work "_work" \
  --replace

# Install as systemd service with security constraints
sudo ./svc.sh install ${RUNNER_USER}

# Apply security configurations
sudo systemctl edit github-runner --full << 'EOF'
[Unit]
Description=GitHub Actions Runner
After=network.target

[Service]
Type=simple
User=github-runner
Group=github-runner
WorkingDirectory=/opt/github-runner
ExecStart=/opt/github-runner/run.sh
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal
SyslogIdentifier=github-runner

# Security restrictions
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadWritePaths=/opt/github-runner
CapabilityBoundingSet=
AmbientCapabilities=
SecureBits=keep-caps-locked

# Resource limits
LimitNOFILE=4096
LimitNPROC=4096
MemoryMax=8G
CPUQuota=400%

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable github-runner
sudo systemctl start github-runner
```

## Security Configuration

### Network Security
```yaml
# Network security configuration
firewall_rules:
  outbound:
    - protocol: https
      destination: "*.github.com"
      port: 443
    - protocol: https
      destination: "*.githubassets.com"
      port: 443
    - protocol: https
      destination: "*.githubusercontent.com"
      port: 443
  
  blocked:
    - protocol: all
      destination: "0.0.0.0/0"
      action: deny
      log: true
```

### Container Security
```dockerfile
# Dockerfile for secure runner environments
FROM ubuntu:20.04

# Security updates
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    jq \
    git \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -r runner && useradd -r -g runner runner

# Install security tools
RUN apt-get update && apt-get install -y \
    clamav \
    rkhunter \
    lynis \
    && rm -rf /var/lib/apt/lists/*

# Security hardening
RUN echo "runner ALL=(ALL) NOPASSWD: /usr/bin/docker" >> /etc/sudoers
USER runner

# Security scanning on startup
ENTRYPOINT ["/usr/local/bin/security-check.sh"]
```

### Environment Variables and Secrets
```bash
# Secure environment configuration
export GITHUB_ACTIONS_RUNNER_TLS_CA_CERTS="/etc/ssl/certs/ca-certificates.crt"
export RUNNER_ALLOW_RUNASROOT="0"
export DISABLE_TELEMETRY="1"

# Audit logging
export GITHUB_ACTIONS_RUNNER_AUDIT_LOG="/var/log/github-runner/audit.log"
export RUNNER_AUDIT_EVENTS="job_started,job_completed,job_failed"

# Resource limits
export RUNNER_MAX_JOBS="2"
export RUNNER_JOB_TIMEOUT="3600"
```

## Monitoring and Compliance

### Log Configuration
```yaml
# Logging configuration for audit compliance
logging:
  level: INFO
  format: json
  outputs:
    - type: file
      path: /var/log/github-runner/runner.log
      max_size: 100MB
      max_backups: 30
      compress: true
    
    - type: syslog
      facility: local0
      tag: github-runner
    
    - type: splunk
      endpoint: https://splunk.bfsi.internal:8088
      token: ${SPLUNK_HEC_TOKEN}

audit_events:
  - runner_started
  - runner_stopped
  - job_queued
  - job_started
  - job_completed
  - job_failed
  - artifact_uploaded
  - artifact_downloaded
  - secret_accessed
```

### Health Monitoring
```bash
#!/bin/bash
# Health check script for BFSI runners

# Check runner status
check_runner_status() {
    systemctl is-active --quiet github-runner
    return $?
}

# Check network connectivity
check_github_connectivity() {
    curl -s -f https://api.github.com/zen > /dev/null
    return $?
}

# Check disk space
check_disk_space() {
    local usage=$(df /opt/github-runner | awk 'NR==2{print $5}' | sed 's/%//')
    if [ $usage -gt 80 ]; then
        return 1
    fi
    return 0
}

# Security checks
check_security() {
    # Check for unauthorized processes
    # Verify file integrity
    # Check for malware
    return 0
}

# Main health check
main() {
    local status=0
    
    check_runner_status || status=1
    check_github_connectivity || status=2
    check_disk_space || status=3
    check_security || status=4
    
    # Report to monitoring system
    curl -X POST https://monitoring.bfsi.internal/api/runner-health \
        -H "Content-Type: application/json" \
        -d "{\"hostname\":\"$(hostname)\",\"status\":$status,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
    
    exit $status
}

main "$@"
```

## Compliance and Audit

### Audit Trail Requirements
- **Complete Activity Logging**: All runner activities must be logged
- **Retention Period**: Minimum 7 years as per RBI guidelines
- **Tamper Protection**: Logs must be write-protected and integrity-verified
- **Regular Audits**: Monthly compliance audits required

### Compliance Checklist
- [ ] Runner hosted within Indian territory
- [ ] Network segregation implemented
- [ ] Security hardening applied
- [ ] Audit logging configured
- [ ] Monitoring and alerting active
- [ ] Backup and recovery procedures documented
- [ ] Incident response plan in place
- [ ] Regular security assessments scheduled

## Troubleshooting

### Common Issues
1. **Connection Issues**: Check firewall and proxy settings
2. **Authentication Failures**: Verify runner token and permissions
3. **Resource Constraints**: Monitor CPU, memory, and disk usage
4. **Security Violations**: Review security logs and compliance reports

### Support and Maintenance
- **Regular Updates**: Monthly security patches
- **Performance Monitoring**: Continuous monitoring of runner performance
- **Capacity Planning**: Regular assessment of runner capacity needs
- **Security Reviews**: Quarterly security assessments

## Contact Information
- **Technical Support**: devops@bfsi-org.com
- **Security Team**: security@bfsi-org.com
- **Compliance Office**: compliance@bfsi-org.com