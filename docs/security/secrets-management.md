# Secrets Management for BFSI Applications

## Overview
This document outlines secure secrets management practices for Indian Financial Institutions using SOPS (Secrets OPerationS) and GitHub Actions, ensuring compliance with RBI, SEBI, and IRDAI regulations.

## SOPS (Secrets OPerationS) Integration

### What is SOPS?
SOPS is Mozilla's secrets management tool that encrypts YAML, JSON, ENV, INI and BINARY files. It's particularly well-suited for BFSI environments due to its:
- Strong encryption standards (AES-256-GCM)
- Key management flexibility
- Audit trail capabilities
- Integration with version control systems

### Installation and Setup

#### Installing SOPS
```bash
# Download and install SOPS
curl -LO https://github.com/mozilla/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64
chmod +x sops-v3.8.1.linux.amd64
sudo mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops

# Verify installation
sops --version
```

#### Setting up Age Encryption
```bash
# Install age for key management
curl -LO https://github.com/FiloSottile/age/releases/download/v1.1.1/age-v1.1.1-linux-amd64.tar.gz
tar xzf age-v1.1.1-linux-amd64.tar.gz
sudo mv age/age* /usr/local/bin/

# Generate age key pair
age-keygen -o ~/.config/sops/age/keys.txt

# Set environment variable
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
```

### SOPS Configuration for BFSI

#### .sops.yaml Configuration
```yaml
creation_rules:
  # Development environment
  - path_regex: config/secrets/dev/.*\.yml$
    age: age1dev1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    encrypted_regex: '^(password|secret|key|token|api_key|private_key|cert)$'
    
  # UAT environment
  - path_regex: config/secrets/uat/.*\.yml$
    age: age1uat1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    encrypted_regex: '^(password|secret|key|token|api_key|private_key|cert)$'
    
  # Production environment
  - path_regex: config/secrets/prod/.*\.yml$
    age: age1prod1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    encrypted_regex: '^(password|secret|key|token|api_key|private_key|cert)$'
    
  # Credit engine specific secrets
  - path_regex: config/credit-engine/.*/secrets\.yml$
    age: age1credit1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    encrypted_regex: '^(password|secret|key|token|api_key|model_key|bureau_key)$'
```

### Secret File Structure

#### Database Secrets (Development)
```yaml
# config/secrets/dev/database.yml
database:
  host: dev-db.internal.bfsi.com
  port: 5432
  name: nbfc_core_dev
  username: nbfc_user
  password: "dev_secure_password_123!"
  
redis:
  host: dev-redis.internal.bfsi.com
  port: 6379
  password: "redis_dev_password_456!"
  
connection_pool:
  max_connections: 20
  timeout: 30000
```

#### API Integration Secrets
```yaml
# config/secrets/prod/external-apis.yml
credit_bureaus:
  cibil:
    base_url: "https://api.cibil.com/v2"
    api_key: "cibil_prod_key_xxxxxxxxxx"
    client_id: "cibil_client_12345"
    client_secret: "cibil_secret_abcdef"
    timeout: 30000
    
  equifax:
    base_url: "https://api.equifax.com/v1"
    api_key: "equifax_prod_key_yyyyyyyyyy"
    username: "equifax_user"
    password: "equifax_password_secure"
    
  experian:
    base_url: "https://api.experian.com/v1"
    subscription_key: "experian_subscription_zzzzzzz"
    oauth_token: "experian_oauth_token_123"

payment_gateways:
  razorpay:
    key_id: "rzp_live_xxxxxxxxxxxxxxxx"
    key_secret: "rzp_secret_yyyyyyyyyyyy"
    webhook_secret: "webhook_secret_zzzzzzz"
    
  hdfc:
    merchant_id: "hdfc_merchant_12345"
    access_code: "hdfc_access_code_abcde"
    working_key: "hdfc_working_key_fghij"
```

