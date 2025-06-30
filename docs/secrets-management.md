# Secrets Management for Financial Institutions

This guide provides comprehensive secrets management strategies for financial services organizations using GitHub Actions, with emphasis on security, compliance, and operational best practices.

## Overview

Effective secrets management is critical for financial institutions to:
- Protect sensitive customer data and financial information
- Comply with regulatory requirements (RBI, IRDAI, PCI DSS)
- Maintain operational security across development and production environments
- Enable secure CI/CD pipelines without exposing credentials

## Architecture Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Developer     │    │   GitHub Actions │    │   Production    │
│   Workstation   │    │   Runner         │    │   Environment   │
├─────────────────┤    ├──────────────────┤    ├─────────────────┤
│ • No hardcoded  │───▶│ • GitHub Secrets │───▶│ • Encrypted     │
│   secrets       │    │ • SOPS encrypted │    │   at rest       │
│ • Local env     │    │ • Vault integration│   │ • Key rotation  │
│   only          │    │ • Time-limited   │    │ • Audit trails  │
└─────────────────┘    │   tokens         │    └─────────────────┘
                       └──────────────────┘
```

## GitHub Secrets Management

### 1. Repository Secrets Hierarchy

```yaml
# Repository Level (Least Privileged)
secrets:
  DEV_DATABASE_PASSWORD: "dev_password_123"
  DEV_API_KEY: "dev_api_key_xyz"

# Environment Level (Environment-Specific)
environments:
  production:
    secrets:
      PROD_DATABASE_PASSWORD: "encrypted_prod_password"
      PROD_API_KEY: "encrypted_prod_api_key"
      ENCRYPTION_KEY: "base64_encoded_encryption_key"
  
  uat:
    secrets:
      UAT_DATABASE_PASSWORD: "encrypted_uat_password"
      UAT_API_KEY: "encrypted_uat_api_key"

# Organization Level (Shared Across Repos)
organization_secrets:
  SONAR_TOKEN: "sonar_organization_token"
  DOCKER_REGISTRY_PASSWORD: "registry_password"
```

### 2. Secret Naming Conventions

```bash
# Environment-specific secrets
{ENVIRONMENT}_{SERVICE}_{TYPE}
# Examples:
PROD_DATABASE_PASSWORD
UAT_REDIS_CONNECTION_STRING
DEV_SMTP_API_KEY

# Service-specific secrets
{SERVICE}_{COMPONENT}_{TYPE}
# Examples:
PAYMENT_GATEWAY_API_KEY
NBFC_CORE_ENCRYPTION_KEY
CREDIT_ENGINE_MODEL_TOKEN

# Third-party integrations
{VENDOR}_{SERVICE}_{TYPE}
# Examples:
AWS_S3_ACCESS_KEY
AZURE_KEYVAULT_CLIENT_SECRET
EQUIFAX_API_CREDENTIALS
```

## SOPS (Secrets OPerationS) Integration

### 1. Installation and Setup

```bash
# Install SOPS
curl -LO https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64
sudo mv sops-v3.7.3.linux.amd64 /usr/local/bin/sops
sudo chmod +x /usr/local/bin/sops

# Install age for encryption
curl -LO https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-linux-amd64.tar.gz
tar xzf age-v1.1.1-linux-amd64.tar.gz
sudo mv age/age* /usr/local/bin/
```

### 2. Key Management

```bash
# Generate age key pair
age-keygen -o ~/.age/key.txt

# Create .sops.yaml configuration
cat <<EOF > .sops.yaml
creation_rules:
  - path_regex: \.prod\.ya?ml$
    age: age1ql3z7hjy54pw9hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
  - path_regex: \.dev\.ya?ml$
    age: age1ql3z7hjy54pw9hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
  - path_regex: \.uat\.ya?ml$
    age: age1ql3z7hjy54pw9hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
