# BFSI SBOM Generation and Signing Action

## Overview

This GitHub Action provides comprehensive Software Bill of Materials (SBOM) generation and artifact signing capabilities specifically designed for Banking, Financial Services, and Insurance (BFSI) organizations in India. It ensures compliance with RBI, SEBI, and IRDAI regulatory requirements while maintaining the highest security standards.

## Features

- 🔍 **Multi-format SBOM Generation**: SPDX-JSON, CycloneDX, and human-readable formats
- 🔐 **Cryptographic Signing**: Keyless signing with Cosign and certificate transparency
- 📋 **SLSA Attestation**: Level 2+ compliance with provenance verification
- 🏛️ **Regulatory Compliance**: 7-year evidence retention for BFSI audits
- 🔄 **CI/CD Integration**: Seamless integration with existing workflows
- 🏃 **BFSI Runner Support**: Optimized for bfsi-* labeled self-hosted runners

## Quick Start

### Basic Usage

```yaml
- name: 'Generate SBOM and Sign Artifacts'
  uses: ./actions/sbom
  with:
    artifact-path: 'target/*.jar'
    runner-environment: 'production'
```

### Complete Configuration

```yaml
- name: 'Comprehensive SBOM Generation'
  uses: ./actions/sbom
  with:
    scan-path: '.'
    sbom-format: 'spdx-json'
    output-file: 'production-sbom.spdx.json'
    artifact-path: 'target/*.jar'
    enable-signing: 'true'
    enable-attestation: 'true'
    runner-environment: 'production'
    compliance-evidence-retention: '2555'
```

## Input Parameters

| Input | Type | Default | Required | Description |
|-------|------|---------|----------|-------------|
| `scan-path` | string | `.` | No | Directory path to scan for SBOM generation |
| `sbom-format` | string | `spdx-json` | No | Primary SBOM format (spdx-json, cyclonedx-json, json, table) |
| `output-file` | string | `sbom.spdx.json` | No | Output filename for the generated SBOM |
| `enable-signing` | boolean | `true` | No | Enable cryptographic signing of artifacts |
| `enable-attestation` | boolean | `true` | No | Generate SLSA attestation for provenance |
| `artifact-path` | string | `target/*.jar` | No | Glob pattern for artifacts to sign |
| `registry` | string | `` | No | Container registry for image signing |
| `image-name` | string | `` | No | Container image name for signing |
| `compliance-evidence-retention` | number | `2555` | No | Evidence retention period in days (7 years default) |
| `runner-environment` | string | `dev` | No | Target environment (dev, uat, prod) |

## Output Parameters

| Output | Description |
|--------|-------------|
| `sbom-file` | Path to the generated SBOM file |
| `signature-file` | Path to the cryptographic signature file |
| `attestation-file` | Path to the SLSA attestation file |
| `compliance-report` | Path to the compliance evidence report |

## Supported Ecosystems

### Java/Maven
- Detects Maven projects via `pom.xml`
- Generates comprehensive dependency tree
- Signs JAR artifacts automatically
- Integrates with existing Maven workflows

### Node.js/npm
- Detects npm projects via `package.json`
- Generates CycloneDX format by default
- Supports package-lock.json analysis
- Frontend and backend applications

### Container Images
- Scans Docker containers and images
- Signs container images with Cosign
- Generates multi-layer SBOM analysis
- Supports private registries

### Generic Projects
- Language-agnostic scanning
- File system analysis
- Custom artifact patterns
- Flexible output formats

## Security Features

### Cryptographic Signing
- **Algorithm**: ECDSA-SHA256
- **Method**: Keyless signing with GitHub OIDC
- **Transparency**: Certificate Transparency logs
- **Verification**: Public signature verification

### SLSA Compliance
- **Level**: 2+ compliance
- **Provenance**: Complete build metadata
- **Attestation**: Cryptographically signed
- **Verification**: Immutable evidence chain

### Evidence Integrity
- **Hashing**: SHA-256 for all artifacts
- **Timestamps**: RFC 3339 format
- **Chain of Custody**: Complete audit trail
- **Retention**: 7-year regulatory compliance

## Regulatory Compliance

### RBI IT Framework
- ✅ **IT-R1**: Complete audit trail with 7-year retention
- ✅ **IT-R2**: Data integrity via cryptographic signatures
- ✅ **IT-R3**: Change management through SBOM versioning
- ✅ **IT-R4**: Comprehensive documentation and evidence