#### Regulatory Reporting Secrets
```yaml
# config/secrets/prod/regulatory.yml
rbi_reporting:
  endpoint: "https://rbi-reporting.gov.in/api/v1"
  certificate_path: "/etc/ssl/certs/rbi-client.pem"
  private_key_path: "/etc/ssl/private/rbi-client-key.pem"
  institution_code: "NBFC001234"
  api_version: "2.1"
  
sebi_reporting:
  endpoint: "https://sebi-portal.gov.in/api/reporting"
  username: "sebi_reporting_user"
  password: "sebi_secure_password_xyz"
  entity_id: "SEBI_ENTITY_56789"
  
irdai_reporting:
  endpoint: "https://irdai.gov.in/api/insurance"
  license_number: "IRDAI_LICENSE_98765"
  api_token: "irdai_token_abcdefghijk"
```

### Encrypting Secrets

#### Initial Encryption
```bash
# Encrypt a new secrets file
sops -e config/secrets/prod/database.yml > config/secrets/prod/database.enc.yml

# Edit encrypted file
sops config/secrets/prod/database.enc.yml

# Decrypt for viewing (temporary)
sops -d config/secrets/prod/database.enc.yml
```

#### Batch Operations
```bash
#!/bin/bash
# encrypt-all-secrets.sh - Batch encrypt all secret files

ENVIRONMENTS=("dev" "uat" "prod")
SECRET_TYPES=("database" "external-apis" "regulatory" "application")

for env in "${ENVIRONMENTS[@]}"; do
    for type in "${SECRET_TYPES[@]}"; do
        if [ -f "config/secrets/${env}/${type}.yml" ]; then
            echo "Encrypting ${env}/${type}.yml..."
            sops -e "config/secrets/${env}/${type}.yml" > "config/secrets/${env}/${type}.enc.yml"
            rm "config/secrets/${env}/${type}.yml"  # Remove plaintext
        fi
    done
done
```

## GitHub Actions Integration

### Setting up Repository Secrets
```bash
# Required GitHub repository secrets
SOPS_AGE_KEY_DEV="AGE-SECRET-KEY-1..."      # Development key
SOPS_AGE_KEY_UAT="AGE-SECRET-KEY-1..."      # UAT key  
SOPS_AGE_KEY_PROD="AGE-SECRET-KEY-1..."     # Production key

# Additional secrets for external integrations
REGISTRY_USERNAME="docker_registry_user"
REGISTRY_PASSWORD="docker_registry_password"
SONAR_TOKEN="sonar_analysis_token"
SLACK_WEBHOOK="https://hooks.slack.com/services/..."
```

### Workflow Integration Example
```yaml
# In your GitHub Actions workflow
- name: '🔐 Decrypt Application Secrets'
  env:
    SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY_PROD }}
  run: |
    # Decrypt production secrets
    sops -d config/secrets/prod/database.enc.yml > /tmp/database.yml
    sops -d config/secrets/prod/external-apis.enc.yml > /tmp/external-apis.yml
    
    # Convert to environment variables
    export DATABASE_HOST=$(yq eval '.database.host' /tmp/database.yml)
    export DATABASE_PASSWORD=$(yq eval '.database.password' /tmp/database.yml)
    export CIBIL_API_KEY=$(yq eval '.credit_bureaus.cibil.api_key' /tmp/external-apis.yml)
    
    # Clean up temporary files
    rm -f /tmp/*.yml
```

### Secure Secret Handling in CI/CD
```yaml
- name: '🔒 Secure Secret Processing'
  env:
    SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
  run: |
    # Create secure temporary directory
    TEMP_DIR=$(mktemp -d)
    chmod 700 $TEMP_DIR
    
    # Decrypt secrets to secure location
    sops -d config/secrets/${{ matrix.environment }}/application-secrets.enc.yml > $TEMP_DIR/secrets.yml
    
    # Process secrets with restricted permissions
    (
        umask 077
        yq eval '.spring.datasource.url' $TEMP_DIR/secrets.yml > $TEMP_DIR/db_url
        yq eval '.jwt.secret' $TEMP_DIR/secrets.yml > $TEMP_DIR/jwt_secret
    )
    
    # Use secrets in application
    export SPRING_DATASOURCE_URL=$(cat $TEMP_DIR/db_url)
    export JWT_SECRET=$(cat $TEMP_DIR/jwt_secret)
    
    # Secure cleanup
    shred -vfz -n 3 $TEMP_DIR/*
    rmdir $TEMP_DIR
```