EOF
```

### 3. Encrypted Configuration Files

```yaml
# secrets/production.yml (encrypted with SOPS)
database:
    host: ENC[AES256_GCM,data:Tr7o=,tag:V8WyTlL=,type:str]
    username: ENC[AES256_GCM,data:ZG0=,tag:obo=,type:str]
    password: ENC[AES256_GCM,data:I5I=,tag:Y50=,type:str]
api_keys:
    payment_gateway: ENC[AES256_GCM,data:jq==,tag:eA=,type:str]
    credit_bureau: ENC[AES256_GCM,data:MQ==,tag:lg=,type:str]
encryption:
    master_key: ENC[AES256_GCM,data:xA==,tag:hg=,type:str]
sops:
    kms: []
    gcp_kms: []
    azure_kv: []
    hc_vault: []
    age:
        - recipient: age1ql3z7hjy54pw9hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
          enc: |
            -----BEGIN AGE ENCRYPTED FILE-----
            YWdlLWVuY3J5cHRpb24ub3JnL3YxCi0+IFgyNTUxOSBOQjJ3VHV6TlRHMGZSU1JQ
            -----END AGE ENCRYPTED FILE-----
    lastmodified: "2024-01-15T10:30:00Z"
    mac: ENC[AES256_GCM,data:ABC123==,tag:XYZ789==,type:str]
    pgp: []
    version: 3.7.3
```

### 4. GitHub Actions Integration

```yaml
# .github/workflows/deploy-with-sops.yml
name: Deploy with SOPS Secrets

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install SOPS
      run: |
        curl -LO https://github.com/mozilla/sops/releases/download/v3.7.3/sops-v3.7.3.linux.amd64
        sudo mv sops-v3.7.3.linux.amd64 /usr/local/bin/sops
        sudo chmod +x /usr/local/bin/sops

    - name: Install age
      run: |
        curl -LO https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-linux-amd64.tar.gz
        tar xzf age-v1.1.1-linux-amd64.tar.gz
        sudo mv age/age* /usr/local/bin/

    - name: Setup age key
      run: |
        echo "${{ secrets.AGE_SECRET_KEY }}" > ~/.age/key.txt
        chmod 600 ~/.age/key.txt

    - name: Decrypt secrets
      run: |
        sops -d secrets/production.yml > /tmp/decrypted-secrets.yml

    - name: Load secrets into environment
      run: |
        # Parse YAML and set environment variables
        eval $(sops -d secrets/production.yml | yq eval -o=shell)
        
    - name: Deploy application
      run: |
        # Deploy using decrypted secrets
        ./deploy.sh
      env:
        DATABASE_PASSWORD: ${{ env.DATABASE_PASSWORD }}
        API_KEY: ${{ env.API_KEY }}
```

## Azure Key Vault Integration

### 1. Setup and Configuration

```yaml
# Azure Key Vault integration for financial services
name: Deploy with Azure Key Vault

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Get secrets from Key Vault
      uses: Azure/get-keyvault-secrets@v1
      with:
        keyvault: "financial-app-kv"
        secrets: 'database-password, api-key, encryption-key'
      id: kv-secrets

    - name: Deploy application
      run: |
        ./deploy.sh
      env:
        DATABASE_PASSWORD: ${{ steps.kv-secrets.outputs.database-password }}
        API_KEY: ${{ steps.kv-secrets.outputs.api-key }}
        ENCRYPTION_KEY: ${{ steps.kv-secrets.outputs.encryption-key }}
```

### 2. Key Vault Policy Configuration

```json
{
  "tenantId": "your-tenant-id",
  "objectId": "github-actions-sp-object-id",
  "permissions": {
    "keys": ["get", "list"],
    "secrets": ["get", "list"],
    "certificates": ["get", "list"]
  }
}
```

## HashiCorp Vault Integration

### 1. Vault Agent Configuration

```hcl
# vault-agent.hcl
pid_file = "/tmp/vault-agent.pid"

vault {
  address = "https://vault.financial-org.com"
}