### SEBI IT Governance
- ✅ **SG-1**: System documentation via SBOM inventory
- ✅ **SG-2**: Risk assessment through vulnerability analysis
- ✅ **SG-3**: Change control with version tracking

### IRDAI Cybersecurity
- ✅ **CS-1**: Supply chain security verification
- ✅ **CS-2**: Data protection with encryption
- ✅ **CS-3**: Incident response capabilities

## Integration Examples

### Java Spring Boot Application

```yaml
jobs:
  build:
    runs-on: [self-hosted, bfsi-build]
    steps:
      - uses: actions/checkout@v4
      - name: 'Build Application'
        run: mvn clean package
      - name: 'Generate SBOM'
        uses: ./actions/sbom
        with:
          artifact-path: 'target/*.jar'
          runner-environment: 'production'
```

### Node.js Application

```yaml
jobs:
  build:
    runs-on: [self-hosted, bfsi-build]
    steps:
      - uses: actions/checkout@v4
      - name: 'Build Application'
        run: npm run build
      - name: 'Generate SBOM'
        uses: ./actions/sbom
        with:
          sbom-format: 'cyclonedx-json'
          artifact-path: 'dist/*'
```

### Container Application

```yaml
jobs:
  container:
    runs-on: [self-hosted, bfsi-docker]
    steps:
      - name: 'Build Container'
        run: docker build -t myapp:latest .
      - name: 'Sign Container'
        uses: ./actions/sbom
        with:
          registry: 'myregistry.azurecr.io'
          image-name: 'myapp'
```

## Environment-Specific Configuration

### Development Environment
```yaml
runner-environment: 'dev'
enable-signing: 'false'
enable-attestation: 'false'
compliance-evidence-retention: '90'
```

### UAT Environment
```yaml
runner-environment: 'uat'
enable-signing: 'true'
enable-attestation: 'false'
compliance-evidence-retention: '365'
```

### Production Environment
```yaml
runner-environment: 'prod'
enable-signing: 'true'
enable-attestation: 'true'
compliance-evidence-retention: '2555'
```

## Generated Artifacts

### SBOM Files
- `*.spdx.json` - SPDX format SBOM
- `*.cyclonedx.json` - CycloneDX format SBOM
- `*.table.txt` - Human-readable format

### Signature Files
- `*.sig` - Cryptographic signatures
- `*.crt` - Signing certificates
- `*.attestation.json` - SLSA attestations

### Compliance Reports
- `sbom-compliance-evidence.json` - Regulatory evidence
- Comprehensive audit trail metadata
- Framework compliance mapping

## Troubleshooting

### Common Issues

**SBOM Generation Fails**
```bash
# Check scan path
ls -la ${{ inputs.scan-path }}
# Verify Syft installation
syft version
```

**Signing Fails**
```bash
# Check OIDC token
echo $ACTIONS_ID_TOKEN_REQUEST_TOKEN
# Verify Cosign setup
cosign version
```

**Large Artifacts**
```yaml
# Increase timeout for large files
timeout-minutes: 30
```

### Debug Mode
```yaml
env:
  ACTIONS_STEP_DEBUG: true
  RUNNER_DEBUG: 1
```

## Best Practices

### Security
1. Always use `bfsi-*` labeled runners for production
2. Enable signing for UAT and production environments
3. Verify signatures before deployment
4. Maintain evidence for regulatory audits

### Performance
1. Use appropriate scan paths to reduce processing time
2. Cache tool installations where possible
3. Optimize artifact patterns for large projects
4. Consider parallel processing for multi-component projects

### Compliance
1. Configure 7-year retention for production evidence
2. Generate multiple SBOM formats for different stakeholders
3. Maintain comprehensive audit trails
4. Regular compliance framework updates

## Support and Maintenance

### Updates
- Monthly tool version updates
- Quarterly compliance reviews
- Annual regulatory assessments
- Continuous security improvements

### Documentation
- [Complete Documentation](../../docs/sbom/README.md)
- [Integration Examples](../../docs/sbom/examples/)
- [Specification](../../specs/002-sbom-signature-chain/)

### Support Channels
- GitHub Issues for bug reports
- Security team consultation
- Compliance officer reviews
- Technical documentation wiki

## License

This action is part of the GitHub for Indian Financial Institutions repository and is licensed under the MIT License.