## Security Best Practices

### Key Management
1. **Key Rotation**: Rotate encryption keys quarterly
2. **Access Control**: Limit key access to authorized personnel only
3. **Backup**: Secure backup of encryption keys in multiple locations
4. **Audit**: Regular audit of key usage and access

### Secret Lifecycle Management
1. **Creation**: Use strong, unique passwords/keys
2. **Storage**: Encrypt at rest and in transit
3. **Usage**: Decrypt only when needed, in secure environments
4. **Rotation**: Regular rotation based on risk assessment
5. **Retirement**: Secure deletion of obsolete secrets

### Compliance Considerations

#### RBI IT Framework
- **Data Localization**: Ensure encryption keys remain within India
- **Audit Trail**: Maintain complete logs of secret access
- **Access Controls**: Implement role-based access controls
- **Incident Response**: Document procedures for secret compromise

#### SEBI Guidelines
- **System Governance**: Document secret management procedures
- **Risk Management**: Regular risk assessment of secret management
- **Change Management**: Approval process for secret changes

### Monitoring and Alerting
```yaml
# Secret access monitoring
monitoring:
  alerts:
    - name: "Unauthorized Secret Access"
      condition: "secret_access.user not in authorized_users"
      action: "immediate_alert"
      
    - name: "Secret Decryption Failure"
      condition: "sops_decrypt.status != 'success'"
      action: "security_team_notification"
      
    - name: "Key Usage Anomaly"
      condition: "key_usage.frequency > baseline * 3"
      action: "audit_review_required"
```

## Advanced Configurations

### Multi-Environment Key Management
```yaml
# Advanced SOPS configuration for multiple environments
creation_rules:
  # Environment-specific rules with multiple keys
  - path_regex: config/secrets/prod/.*
    age: >-
      age1prod1security1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,
      age1prod2backup1yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy,
      age1audit1zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz
    pgp: >-
      3AA5C34371567BD2,
      FBC7B9E2A4F9289AC0ED73D7
    encrypted_regex: '^(password|secret|key|token|api_key)$'
    
  # Credit risk model secrets
  - path_regex: models/credit-risk/secrets/.*
    age: age1model1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    encrypted_regex: '^(model_weights|api_key|training_data_key)$'
```

### Integration with Hardware Security Modules (HSM)
```bash
#!/bin/bash
# HSM integration for enhanced security

# Configure SOPS with HSM
export SOPS_KMS_ARN="arn:aws:kms:ap-south-1:123456789012:key/12345678-1234-1234-1234-123456789012"
export SOPS_HSM_PIN="hsm_pin_secure"

# Encrypt with HSM backing
sops -e --kms $SOPS_KMS_ARN config/secrets/prod/critical-secrets.yml
```

## Troubleshooting

### Common Issues
1. **Decryption Failures**: Verify age key and permissions
2. **Key Not Found**: Check SOPS_AGE_KEY environment variable
3. **Permission Denied**: Verify file permissions and user access
4. **Invalid Format**: Ensure YAML/JSON syntax is correct

### Debugging Commands
```bash
# Test SOPS configuration
sops --config .sops.yaml -e /dev/null

# Verify key access
age-keygen -y ~/.config/sops/age/keys.txt

# Check encrypted file metadata
sops --show-master-keys config/secrets/prod/database.enc.yml
```

## Compliance Audit Checklist
- [ ] All secrets encrypted at rest
- [ ] Access to decryption keys logged and monitored  
- [ ] Regular key rotation implemented
- [ ] Backup and recovery procedures documented
- [ ] Incident response plan includes secret compromise scenarios
- [ ] Regular security assessments of secret management practices
- [ ] Compliance with data localization requirements
- [ ] Audit trail retention meets regulatory requirements

## Support and Contact
- **Security Team**: security@bfsi-org.com
- **DevOps Team**: devops@bfsi-org.com
- **Compliance Office**: compliance@bfsi-org.com