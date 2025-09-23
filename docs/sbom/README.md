# SBOM and Signature Chain Documentation

## Overview

This documentation provides comprehensive guidance for implementing and using the SBOM (Software Bill of Materials) and signature chain automation system designed specifically for Banking, Financial Services, and Insurance (BFSI) organizations in India.

## Table of Contents

1. [Quick Start Guide](#quick-start-guide)
2. [Configuration Reference](#configuration-reference)
3. [Integration Examples](#integration-examples)
4. [Compliance Guidelines](#compliance-guidelines)
5. [Troubleshooting](#troubleshooting)
6. [Security Best Practices](#security-best-practices)

## Quick Start Guide

### Basic Usage

Add the SBOM action to your workflow:

```yaml
- name: 'Generate SBOM and Sign Artifacts'
  uses: ./actions/sbom
  with:
    scan-path: '.'
    artifact-path: 'target/*.jar'
    runner-environment: 'dev'
```

### Complete Example

```yaml
name: 'BFSI Application CI/CD with SBOM'

on:
  push:
    branches: [main, develop]

jobs:
  build-and-sbom:
    runs-on: [self-hosted, bfsi-build]
    steps:
      - name: 'Checkout Code'
        uses: actions/checkout@v4

      - name: 'Set up JDK'
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: 'Build Application'
        run: mvn clean package

      - name: 'Generate SBOM and Sign Artifacts'
        uses: ./actions/sbom
        with:
          scan-path: '.'
          sbom-format: 'spdx-json'
          artifact-path: 'target/*.jar'
          enable-signing: 'true'
          enable-attestation: 'true'
          runner-environment: 'production'
          compliance-evidence-retention: '2555'

      - name: 'Upload Evidence for Audit'
        uses: actions/upload-artifact@v4
        with:
          name: 'compliance-evidence-${{ github.run_id }}'
          path: |
            *.spdx.json
            *.attestation.json
            sbom-compliance-evidence.json
          retention-days: 2555
```

## Configuration Reference

### Input Parameters

| Parameter | Type | Default | Required | Description |
|-----------|------|---------|----------|-------------|
| `scan-path` | string | `.` | No | Path to scan for SBOM generation |
| `sbom-format` | string | `spdx-json` | No | SBOM format (json, spdx-json, cyclonedx-json, table) |
| `output-file` | string | `sbom.spdx.json` | No | Output file name for SBOM |
| `enable-signing` | boolean | `true` | No | Enable artifact signing with cosign |
| `enable-attestation` | boolean | `true` | No | Enable SLSA attestation generation |
| `artifact-path` | string | `target/*.jar` | No | Path to artifacts to sign (supports glob patterns) |
| `registry` | string | `` | No | Container registry for image signing |
| `image-name` | string | `` | No | Container image name for signing |
| `compliance-evidence-retention` | number | `2555` | No | Evidence retention in days (7 years for BFSI) |
| `runner-environment` | string | `dev` | No | Runner environment (dev, uat, prod) |

### Output Parameters

| Output | Description |
|--------|-------------|
| `sbom-file` | Path to generated SBOM file |
| `signature-file` | Path to signature file |
| `attestation-file` | Path to SLSA attestation file |
| `compliance-report` | Path to compliance evidence report |

## Integration Examples

### Java Spring Boot Application

```yaml
name: 'Java Spring Boot BFSI Pipeline'

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  JAVA_VERSION: '17'
  REGISTRY: 'your-registry.azurecr.io'
  IMAGE_NAME: 'bfsi-app'

jobs:
  security-scan:
    name: '🔒 Security Scanning'
    runs-on: [self-hosted, bfsi-secure]
    steps:
      - uses: actions/checkout@v4
      
      - name: 'Initial SBOM Generation'
        uses: ./actions/sbom
        with:
          scan-path: '.'
          sbom-format: 'spdx-json'
          enable-signing: 'false'  # Skip signing for scan phase
          enable-attestation: 'false'

  build-and-test:
    name: '🔨 Build & Test'
    runs-on: [self-hosted, bfsi-build]
    needs: security-scan
    steps:
      - uses: actions/checkout@v4
      
      - name: 'Set up JDK'
        uses: actions/setup-java@v4
        with:
          java-version: ${{ env.JAVA_VERSION }}
          distribution: 'temurin'

      - name: 'Build Application'
        run: mvn clean package -DskipTests=false

      - name: 'Generate Production SBOM'
        uses: ./actions/sbom
        with:
          scan-path: '.'
          artifact-path: 'target/*.jar'
          sbom-format: 'spdx-json'
          output-file: 'production-sbom.spdx.json'
          enable-signing: 'true'
          enable-attestation: 'true'
          runner-environment: 'production'

  container-build:
    name: '🐳 Container Build'
    runs-on: [self-hosted, bfsi-docker]
    needs: build-and-test
    steps:
      - uses: actions/checkout@v4
      
      - name: 'Download Build Artifacts'
        uses: actions/download-artifact@v4
        with:
          name: 'sbom-evidence-${{ github.run_id }}'
          path: './artifacts'

      - name: 'Build Container Image'
        run: |
          docker build -t ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} .

      - name: 'Sign Container Image'
        uses: ./actions/sbom
        with:
          registry: ${{ env.REGISTRY }}
          image-name: ${{ env.IMAGE_NAME }}
          enable-signing: 'true'
          runner-environment: 'production'
```

### Node.js Application

```yaml
name: 'Node.js BFSI Pipeline'

jobs:
  build:
    runs-on: [self-hosted, bfsi-build]
    steps:
      - uses: actions/checkout@v4
      
      - name: 'Setup Node.js'
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: 'Install Dependencies'
        run: npm ci

      - name: 'Build Application'
        run: npm run build

      - name: 'Generate SBOM for Node.js'
        uses: ./actions/sbom
        with:
          scan-path: '.'
          sbom-format: 'cyclonedx-json'
          output-file: 'nodejs-sbom.cyclonedx.json'
          artifact-path: 'dist/*'
          enable-signing: 'true'
          enable-attestation: 'true'
```

### Multi-Language Project

```yaml
name: 'Multi-Language BFSI Pipeline'

jobs:
  sbom-matrix:
    runs-on: [self-hosted, bfsi-build]
    strategy:
      matrix:
        component:
          - { path: 'backend', type: 'java', artifacts: 'target/*.jar' }
          - { path: 'frontend', type: 'nodejs', artifacts: 'dist/*' }
          - { path: 'mobile', type: 'android', artifacts: 'app/build/outputs/apk/*.apk' }
    steps:
      - uses: actions/checkout@v4
      
      - name: 'Generate Component SBOM'
        uses: ./actions/sbom
        with:
          scan-path: ${{ matrix.component.path }}
          output-file: '${{ matrix.component.type }}-sbom.spdx.json'
          artifact-path: ${{ matrix.component.artifacts }}
          runner-environment: 'production'
```

## Compliance Guidelines

### RBI IT Framework Compliance

The SBOM action ensures compliance with RBI IT Framework requirements:

1. **Audit Trail (IT-R1)**
   - Complete logging of SBOM generation process
   - Cryptographic signatures for integrity
   - 7-year retention of evidence

2. **Change Management (IT-R3)**
   - Component version tracking in SBOM
   - Correlation with Git commits
   - Automated documentation updates

3. **Security Controls (IT-R4)**
   - Cryptographic signing of all artifacts
   - Certificate transparency logging
   - Vulnerability tracking through SBOM

### SEBI IT Governance

1. **System Documentation (SG-1)**
   - Comprehensive software inventory via SBOM
   - Multiple format support for different stakeholders
   - Regular updates with each build

2. **Risk Management (SG-2)**
   - Component vulnerability assessment
   - Third-party dependency tracking
   - Security risk scoring

### IRDAI Cybersecurity Guidelines

1. **Supply Chain Security (CS-1)**
   - Complete component visibility
   - Supplier risk assessment
   - Dependency graph analysis

2. **Data Protection (CS-2)**
   - Cryptographic integrity protection
   - Tamper-evident storage
   - Access control integration

## Troubleshooting

### Common Issues

#### SBOM Generation Fails

**Problem**: Syft fails to generate SBOM

**Solution**:
```yaml
- name: 'Debug SBOM Generation'
  run: |
    echo "Checking scan path: ${{ inputs.scan-path }}"
    ls -la ${{ inputs.scan-path }}
    syft --version
    syft ${{ inputs.scan-path }} -o table
```

#### Signing Fails

**Problem**: Cosign signing fails with authentication error

**Solution**:
```yaml
- name: 'Debug Cosign Setup'
  run: |
    echo "OIDC Token: ${ACTIONS_ID_TOKEN_REQUEST_TOKEN:0:20}..."
    echo "OIDC URL: $ACTIONS_ID_TOKEN_REQUEST_URL"
    cosign version
    export COSIGN_EXPERIMENTAL=1
    echo "Cosign experimental mode enabled"
```

#### Large Artifact Handling

**Problem**: Large artifacts cause timeout

**Solution**:
```yaml
- name: 'Optimize for Large Artifacts'
  uses: ./actions/sbom
  with:
    artifact-path: 'target/*.jar'
    enable-signing: 'true'
  timeout-minutes: 30  # Increase timeout
```

### Debug Mode

Enable debug logging:

```yaml
- name: 'Debug SBOM Generation'
  uses: ./actions/sbom
  env:
    ACTIONS_STEP_DEBUG: true
    RUNNER_DEBUG: 1
  with:
    scan-path: '.'
```

## Security Best Practices

### Runner Security

1. **Use BFSI Runners**: Always use `bfsi-*` labeled runners for production workloads
2. **Environment Isolation**: Separate dev/uat/prod environments
3. **Access Controls**: Implement role-based access to compliance evidence

### Artifact Security

1. **Signature Verification**: Always verify signatures before deployment
2. **Certificate Transparency**: Ensure CT logging is enabled
3. **Evidence Retention**: Maintain 7-year retention for regulatory compliance

### Example Verification Workflow

```yaml
name: 'Verify Signed Artifacts'

jobs:
  verify:
    runs-on: [self-hosted, bfsi-compliance]
    steps:
      - name: 'Download Artifacts'
        uses: actions/download-artifact@v4
        with:
          name: 'sbom-evidence-${{ github.run_id }}'

      - name: 'Verify Signatures'
        run: |
          export COSIGN_EXPERIMENTAL=1
          
          # Verify SBOM signature
          cosign verify-blob --signature sbom.spdx.json.sig sbom.spdx.json
          
          # Verify artifact signatures
          for artifact in target/*.jar; do
            if [ -f "${artifact}.sig" ]; then
              cosign verify-blob --signature "${artifact}.sig" "$artifact"
              echo "✅ Verified: $artifact"
            fi
          done
```

### Compliance Evidence Access

```yaml
name: 'Audit Evidence Access'

jobs:
  audit-access:
    runs-on: [self-hosted, bfsi-audit]
    if: github.actor == 'auditor' || contains(github.actor, 'compliance-')
    steps:
      - name: 'Generate Audit Report'
        run: |
          echo "Generating audit report for compliance evidence access"
          # Log access for regulatory compliance
```

## Advanced Configuration

### Custom SBOM Formats

```yaml
- name: 'Generate Multiple SBOM Formats'
  uses: ./actions/sbom
  with:
    scan-path: '.'
    sbom-format: 'spdx-json'
    # Action automatically generates additional formats:
    # - CycloneDX JSON
    # - Human-readable table
    # - SPDX TV format (if needed)
```

### Integration with External Systems

```yaml
- name: 'Submit to Compliance System'
  run: |
    # Submit SBOM to external compliance system
    curl -X POST \
      -H "Authorization: Bearer ${{ secrets.COMPLIANCE_API_TOKEN }}" \
      -H "Content-Type: application/json" \
      -d @sbom-compliance-evidence.json \
      https://compliance.bfsi-org.com/api/evidence
```

This documentation provides comprehensive guidance for implementing and using the SBOM and signature chain automation system in BFSI environments while maintaining regulatory compliance and security best practices.