# SBOM Integration Examples

This directory contains example workflows demonstrating how to integrate SBOM generation and signing into various BFSI applications.

## Examples

### 1. Java Spring Boot Integration
- File: `java-spring-boot-sbom.yml`
- Description: Complete CI/CD pipeline with SBOM for Java Spring Boot applications
- Use Case: Banking core systems, payment processing

### 2. Node.js Application
- File: `nodejs-sbom.yml`
- Description: Frontend and API applications with CycloneDX SBOM
- Use Case: Customer portals, mobile backends

### 3. Container Applications
- File: `container-sbom.yml`
- Description: Container image signing and SBOM generation
- Use Case: Microservices, cloud-native applications

### 4. Multi-Language Projects
- File: `multi-language-sbom.yml`
- Description: Complex projects with multiple components
- Use Case: Enterprise applications with diverse tech stack

### 5. Compliance-Only Workflow
- File: `compliance-sbom.yml`
- Description: SBOM generation for compliance and audit purposes
- Use Case: Legacy systems, third-party integrations

## Usage Instructions

1. Copy the appropriate example to your `.github/workflows/` directory
2. Customize the configuration for your specific needs
3. Update secrets and environment variables
4. Test in development environment first
5. Deploy to production with proper approvals

## Configuration Guidelines

### Environment-Specific Settings

```yaml
# Development
runner-environment: 'dev'
compliance-evidence-retention: '90'  # 3 months

# UAT
runner-environment: 'uat'
compliance-evidence-retention: '365'  # 1 year

# Production
runner-environment: 'prod'
compliance-evidence-retention: '2555'  # 7 years (regulatory requirement)
```

### Security Settings

```yaml
# High-security environments
enable-signing: 'true'
enable-attestation: 'true'

# Development/testing
enable-signing: 'false'  # Optional for dev
enable-attestation: 'false'  # Optional for dev
```