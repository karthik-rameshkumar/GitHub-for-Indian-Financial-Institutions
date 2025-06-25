# Actions Directory - CI/CD Workflows for Indian Financial Institutions

## Overview
This directory contains GitHub Actions workflows, reusable actions, and templates specifically designed for Banking, Financial Services, and Insurance (BFSI) organizations in India. All workflows are compliant with RBI, SEBI, and IRDAI regulatory requirements.

## Directory Structure

```
actions/
├── ci-cd/                     # Continuous Integration/Deployment workflows
│   ├── templates/            # Reusable workflow templates
│   ├── java-spring-boot/     # Java Spring Boot specific workflows
│   ├── nodejs/               # Node.js application workflows
│   └── docker/               # Container-based workflows
├── security/                 # Security-focused workflows
│   ├── scanning/             # Security scanning workflows
│   ├── compliance/           # Compliance checking workflows
│   └── vulnerability/        # Vulnerability management
├── compliance/               # Regulatory compliance workflows
│   ├── rbi/                  # RBI specific compliance
│   ├── sebi/                 # SEBI specific compliance
│   ├── irdai/                # IRDAI specific compliance
│   └── reporting/            # Compliance reporting
└── shared/                   # Shared actions and utilities
    ├── actions/              # Custom GitHub Actions
    ├── scripts/              # Utility scripts
    └── templates/            # Common templates
```

## Available Workflows

### 🔧 CI/CD Workflows

#### Java Spring Boot Pipelines
- **`java-spring-boot-ci.yml`** - Complete CI/CD pipeline for Spring Boot applications
- **`credit-decision-engine.yml`** - Specialized pipeline for credit decision systems
- **`microservices-ci.yml`** - Pipeline for microservices architecture

#### Features:
- ✅ Multi-environment support (dev, UAT, production)
- ✅ Security scanning integration (SAST, DAST, SCA)
- ✅ Self-hosted runner compatibility
- ✅ SOPS secret management
- ✅ Multi-stage approval workflows
- ✅ Compliance validation gates
- ✅ Comprehensive audit logging

### 🛡️ Security Workflows

#### Security Scanning
- **CodeQL Analysis** - Static application security testing
- **OWASP Dependency Check** - Vulnerable dependency detection
- **Container Security Scanning** - Docker image vulnerability assessment
- **Secrets Detection** - Hardcoded secrets identification

#### Compliance Workflows
- **RBI IT Framework Validation** - Ensures RBI compliance
- **SEBI Governance Check** - Validates SEBI requirements
- **Data Localization Verification** - Confirms data residency
- **Audit Trail Generation** - Creates compliance audit reports

### 📋 Regulatory Compliance

#### RBI Compliance
- IT Framework for Banks/NBFCs validation
- Cyber Security Framework adherence
- Data localization compliance
- Outsourcing guidelines verification

#### SEBI Compliance
- IT Governance framework validation
- System audit requirements
- Risk management compliance
- Cyber resilience verification

#### IRDAI Compliance
- Information security guidelines
- Business continuity requirements
- Data protection compliance
- System governance validation

## Quick Start Guide

### 1. Repository Setup
```bash
# Copy workflow templates to your repository
cp .github/workflows/java-spring-boot-ci.yml /path/to/your/repo/.github/workflows/

# Copy supporting configuration files
cp -r .github/codeql /path/to/your/repo/.github/
cp -r .github/security /path/to/your/repo/.github/
```

### 2. Configure Repository Secrets
```bash
# Required secrets for BFSI workflows
SOPS_AGE_KEY_DEV="your-development-encryption-key"
SOPS_AGE_KEY_UAT="your-uat-encryption-key"
SOPS_AGE_KEY_PROD="your-production-encryption-key"
REGISTRY_USERNAME="docker-registry-username"
REGISTRY_PASSWORD="docker-registry-password"
SONAR_TOKEN="sonarqube-analysis-token"
```