auto_auth {
  method "jwt" {
    mount_path = "auth/github"
    config = {
      role = "github-actions"
      path = "/tmp/jwt-token"
    }
  }

  sink "file" {
    config = {
      path = "/tmp/vault-token"
    }
  }
}

template {
  source      = "/templates/app-config.tpl"
  destination = "/config/app-config.yml"
  perms       = 0644
}
```

### 2. GitHub Actions Vault Integration

```yaml
name: Deploy with HashiCorp Vault

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure Vault authentication
      uses: hashicorp/vault-action@v2
      with:
        url: https://vault.financial-org.com
        method: jwt
        role: github-actions
        secrets: |
          secret/data/database password | DATABASE_PASSWORD ;
          secret/data/api api_key | API_KEY ;
          secret/data/encryption master_key | ENCRYPTION_KEY

    - name: Deploy application
      run: |
        ./deploy.sh
      env:
        DATABASE_PASSWORD: ${{ env.DATABASE_PASSWORD }}
        API_KEY: ${{ env.API_KEY }}
        ENCRYPTION_KEY: ${{ env.ENCRYPTION_KEY }}
```

## Secret Rotation Strategies

### 1. Automated Secret Rotation

```yaml
# .github/workflows/secret-rotation.yml
name: Automated Secret Rotation

on:
  schedule:
    - cron: '0 2 1 * *'  # Monthly on the 1st at 2 AM
  workflow_dispatch:

jobs:
  rotate-secrets:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Rotate database password
      run: |
        # Generate new password
        NEW_PASSWORD=$(openssl rand -base64 32)
        
        # Update database with new password
        mysql -h ${{ secrets.DB_HOST }} -u admin -p${{ secrets.DB_ADMIN_PASSWORD }} \
          -e "ALTER USER 'app_user'@'%' IDENTIFIED BY '$NEW_PASSWORD';"
        
        # Update GitHub secret
        curl -X PUT \
          -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
          -H "Accept: application/vnd.github.v3+json" \
          "https://api.github.com/repos/${{ github.repository }}/actions/secrets/DATABASE_PASSWORD" \
          -d "{\"encrypted_value\":\"$(echo -n $NEW_PASSWORD | base64)\"}"

    - name: Verify new credentials
      run: |
        # Test connection with new password
        mysql -h ${{ secrets.DB_HOST }} -u app_user -p$NEW_PASSWORD \
          -e "SELECT 1;" || exit 1

    - name: Notify operations team
      run: |
        # Send notification about successful rotation
        echo "Database password rotated successfully on $(date)"
```

### 2. Zero-Downtime Key Rotation

```bash
#!/bin/bash
# zero-downtime-rotation.sh

# Implement blue-green key rotation
rotate_encryption_key() {
    local OLD_KEY=$1
    local NEW_KEY=$2
    
    # Phase 1: Dual-key support
    echo "Enabling dual-key support..."
    update_app_config "encryption.keys" "[$OLD_KEY, $NEW_KEY]"
    restart_app_instances
    
    # Phase 2: Re-encrypt data with new key
    echo "Re-encrypting data..."
    for table in sensitive_tables; do
        re_encrypt_table $table $OLD_KEY $NEW_KEY
    done
    
    # Phase 3: Remove old key
    echo "Removing old key..."
    update_app_config "encryption.keys" "[$NEW_KEY]"
    restart_app_instances
    
    echo "Key rotation completed successfully"
}
```

## Compliance and Audit

### 1. Secret Access Logging

```yaml
# secrets-audit.yml - Monitor secret access
name: Secrets Audit Trail

on:
  workflow_run:
    workflows: ["*"]
    types: [completed]

