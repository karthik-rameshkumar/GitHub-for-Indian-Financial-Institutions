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

### Microsoft Security Integration
- Static Application Security Testing (SAST) with GitHub CodeQL and Microsoft Application Inspector
- Dynamic Application Security Testing (DAST) with Microsoft Defender for APIs
- Software Composition Analysis (SCA) with GitHub Dependency Review and Azure Artifacts
- Container security scanning with Microsoft Defender for Containers
- Secrets detection with GitHub Advanced Security Secret Scanning

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

### Required Microsoft Secrets

```yaml
# Azure Container Registry Access
ACR_NAME: "your-azure-container-registry"
AZURE_CLIENT_ID: "azure-service-principal-id"
AZURE_CLIENT_SECRET: "azure-service-principal-secret"
AZURE_TENANT_ID: "azure-tenant-id"
AZURE_SUBSCRIPTION_ID: "azure-subscription-id"

# Microsoft Security Scanning
AZURE_LOG_ANALYTICS_WORKSPACE_ID: "azure-monitor-workspace-id"
AZURE_LOG_ANALYTICS_WORKSPACE_KEY: "azure-monitor-workspace-key"
SENTINEL_WORKSPACE_ID: "microsoft-sentinel-workspace-id"
SENTINEL_API_KEY: "microsoft-sentinel-api-key"

# Microsoft DevOps Integration
AZURE_DEVOPS_ORG: "your-azure-devops-organization"
AZURE_DEVOPS_PROJECT: "your-azure-devops-project"
AZURE_DEVOPS_PAT: "azure-devops-personal-access-token"

# Microsoft Notifications
TEAMS_WEBHOOK_URL: "microsoft-teams-webhook-url"
```

### Required Microsoft Variables

```yaml
# Azure Registry Configuration
ACR_URL: "your-registry.azurecr.io"

# Environment Configuration
JAVA_VERSION: "17"
NODE_VERSION: "18"
DOTNET_VERSION: "8.x"

# Microsoft Compliance Configuration
RBI_FRAMEWORK_VERSION: "2021"
AZURE_POLICY_ASSIGNMENT_ID: "azure-policy-assignment-id"
DEFENDER_FOR_DEVOPS_ENABLED: "true"
```

## Microsoft Self-hosted Runner Labels

Workflows are designed to use specific Microsoft-compatible runner labels for security and compliance:

- `bfsi-security` - Microsoft security scanning and analysis
- `bfsi-build` - Application building and testing with Microsoft tools
- `bfsi-compliance` - Microsoft compliance validation (Azure Policy, Security Center)
- `bfsi-deploy` - Deployment operations using Azure services

## Microsoft Best Practices

### Microsoft Security
1. Use Azure-hosted agents or self-hosted runners with Microsoft security baseline
2. Implement Azure AD-based least privilege access
3. Enable Azure Monitor and Microsoft Sentinel audit logging
4. Use Azure Key Vault for encrypted secrets management
5. Implement Azure DevOps multi-stage approvals for production

### Microsoft Performance
1. Use Azure DevOps dependency caching and Azure Storage
2. Run tests in parallel using Azure DevOps parallel jobs
3. Optimize Docker builds with Azure Container Registry caching
4. Use Azure DevOps matrix builds for multi-environment testing
5. Implement incremental builds using Azure DevOps change detection

### Microsoft Compliance
1. Maintain audit trails using Azure DevOps audit logs
2. Implement Azure DevOps approval workflows for production changes
3. Regular compliance reporting via Azure Policy and Security Center
4. Document all security exceptions in Azure DevOps work items
5. Regular security and compliance training via Microsoft Learn

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