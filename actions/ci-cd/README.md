# CI/CD Workflows

This directory contains Continuous Integration and Continuous Deployment workflows specifically designed for Banking, Financial Services, and Insurance (BFSI) applications.

## Directory Structure

```
ci-cd/
├── templates/              # Reusable workflow templates
├── java-spring-boot/      # Java Spring Boot specific workflows
├── nodejs/               # Node.js application workflows
└── docker/               # Container-based workflows
```

## Templates

### Available Templates

1. **java-spring-boot-basic.yml** - Basic CI/CD pipeline for Spring Boot applications
2. **advanced-multi-environment.yml** - Advanced pipeline with multiple environments and approval gates

### Usage

Copy the appropriate template to your repository's `.github/workflows/` directory:

```bash
cp actions/ci-cd/templates/java-spring-boot-basic.yml .github/workflows/
```

## Language-Specific Workflows

### Java Spring Boot

- **microservices-pipeline.yml** - Comprehensive pipeline for microservices architecture
- Includes change detection, parallel builds, integration testing
- Supports blue-green deployments

### Node.js

- **bfsi-app-pipeline.yml** - Complete Node.js application pipeline
- Includes security auditing, license compliance, performance testing
- Supports both TypeScript and JavaScript applications

### Docker

- **container-security-pipeline.yml** - Container-focused security pipeline
- Includes Dockerfile linting, vulnerability scanning, runtime security analysis
- Implements image signing and SBOM generation

## Key Features

### Security Integration
- Static Application Security Testing (SAST)
- Dynamic Application Security Testing (DAST)
- Software Composition Analysis (SCA)
- Container security scanning
- Secrets detection

### Compliance Validation
- RBI IT Framework compliance checks
- SEBI governance validation (when applicable)
- IRDAI guidelines compliance (when applicable)
- Data localization verification
- Audit trail validation

### Quality Gates
- Code coverage requirements
- Security vulnerability thresholds
- Dependency vulnerability limits
- Performance benchmarks
- Compliance score minimums

### Environment Management
- Development (auto-deployment)
- UAT (approval required)
- Production (multi-stage approval)
- Emergency deployment procedures

## Configuration

### Required Secrets

```yaml
# Registry Access
REGISTRY_USERNAME: "docker-registry-username"
REGISTRY_PASSWORD: "docker-registry-password"

# Security Scanning
SONAR_TOKEN: "sonarqube-token"
SNYK_TOKEN: "snyk-api-token"

# Image Signing
COSIGN_PRIVATE_KEY: "cosign-private-key"

# Notifications
SLACK_WEBHOOK_URL: "slack-webhook-url"
```

### Required Variables

```yaml
# Registry Configuration
REGISTRY_URL: "your-private-registry.com"

# Environment Configuration
JAVA_VERSION: "17"
NODE_VERSION: "18"

# Compliance Configuration
RBI_FRAMEWORK_VERSION: "2021"
```

## Self-hosted Runner Labels

Workflows are designed to use specific runner labels for security and compliance:

- `bfsi-security` - Security scanning and analysis
- `bfsi-build` - Application building and testing
- `bfsi-compliance` - Compliance validation
- `bfsi-deploy` - Deployment operations

## Best Practices

### Security
1. Use self-hosted runners for sensitive operations
2. Implement least privilege access
3. Enable comprehensive audit logging
4. Use encrypted secrets management
5. Implement multi-stage approvals for production

### Performance
1. Use dependency caching
2. Run tests in parallel where possible
3. Optimize Docker builds with multi-stage builds
4. Use matrix builds for multi-environment testing
5. Implement incremental builds for large applications

### Compliance
1. Maintain audit trails for all deployments
2. Implement approval workflows for production changes
3. Regular compliance reporting
4. Document all security exceptions
5. Regular security and compliance training

## Customization

### Environment-Specific Configuration

Each workflow can be customized for specific environments:

```yaml
env:
  JAVA_VERSION: '17'
  REGISTRY: 'your-private-registry.com'
  IMAGE_NAME: 'your-application-name'
  
  # Environment-specific settings
  DEV_AUTO_DEPLOY: true
  UAT_APPROVAL_REQUIRED: true
  PROD_APPROVAL_COUNT: 3
```

### Threshold Configuration

Security and quality thresholds can be adjusted in `actions/shared/templates/security-thresholds.yml`

## Troubleshooting

### Common Issues

1. **Runner Not Found**: Ensure self-hosted runners are properly labeled
2. **Permission Denied**: Check repository secrets and permissions
3. **Build Failures**: Review dependency versions and conflicts
4. **Security Scan Failures**: Address vulnerabilities or adjust thresholds
5. **Compliance Failures**: Review and update compliance configurations

### Support

For workflow issues and support:
- Technical Support: devops@bfsi-org.com
- Security Questions: security@bfsi-org.com
- Compliance Issues: compliance@bfsi-org.com