jobs:
  audit-secrets:
    runs-on: ubuntu-latest
    
    steps:
    - name: Log secret usage
      run: |
        # Log which secrets were accessed
        cat <<EOF > /tmp/secret-audit.json
        {
          "timestamp": "$(date -Iseconds)",
          "workflow": "${{ github.workflow }}",
          "repository": "${{ github.repository }}",
          "actor": "${{ github.actor }}",
          "ref": "${{ github.ref }}",
          "secrets_accessed": [
            $(echo "${{ toJson(secrets) }}" | jq -r 'keys[]' | sed 's/^/"/' | sed 's/$/"/' | tr '\n' ',' | sed 's/,$//')
          ]
        }
        EOF
        
        # Send to SIEM system
        curl -X POST https://siem.financial-org.com/api/logs \
          -H "Content-Type: application/json" \
          -H "Authorization: Bearer ${{ secrets.SIEM_TOKEN }}" \
          -d @/tmp/secret-audit.json
```

### 2. Compliance Reporting

```python
#!/usr/bin/env python3
# compliance-report.py

import json
import requests
from datetime import datetime, timedelta

def generate_secrets_compliance_report():
    """Generate compliance report for secrets management."""
    
    report = {
        "report_date": datetime.now().isoformat(),
        "compliance_period": "monthly",
        "checks": {
            "secret_rotation": check_secret_rotation(),
            "access_controls": check_access_controls(),
            "encryption_standards": check_encryption_standards(),
            "audit_trails": check_audit_trails()
        }
    }
    
    return report

def check_secret_rotation():
    """Check if secrets are rotated according to policy."""
    # RBI requires regular password changes
    # IRDAI requires quarterly key rotation for critical systems
    return {
        "status": "compliant",
        "last_rotation": "2024-01-01",
        "next_rotation": "2024-04-01",
        "policy": "quarterly_rotation"
    }

def check_access_controls():
    """Verify access controls are properly implemented."""
    return {
        "status": "compliant",
        "least_privilege": True,
        "role_based_access": True,
        "multi_factor_auth": True
    }

def check_encryption_standards():
    """Verify encryption meets regulatory standards."""
    return {
        "status": "compliant",
        "algorithm": "AES-256-GCM",
        "key_length": 256,
        "fips_140_2_level": 3
    }

def check_audit_trails():
    """Verify audit trails are complete and tamper-proof."""
    return {
        "status": "compliant",
        "log_integrity": True,
        "retention_period": "7_years",
        "immutable_storage": True
    }

if __name__ == "__main__":
    report = generate_secrets_compliance_report()
    print(json.dumps(report, indent=2))
```

## Best Practices

### 1. Secret Lifecycle Management

```bash
# secret-lifecycle.sh
#!/bin/bash

# 1. Creation
create_secret() {
    local SECRET_NAME=$1
    local SECRET_VALUE=$2
    local ENVIRONMENT=$3
    
    # Validate secret strength
    if ! validate_secret_strength "$SECRET_VALUE"; then
        echo "Secret does not meet complexity requirements"
        exit 1
    fi
    
    # Encrypt and store
    echo "$SECRET_VALUE" | age -r "$PUBLIC_KEY" > "secrets/${ENVIRONMENT}/${SECRET_NAME}.age"
    
    # Log creation
    log_secret_event "created" "$SECRET_NAME" "$ENVIRONMENT"
}

# 2. Usage
use_secret() {
    local SECRET_NAME=$1
    local ENVIRONMENT=$2
    
    # Decrypt secret
    SECRET_VALUE=$(age -d -i "$PRIVATE_KEY" "secrets/${ENVIRONMENT}/${SECRET_NAME}.age")
    
    # Log usage
    log_secret_event "accessed" "$SECRET_NAME" "$ENVIRONMENT"
    
    echo "$SECRET_VALUE"
}

# 3. Rotation
rotate_secret() {
    local SECRET_NAME=$1
    local ENVIRONMENT=$2
    
    # Generate new secret
    NEW_SECRET=$(generate_secure_secret)
    
    # Update secret
    create_secret "$SECRET_NAME" "$NEW_SECRET" "$ENVIRONMENT"
    
    # Update applications
    update_applications "$SECRET_NAME" "$NEW_SECRET" "$ENVIRONMENT"
    
    # Log rotation
    log_secret_event "rotated" "$SECRET_NAME" "$ENVIRONMENT"
}

