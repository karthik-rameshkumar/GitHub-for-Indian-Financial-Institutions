# Runner Configuration for Indian Financial Institutions

## Overview
This document provides comprehensive guidance for configuring GitHub Actions runners in Indian Financial Institution environments, covering both **GitHub hosted runners** and **self-hosted runners** to maximize GitHub product usage while addressing regulatory compliance, security requirements, and operational constraints.

## Runner Selection Strategy

### GitHub Hosted Runners vs Self-hosted Runners

| **Aspect** | **GitHub Hosted Runners** | **Self-hosted Runners** |
|------------|---------------------------|-------------------------|
| **Best for** | Development, testing, CI builds | Production, compliance, sensitive operations |
| **Cost** | Pay-per-use, cost-effective for development | Fixed infrastructure cost |
| **Maintenance** | Zero maintenance, always updated | Requires maintenance, patching, monitoring |
| **Security** | GitHub-managed, secure by default | Full control, customizable security |
| **Compliance** | Limited compliance controls | Full regulatory compliance |
| **Network Access** | Public internet only | Internal network access |
| **Customization** | Limited | Full customization |
| **Data Locality** | Global GitHub infrastructure | On-premises, data localization compliant |

### Recommended Usage Pattern

**🟢 Use GitHub Hosted Runners for:**
- Feature branch builds and testing
- Pull request validation
- Development environment deployments
- Code quality checks and linting
- Unit and integration testing
- Open source dependency scanning
- Non-sensitive container builds

**🔴 Use Self-hosted Runners for:**
- Production deployments
- Regulatory compliance checks
- Financial data processing
- Audit trail generation
- Environment-specific deployments
- Network-restricted operations
- Sensitive secret handling
- Long-term audit log retention

## Configuration Examples

### Hybrid Workflow Configuration

Our workflows support both runner types through conditional logic:

```yaml
env:
  # Default to GitHub hosted for development efficiency and cost optimization
  USE_GITHUB_HOSTED: ${{ github.event.inputs.runner_type == 'github-hosted' || (github.event.inputs.runner_type == '' && github.ref != 'refs/heads/main') }}
  # Force self-hosted for production and sensitive operations
  FORCE_SELF_HOSTED: ${{ github.ref == 'refs/heads/main' && contains(github.event.head_commit.message, '[production]') }}

jobs:
  build-and-test:
    name: '🔨 Build & Test'
    # Conditional runner selection
    runs-on: ${{ env.USE_GITHUB_HOSTED == 'true' && env.FORCE_SELF_HOSTED != 'true' && 'ubuntu-latest' || fromJSON('["self-hosted", "bfsi-build"]') }}
    
  # Production deployments always use self-hosted runners
  deploy-prod:
    name: '🚀 Deploy to Production'
    runs-on: [self-hosted, bfsi-deploy-prod]  # Always self-hosted for production security
```

### Manual Runner Selection

You can manually choose the runner type when triggering workflows:

```yaml
workflow_dispatch:
  inputs:
    runner_type:
      description: 'Runner type to use'
      required: false
      default: 'github-hosted'
      type: choice
      options:
        - 'github-hosted'
        - 'self-hosted'
```

## GitHub Hosted Runners Configuration

### Advantages for BFSI Development

1. **Cost Optimization**
   - No infrastructure maintenance costs
   - Pay only for actual usage
   - Ideal for development and testing phases

2. **GitHub Product Integration**
   - Seamless integration with GitHub Advanced Security
   - Built-in CodeQL analysis
   - Native GitHub Packages support
   - Integrated GitHub Container Registry

3. **Developer Productivity**
   - Instant availability, no wait times
   - Always updated with latest tools
   - Consistent environment across teams

4. **Compliance Benefits**
   - SOC 2 Type II certified infrastructure
   - Regular security updates
   - Built-in security controls

### Recommended GitHub Hosted Workflow