### 3. Setup Self-hosted Runners
```bash
# Configure runner labels for BFSI environments
# Development runners: [self-hosted, bfsi-dev]
# UAT runners: [self-hosted, bfsi-uat]
# Production runners: [self-hosted, bfsi-prod]
```

### 4. Customize for Your Application
```yaml
# Edit workflow variables in .github/workflows/java-spring-boot-ci.yml
env:
  JAVA_VERSION: '17'
  REGISTRY: 'your-private-registry.com'
  IMAGE_NAME: 'your-application-name'
```

## Workflow Templates

### Basic Java Spring Boot CI/CD
```yaml
name: 'BFSI Java Spring Boot CI/CD'
on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  security-scan:
    runs-on: [self-hosted, bfsi-secure]
    steps:
      - uses: actions/checkout@v4
      - name: 'Security Scanning'
        uses: ./.github/actions/security-scan
        
  build-and-test:
    needs: security-scan
    runs-on: [self-hosted, bfsi-build]
    steps:
      - uses: actions/checkout@v4
      - name: 'Build and Test'
        uses: ./.github/actions/java-build-test
        
  compliance-check:
    needs: build-and-test
    runs-on: [self-hosted, bfsi-compliance]
    steps:
      - name: 'RBI Compliance Validation'
        uses: ./.github/actions/rbi-compliance-check
```

### Advanced Multi-Environment Pipeline
```yaml
name: 'Advanced BFSI Pipeline'
on:
  push:
    branches: [ main ]

jobs:
  security-and-compliance:
    strategy:
      matrix:
        check: [security, compliance, quality]
    runs-on: [self-hosted, bfsi-${{ matrix.check }}]
    steps:
      - uses: actions/checkout@v4
      - name: 'Run ${{ matrix.check }} checks'
        uses: ./.github/actions/${{ matrix.check }}-check

  multi-stage-approval:
    needs: security-and-compliance
    uses: ./.github/workflows/approval-workflow.yml
    with:
      environment: production
      approvers: 'security-team,compliance-team,risk-committee'
      minimum-approvals: 3
```

## Custom Actions

### Security Scanning Action
```yaml
# .github/actions/security-scan/action.yml
name: 'BFSI Security Scan'
description: 'Comprehensive security scanning for financial applications'
inputs:
  severity-threshold:
    description: 'Minimum severity to fail the build'
    required: false
    default: 'high'
runs:
  using: 'composite'
  steps:
    - name: 'CodeQL Analysis'
      uses: github/codeql-action/analyze@v3
    - name: 'OWASP Dependency Check'
      run: mvn org.owasp:dependency-check-maven:check
    - name: 'Container Security Scan'
      uses: aquasecurity/trivy-action@master
```

### Compliance Validation Action
```yaml
# .github/actions/rbi-compliance-check/action.yml
name: 'RBI Compliance Check'
description: 'Validates RBI IT Framework compliance'
inputs:
  framework-version:
    description: 'RBI IT Framework version'
    required: false
    default: '2021'
runs:
  using: 'composite'
  steps:
    - name: 'Data Localization Check'
      run: |
        echo "Validating data localization compliance..."
        # Custom compliance validation logic
    - name: 'Audit Trail Verification'
      run: |
        echo "Verifying audit trail implementation..."
        # Audit trail validation logic
```

## Environment-Specific Configurations

### Development Environment
```yaml
# Optimized for rapid development feedback
development:
  security_checks: basic
  approval_required: false
  auto_deployment: true
  test_coverage_threshold: 70
```

### UAT Environment
```yaml
# Balanced security and business validation
uat:
  security_checks: comprehensive
  approval_required: true
  auto_deployment: true
  test_coverage_threshold: 80
  business_validation: required
```

### Production Environment
```yaml
# Maximum security and compliance
production:
  security_checks: comprehensive
  approval_required: true
  approval_stages: 5
  auto_deployment: false
  test_coverage_threshold: 85
  compliance_validation: mandatory
  audit_logging: comprehensive
```

## Self-hosted Runner Configuration