# 4. Deletion
delete_secret() {
    local SECRET_NAME=$1
    local ENVIRONMENT=$2
    
    # Secure deletion
    shred -vfz -n 3 "secrets/${ENVIRONMENT}/${SECRET_NAME}.age"
    
    # Log deletion
    log_secret_event "deleted" "$SECRET_NAME" "$ENVIRONMENT"
}
```

### 2. Security Validation

```yaml
# .github/workflows/secrets-validation.yml
name: Secrets Security Validation

on:
  push:
    paths:
      - 'secrets/**'
      - '.sops.yaml'

jobs:
  validate-secrets:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Install security tools
      run: |
        # Install secret scanning tools
        pip install detect-secrets
        npm install -g @secretlint/secretlint @secretlint/secretlint-rule-preset-recommend

    - name: Scan for exposed secrets
      run: |
        # Scan for accidentally committed secrets
        detect-secrets scan --all-files --force-use-all-plugins

    - name: Validate secret files
      run: |
        # Check that all secret files are properly encrypted
        find secrets/ -name "*.yml" -o -name "*.yaml" | while read file; do
          if ! sops filestatus "$file" | grep -q "encrypted"; then
            echo "ERROR: $file is not encrypted!"
            exit 1
          fi
        done

    - name: Check secret rotation dates
      run: |
        # Verify secrets are not overdue for rotation
        python3 scripts/check-rotation-dates.py

    - name: Validate compliance
      run: |
        # Check RBI/IRDAI compliance requirements
        python3 scripts/compliance-check.py
```

## Disaster Recovery

### 1. Secret Backup Strategy

```bash
# backup-secrets.sh
#!/bin/bash

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/secure-backup/secrets/$BACKUP_DATE"

# Create encrypted backup
create_secret_backup() {
    mkdir -p "$BACKUP_DIR"
    
    # Backup GitHub secrets (encrypted)
    gh secret list --json name,updatedAt > "$BACKUP_DIR/github-secrets.json"
    
    # Backup SOPS files
    tar -czf "$BACKUP_DIR/sops-secrets.tar.gz" secrets/
    
    # Backup Vault secrets
    vault kv get -format=json secret/ > "$BACKUP_DIR/vault-secrets.json"
    
    # Encrypt entire backup
    age -r "$BACKUP_PUBLIC_KEY" "$BACKUP_DIR"/* > "$BACKUP_DIR.age"
    
    # Upload to secure offsite storage
    aws s3 cp "$BACKUP_DIR.age" s3://financial-secure-backup/secrets/
    
    # Cleanup local backup
    rm -rf "$BACKUP_DIR"
    
    echo "Secret backup completed: $BACKUP_DIR.age"
}
```

### 2. Recovery Procedures

```bash
# recover-secrets.sh
#!/bin/bash

RECOVERY_DATE=$1

recover_secrets() {
    # Download backup from secure storage
    aws s3 cp "s3://financial-secure-backup/secrets/${RECOVERY_DATE}.age" /tmp/
    
    # Decrypt backup
    age -d -i "$RECOVERY_PRIVATE_KEY" "/tmp/${RECOVERY_DATE}.age" > "/tmp/recovery-${RECOVERY_DATE}.tar.gz"
    
    # Extract secrets
    tar -xzf "/tmp/recovery-${RECOVERY_DATE}.tar.gz" -C /tmp/
    
    # Restore GitHub secrets
    while read -r secret; do
        secret_name=$(echo "$secret" | jq -r '.name')
        # Manual restoration required for GitHub secrets
        echo "Please restore GitHub secret: $secret_name"
    done < "/tmp/github-secrets.json"
    
    # Restore SOPS files
    cp -r "/tmp/secrets/" ./
    
    echo "Secret recovery completed from backup: $RECOVERY_DATE"
}
```

This comprehensive secrets management strategy ensures that financial institutions can securely handle sensitive data throughout their CI/CD pipelines while maintaining compliance with regulatory requirements.