```yaml
name: 'BFSI Development Pipeline'

on:
  pull_request:
    branches: [ main, develop ]
  push:
    branches: [ develop, 'feature/*' ]

jobs:
  # Use GitHub hosted runners for development workflows
  code-quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup Java
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      
      # Leverage GitHub's built-in security features
      - name: Initialize CodeQL
        uses: github/codeql-action/init@v3
        with:
          languages: java
      
      - name: Build for Analysis
        run: mvn compile
      
      - name: Perform CodeQL Analysis
        uses: github/codeql-action/analyze@v3
      
      # Use GitHub's dependency scanning
      - name: Run Dependency Check
        run: mvn org.owasp:dependency-check-maven:check

  unit-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        java-version: [17, 21]
    steps:
      - uses: actions/checkout@v4
      - name: Setup Java ${{ matrix.java-version }}
        uses: actions/setup-java@v4
        with:
          java-version: ${{ matrix.java-version }}
          distribution: 'temurin'
      
      - name: Cache Maven dependencies
        uses: actions/cache@v4
        with:
          path: ~/.m2
          key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
      
      - name: Run Tests
        run: mvn test
      
      - name: Upload Test Results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results-java-${{ matrix.java-version }}
          path: target/surefire-reports/
```

### GitHub Actions Security Features

Maximize GitHub's security features when using hosted runners:

```yaml
permissions:
  # Minimal permissions for security
  contents: read
  security-events: write
  actions: read

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
      # Advanced Security Features
      - name: Checkout
        uses: actions/checkout@v4
      
      # GitHub Advanced Security - Secret Scanning
      - name: Check for secrets
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: main
          head: HEAD
      
      # GitHub Advanced Security - Dependency Review
      - name: Dependency Review
        uses: actions/dependency-review-action@v3
        with:
          fail-on-severity: moderate
      
      # Container scanning with GitHub Container Registry
      - name: Build and scan container
        run: |
          docker build -t temp-image .
          docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
            -v $PWD:/app -w /app aquasec/trivy image temp-image
```

## Self-hosted Runner Configuration

### When Self-hosted Runners are Mandatory

For Indian Financial Institutions, self-hosted runners are **required** for:

1. **Regulatory Compliance Operations**
   - RBI audit trail generation
   - SEBI compliance reporting
   - IRDAI data governance checks
   - Regulatory filing processes

2. **Production Environments**
   - Production deployments
   - Live system monitoring
   - Production data processing
   - Critical system updates

3. **Sensitive Data Processing**
   - Customer PII handling
   - Financial transaction processing
   - Credit scoring and risk assessment
   - Fraud detection algorithms

4. **Network-restricted Operations**
   - Internal API access
   - Database connections
   - Legacy system integrations
   - On-premises service calls

## Best Practices for Hybrid Runner Usage

### Cost Optimization Strategy

1. **Default to GitHub Hosted Runners**
   - Use for all development and testing workflows
   - Leverage for feature branch validation
   - Utilize for open source dependency scanning
   - Employ for basic security scanning

2. **Strategic Self-hosted Runner Usage**
   - Reserve for production deployments only
   - Use for regulatory compliance checks
   - Employ for sensitive data processing
   - Utilize for internal network access

3. **Workflow Design Patterns**
   ```yaml
   # Development workflow - GitHub hosted
   development:
     if: github.ref != 'refs/heads/main'
     runs-on: ubuntu-latest
   
   # Production workflow - Self-hosted
   production:
     if: github.ref == 'refs/heads/main'
     runs-on: [self-hosted, bfsi-prod]
   ```

### Security Considerations

1. **GitHub Hosted Runners**
   - Use minimal permissions principle
   - Avoid storing sensitive secrets
   - Use environment-specific configurations
   - Implement proper secret management

2. **Self-hosted Runners**
   - Implement network isolation
   - Regular security updates
   - Comprehensive audit logging
   - Access control enforcement

### Migration Strategy

1. **Phase 1: Development Workflows**
   - Move all feature branch builds to GitHub hosted
   - Migrate unit and integration tests
   - Transition code quality checks

2. **Phase 2: Staging Environments**
   - Evaluate staging deployment on GitHub hosted
   - Test performance and security implications
   - Validate integration capabilities

3. **Phase 3: Selective Production**
   - Keep critical production deployments on self-hosted
   - Migrate non-sensitive production tasks
   - Monitor compliance and performance

### Regulatory Considerations for Self-hosted Runners

## Self-hosted Runner Configuration

### When Self-hosted Runners are Mandatory

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