### Runner Labels Strategy
```yaml
# Environment-based labels
development: [self-hosted, bfsi-dev, linux, x64]
uat: [self-hosted, bfsi-uat, linux, x64]  
production: [self-hosted, bfsi-prod, linux, x64]

# Function-based labels
security: [self-hosted, bfsi-secure, security-hardened]
compliance: [self-hosted, bfsi-compliance, audit-enabled]
deployment: [self-hosted, bfsi-deploy, network-restricted]
```

### Runner Security Configuration
```yaml
# Security hardening for BFSI runners
security_features:
  - network_isolation: true
  - audit_logging: enabled
  - resource_limits: enforced
  - container_scanning: mandatory
  - secrets_encryption: aes256
```

## Compliance Features

### RBI IT Framework Compliance
- ✅ Data localization validation
- ✅ Cyber security framework adherence
- ✅ Risk management integration
- ✅ Audit trail generation
- ✅ Incident response procedures

### SEBI IT Governance
- ✅ System governance validation
- ✅ Business continuity checks
- ✅ Risk assessment integration
- ✅ Compliance reporting
- ✅ Change management workflows

### IRDAI Guidelines
- ✅ Information security compliance
- ✅ Data protection validation
- ✅ Business continuity planning
- ✅ System audit capabilities
- ✅ Regulatory reporting

## Best Practices

### Security
1. **Secrets Management**: Use SOPS for sensitive data encryption
2. **Image Scanning**: Scan all container images for vulnerabilities
3. **Network Isolation**: Use separate networks for different environments
4. **Access Control**: Implement role-based access for workflows
5. **Audit Logging**: Enable comprehensive audit trails

### Compliance
1. **Regular Audits**: Schedule automated compliance checks
2. **Documentation**: Maintain up-to-date compliance documentation
3. **Change Management**: Follow approval workflows for all changes
4. **Risk Assessment**: Conduct regular risk assessments
5. **Incident Response**: Maintain incident response procedures

### Performance
1. **Caching**: Use action caching for dependencies and build artifacts
2. **Parallel Execution**: Run independent jobs in parallel
3. **Resource Optimization**: Optimize runner resource usage
4. **Build Optimization**: Use multi-stage Docker builds
5. **Test Optimization**: Run fast tests first, slow tests later

## Troubleshooting

### Common Issues

#### Workflow Failures
```bash
# Check workflow run logs
gh run list --repo your-org/your-repo
gh run view [run-id] --log

# Debug failed jobs
gh run view [run-id] --job [job-id]
```

#### Self-hosted Runner Issues
```bash
# Check runner status
sudo systemctl status github-runner

# View runner logs
journalctl -u github-runner -f

# Restart runner service
sudo systemctl restart github-runner
```

#### Security Scan Failures
```bash
# Check CodeQL results
gh api repos/:owner/:repo/code-scanning/alerts

# Review dependency check report
cat target/dependency-check-report.html
```

### Support Contacts
- **Technical Support**: devops@bfsi-org.com
- **Security Team**: security@bfsi-org.com
- **Compliance Office**: compliance@bfsi-org.com

## Contributing

### Adding New Workflows
1. Create workflow in appropriate subdirectory
2. Follow naming convention: `[application-type]-[environment]-[function].yml`
3. Include comprehensive documentation
4. Test on self-hosted runners
5. Validate compliance requirements

### Updating Existing Workflows
1. Follow semantic versioning for breaking changes
2. Update documentation and examples
3. Test backward compatibility
4. Notify stakeholders of changes
5. Update compliance documentation

## License
MIT License - See LICENSE file for details

## Documentation
- [Self-hosted Runner Setup](../docs/self-hosted-runners/README.md)
- [Secrets Management](../docs/security/secrets-management.md)
- [Branch Protection Rules](../docs/compliance/branch-protection-rules.md)
- [Deployment Approval Process](../docs/compliance/deployment-approval-process.md)
- [Compliance Checklist](../docs/compliance/compliance-checklist.md)