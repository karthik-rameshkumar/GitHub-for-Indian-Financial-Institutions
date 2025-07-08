# Security Scanning Tool Integration Guide for BFSI Applications

## Overview

This guide provides comprehensive instructions for integrating Microsoft security scanning tools with GitHub Advanced Security for Indian Financial Institutions. The integration ensures comprehensive security coverage while maintaining compliance with RBI, SEBI, and IRDAI guidelines using Microsoft's suite of security tools.

## Supported Microsoft Security Tools

### 1. Static Application Security Testing (SAST)

#### GitHub CodeQL (Primary)
- **Purpose**: Native GitHub SAST solution with BFSI-specific queries
- **Languages**: Java, JavaScript, TypeScript, Python, C#, Go, Ruby
- **Integration**: Built-in GitHub Actions
- **Compliance**: Supports all Indian financial regulatory frameworks

#### Microsoft Application Inspector
- **Purpose**: Microsoft's open-source SAST tool for comprehensive code analysis
- **Integration**: GitHub Actions with Application Inspector CLI
- **BFSI Features**: Financial services security patterns, regulatory compliance scanning

```yaml
# .github/workflows/application-inspector.yml
name: "Microsoft Application Inspector Analysis"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  application-inspector:
    name: Application Inspector Analysis
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: '8.x'
    
    - name: Install Microsoft Application Inspector
      run: dotnet tool install --global Microsoft.ApplicationInspector.CLI
    
    - name: Run Application Inspector
      run: |
        appinspector analyze -s . \
          -f sarif \
          -o security-reports/appinspector-results.sarif \
          -r https://raw.githubusercontent.com/microsoft/ApplicationInspector/main/AppInspector/rules/default/ \
          --confidence-filters high,medium \
          --severity-filters critical,important,moderate
    
    - name: Upload SARIF results to GitHub
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: security-reports/appinspector-results.sarif
    
    - name: Process Application Inspector Results for BFSI Compliance
      run: |
        # Convert Application Inspector results for compliance reporting
        python3 .github/scripts/appinspector-to-bfsi-report.py \
          --sarif-report security-reports/appinspector-results.sarif \
          --output security-reports/appinspector-compliance.json
```

#### Microsoft Defender for DevOps
- **Purpose**: Comprehensive security analysis integrated with Azure DevOps and GitHub
- **Integration**: GitHub Actions with Defender for DevOps
- **BFSI Features**: Advanced threat protection, compliance reporting, vulnerability management

```yaml
# .github/workflows/defender-devops.yml
name: "Microsoft Defender for DevOps Analysis"

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM

jobs:
  defender-devops:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: 17
        distribution: 'temurin'
    
    - name: Build application
      run: mvn clean package -DskipTests
    
    - name: Microsoft Defender for DevOps Analysis
      uses: microsoft/security-devops-action@v1
      id: msdo
      with:
        categories: 'code,artifacts,IaC,containers'
        
    - name: Upload SARIF results to GitHub
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: ${{ steps.msdo.outputs.sarifFile }}
        
    - name: Upload Defender Results
      uses: actions/upload-artifact@v4
      with:
        name: defender-devops-results
        path: ${{ steps.msdo.outputs.sarifFile }}
```

### 2. Dynamic Application Security Testing (DAST)

#### Microsoft Defender for APIs
- **Purpose**: Dynamic security testing for web applications and APIs
- **Integration**: GitHub Actions with Azure API Management Security
- **BFSI Focus**: Financial application and API security testing

```yaml
# .github/workflows/defender-api-testing.yml
name: "Microsoft Defender API Security Testing"

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 3 * * 2'  # Weekly Tuesday 3 AM

jobs:
  api-security-testing:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Start test application
      run: |
        # Start application in test mode
        docker-compose -f docker-compose.test.yml up -d
        sleep 30
        
    - name: Microsoft Defender API Security Scan
      run: |
        # Use Microsoft's security testing tools
        curl -X POST "https://management.azure.com/subscriptions/${{ secrets.AZURE_SUBSCRIPTION_ID }}/resourceGroups/${{ secrets.AZURE_RG }}/providers/Microsoft.ApiManagement/service/${{ secrets.APIM_SERVICE }}/apis/${{ secrets.API_ID }}/securityTests" \
          -H "Authorization: Bearer ${{ secrets.AZURE_TOKEN }}" \
          -H "Content-Type: application/json" \
          -d '{
            "properties": {
              "testType": "security",
              "targetUrl": "http://localhost:8080/api/",
              "securityChecks": ["sqlInjection", "xss", "authenticationBypass", "sensitiveDataExposure"]
            }
          }'
        
    - name: Azure Security Center API Assessment
      uses: azure/CLI@v1
      with:
        azcliversion: 2.30.0
        inlineScript: |
          az login --service-principal -u ${{ secrets.AZURE_CLIENT_ID }} -p ${{ secrets.AZURE_CLIENT_SECRET }} --tenant ${{ secrets.AZURE_TENANT_ID }}
          az security assessment create --name "custom-api-security-assessment" \
            --status-code "Healthy" \
            --resource-id "/subscriptions/${{ secrets.AZURE_SUBSCRIPTION_ID }}/resourceGroups/${{ secrets.AZURE_RG }}" \
            --additional-data '{"apiEndpoint": "http://localhost:8080/api/"}'
        
    - name: Process Security Test Results
      run: |
        # Convert Microsoft security test results to BFSI compliance format
        python3 .github/scripts/microsoft-dast-to-bfsi-report.py \
          --test-results . \
          --output security-reports/dast-compliance.json
        
    - name: Upload Security Test Results
      uses: actions/upload-artifact@v4
      with:
        name: microsoft-dast-results
        path: security-reports/dast-compliance.json
```

#### Azure Security Center Compliance Assessment
- **Purpose**: Comprehensive security posture assessment using Azure Security Center
- **Integration**: Azure CLI and REST API integration with GitHub Actions
- **BFSI Features**: Financial compliance frameworks, regulatory reporting

### 3. Software Composition Analysis (SCA)

#### GitHub Dependency Review (Primary)
- **Purpose**: Native GitHub dependency vulnerability scanning
- **Integration**: Built-in GitHub Actions and Dependabot
- **BFSI Focus**: Financial services dependency management and license compliance

```yaml
# .github/workflows/github-dependency-review.yml
name: "GitHub Dependency Review"

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  dependency-review:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout Repository
      uses: actions/checkout@v4
      
    - name: Dependency Review
      uses: actions/dependency-review-action@v4
      with:
        # Fail the build if any critical or high vulnerabilities are found
        fail-on-severity: critical
        # Allow specific licenses for BFSI compliance
        allow-licenses: MIT, Apache-2.0, BSD-3-Clause, BSD-2-Clause
        # Deny licenses that may conflict with financial regulations
        deny-licenses: GPL-3.0, AGPL-3.0, LGPL-3.0
        
    - name: Generate BFSI Compliance Report
      run: |
        # Generate dependency compliance report for financial regulations
        python3 .github/scripts/dependency-compliance-report.py \
          --output security-reports/dependency-compliance.json \
          --frameworks RBI,SEBI,IRDAI
```

#### Azure Artifacts Security Scanning
- **Purpose**: Advanced dependency scanning with Azure Artifacts and Microsoft security intelligence
- **Integration**: Azure DevOps integration with GitHub Actions
- **BFSI Features**: Enterprise-grade vulnerability intelligence, license compliance, supply chain security

```yaml
# .github/workflows/azure-artifacts-security.yml
name: "Azure Artifacts Security Analysis"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  azure-artifacts-scan:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        
    - name: Azure CLI Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
        
    - name: Install Azure DevOps Extension
      run: az extension add --name azure-devops
      
    - name: Scan Dependencies with Azure Artifacts
      run: |
        # Use Azure Artifacts to scan for vulnerabilities
        az artifacts universal download \
          --organization ${{ secrets.AZURE_DEVOPS_ORG }} \
          --project ${{ secrets.AZURE_DEVOPS_PROJECT }} \
          --scope project \
          --feed security-intel \
          --name vulnerability-database \
          --version latest \
          --path ./vuln-db
        
        # Run dependency analysis
        python3 .github/scripts/azure-dependency-analysis.py \
          --project-path . \
          --vuln-db ./vuln-db \
          --output security-reports/azure-dependency-scan.sarif
      
    - name: Upload SARIF Results to GitHub
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: security-reports/azure-dependency-scan.sarif
```

### 4. Container Security

#### Microsoft Defender for Containers
- **Purpose**: Comprehensive container security with Microsoft Defender
- **Integration**: Azure integration with GitHub Actions
- **BFSI Focus**: Financial application container security and compliance

```yaml
# .github/workflows/defender-containers.yml
name: "Microsoft Defender for Containers"

on:
  push:
    branches: [ main ]
    paths: [ 'Dockerfile', 'docker-compose.yml' ]

jobs:
  defender-containers:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build Docker image
      run: docker build -t bfsi-app:${{ github.sha }} .
    
    - name: Azure CLI Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Microsoft Defender for Containers Scan
      run: |
        # Push image to Azure Container Registry for scanning
        az acr login --name ${{ secrets.ACR_NAME }}
        docker tag bfsi-app:${{ github.sha }} ${{ secrets.ACR_NAME }}.azurecr.io/bfsi-app:${{ github.sha }}
        docker push ${{ secrets.ACR_NAME }}.azurecr.io/bfsi-app:${{ github.sha }}
        
        # Trigger Defender for Containers scan
        az security assessment create \
          --name "container-vulnerability-assessment" \
          --status-code "Healthy" \
          --resource-id "/subscriptions/${{ secrets.AZURE_SUBSCRIPTION_ID }}/resourceGroups/${{ secrets.AZURE_RG }}/providers/Microsoft.ContainerRegistry/registries/${{ secrets.ACR_NAME }}" \
          --additional-data "{\"imageDigest\": \"${{ github.sha }}\", \"repository\": \"bfsi-app\"}"
        
    - name: Download Defender Scan Results
      run: |
        # Download scan results from Azure Security Center
        az security assessment list \
          --resource-group ${{ secrets.AZURE_RG }} \
          --query "[?name=='container-vulnerability-assessment']" \
          --output json > defender-container-results.json
        
        # Convert to SARIF format
        python3 .github/scripts/defender-to-sarif.py \
          --input defender-container-results.json \
          --output defender-containers.sarif
        
    - name: Upload Defender Results
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: defender-containers.sarif
        
    - name: Generate Financial Compliance Report
      run: |
        python3 .github/scripts/container-compliance-report.py \
          --defender-results defender-container-results.json \
          --compliance-standards RBI,SEBI,ISO27001 \
          --output security-reports/container-compliance.json
```

#### Azure Container Registry Security Features
- **Purpose**: Native Azure container security scanning and policy enforcement
- **Integration**: Azure CLI and PowerShell integration
- **BFSI Features**: Advanced threat protection, compliance validation, security policies

### 5. Infrastructure as Code (IaC) Security

#### Microsoft Defender for Cloud (Infrastructure)
- **Purpose**: Comprehensive IaC security analysis using Microsoft Defender for Cloud
- **Integration**: Azure Resource Manager (ARM) and Bicep template analysis
- **BFSI Focus**: Cloud security and financial compliance validation

```yaml
# .github/workflows/defender-cloud-iac.yml
name: "Microsoft Defender for Cloud IaC Security"

on:
  push:
    branches: [ main ]
    paths: 
      - '**/*.json'  # ARM templates
      - '**/*.bicep' # Bicep templates
      - '**/*.yml'
      - '**/*.yaml'

jobs:
  defender-cloud-iac:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Azure CLI Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Install Azure Security Center CLI Extension
      run: az extension add --name security
    
    - name: Validate ARM Templates with Security Policies
      run: |
        # Validate ARM templates against Azure Security Center policies
        for template in $(find . -name "*.json" -path "*/templates/*"); do
          echo "Validating $template"
          az deployment group validate \
            --resource-group ${{ secrets.AZURE_RG }} \
            --template-file "$template" \
            --parameters @"${template%.*}.parameters.json" || true
        done
    
    - name: Bicep Security Analysis
      run: |
        # Install Bicep CLI
        curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
        chmod +x ./bicep
        sudo mv ./bicep /usr/local/bin/bicep
        
        # Analyze Bicep files
        for bicep_file in $(find . -name "*.bicep"); do
          echo "Analyzing $bicep_file"
          bicep build "$bicep_file" --outfile "${bicep_file%.*}.json"
          
          # Run security analysis on compiled ARM template
          python3 .github/scripts/arm-security-analysis.py \
            --template "${bicep_file%.*}.json" \
            --output "security-reports/$(basename ${bicep_file%.*})-analysis.json"
        done
        
    - name: Azure Policy Compliance Check
      run: |
        # Check compliance with Azure Security Center policies
        az policy state list \
          --resource-group ${{ secrets.AZURE_RG }} \
          --query "[?complianceState=='NonCompliant']" \
          --output json > security-reports/policy-compliance.json
        
    - name: Generate IaC Compliance Report
      run: |
        python3 .github/scripts/azure-iac-compliance-report.py \
          --policy-results security-reports/policy-compliance.json \
          --compliance-frameworks RBI,SEBI,ISO27001 \
          --output security-reports/iac-compliance.json
        
    - name: Upload IaC Security Results
      uses: actions/upload-artifact@v4
      with:
        name: azure-iac-security-results
        path: security-reports/
```

#### Azure Resource Manager (ARM) Security Validation
- **Purpose**: Native Azure template security analysis and best practices validation
- **Integration**: Azure CLI and Azure PowerShell
- **BFSI Features**: Financial services cloud security policies and compliance frameworks

### 6. Secrets Management

#### GitHub Advanced Security Secret Scanning (Primary)
- **Purpose**: Native GitHub secret detection and remediation
- **Integration**: Built-in GitHub Advanced Security feature
- **BFSI Focus**: Financial API keys, certificates, and credentials protection

```yaml
# .github/workflows/github-secret-scanning.yml
name: "GitHub Advanced Security Secret Scanning"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  secret-scanning:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - name: Configure GitHub Secret Scanning
      run: |
        # Enable push protection for secrets (if not already enabled)
        curl -X PATCH \
          -H "Authorization: token ${{ secrets.GITHUB_TOKEN }}" \
          -H "Accept: application/vnd.github.v3+json" \
          https://api.github.com/repos/${{ github.repository }}/secret-scanning/push-protection \
          -d '{"enabled": true}'
        
    - name: Custom Financial Secrets Pattern Scan
      run: |
        # Run custom patterns for financial institution secrets
        python3 .github/scripts/financial-secrets-scan.py \
          --path . \
          --patterns .github/security/financial-secrets-patterns.json \
          --output security-reports/custom-secrets-scan.json
        
    - name: Generate Secrets Compliance Report
      if: always()
      run: |
        python3 .github/scripts/secrets-compliance-report.py \
          --scan-results security-reports/custom-secrets-scan.json \
          --compliance-standards RBI,SEBI \
          --output security-reports/secrets-compliance.json
        
    - name: Upload Secrets Scan Results
      uses: actions/upload-artifact@v4
      with:
        name: github-secrets-scan-results
        path: security-reports/
```

#### Azure Key Vault Security Integration
- **Purpose**: Secure secrets management and monitoring with Azure Key Vault
- **Integration**: Azure Key Vault integration with GitHub Actions
- **BFSI Features**: HSM-backed key storage, audit logging, compliance reporting

```yaml
# .github/workflows/azure-keyvault-security.yml
name: "Azure Key Vault Security Monitoring"

on:
  schedule:
    - cron: '0 6 * * *'  # Daily at 6 AM
  workflow_dispatch:

jobs:
  keyvault-security:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Azure CLI Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    
    - name: Audit Key Vault Access
      run: |
        # Monitor Key Vault access patterns
        az monitor activity-log list \
          --resource-group ${{ secrets.AZURE_RG }} \
          --namespace "Microsoft.KeyVault" \
          --start-time $(date -d "1 day ago" -u +"%Y-%m-%dT%H:%M:%SZ") \
          --output json > security-reports/keyvault-audit.json
    
    - name: Check Key Vault Security Policies
      run: |
        # Validate Key Vault security configuration
        az keyvault show \
          --name ${{ secrets.AZURE_KEYVAULT_NAME }} \
          --output json > security-reports/keyvault-config.json
        
        # Check for compliance with BFSI requirements
        python3 .github/scripts/keyvault-compliance-check.py \
          --config security-reports/keyvault-config.json \
          --audit security-reports/keyvault-audit.json \
          --frameworks RBI,SEBI,ISO27001 \
          --output security-reports/keyvault-compliance.json
    
    - name: Upload Key Vault Security Results
      uses: actions/upload-artifact@v4
      with:
        name: azure-keyvault-security-results
        path: security-reports/
```

## Integration Workflow

### Master Microsoft Security Pipeline

```yaml
# .github/workflows/comprehensive-microsoft-security.yml
name: "Comprehensive Microsoft Security Pipeline"

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM

env:
  JAVA_VERSION: '17'
  NODE_VERSION: '18'
  DOTNET_VERSION: '8.x'

jobs:
  # Phase 1: Microsoft Static Analysis
  microsoft-static-analysis:
    name: "Microsoft Static Security Analysis"
    runs-on: ubuntu-latest
    strategy:
      matrix:
        tool: [codeql, application-inspector, defender-devops]
    
    steps:
    - uses: actions/checkout@v4
      
    - name: Run ${{ matrix.tool }} analysis
      uses: ./.github/workflows/${{ matrix.tool }}-integration.yml
      
  # Phase 2: GitHub Dependency Analysis  
  github-dependency-analysis:
    name: "GitHub Dependency Security Analysis"
    runs-on: ubuntu-latest
        
    steps:
    - uses: actions/checkout@v4
      
    - name: Run GitHub Dependency Review
      uses: ./.github/workflows/github-dependency-review.yml
      
    - name: Run Azure Artifacts Security
      uses: ./.github/workflows/azure-artifacts-security.yml

  # Phase 3: Microsoft Container Security
  microsoft-container-analysis:
    name: "Microsoft Container Security Analysis"
    runs-on: ubuntu-latest
    if: hashFiles('Dockerfile') != ''
        
    steps:
    - uses: actions/checkout@v4
      
    - name: Run Microsoft Defender for Containers
      uses: ./.github/workflows/defender-containers.yml

  # Phase 4: Microsoft Dynamic Analysis (only on main branch)
  microsoft-dynamic-analysis:
    name: "Microsoft Dynamic Security Analysis"
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    needs: [microsoft-static-analysis, github-dependency-analysis]
    
    steps:
    - uses: actions/checkout@v4
      
    - name: Run Microsoft API Security Testing
      uses: ./.github/workflows/defender-api-testing.yml

  # Phase 5: Microsoft Security Consolidation
  microsoft-security-consolidation:
    name: "Microsoft Security Compliance Consolidation"
    runs-on: ubuntu-latest
    needs: [microsoft-static-analysis, github-dependency-analysis, microsoft-container-analysis]
    if: always()
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Download all Microsoft security artifacts
      uses: actions/download-artifact@v4
      
    - name: Consolidate Microsoft security results
      run: |
        python3 .github/scripts/consolidate-microsoft-security-results.py \
          --input-dir . \
          --frameworks RBI,SEBI,ISO27001,IRDAI \
          --output-dir consolidated-microsoft-security-reports/
          
    - name: Generate Microsoft security executive dashboard
      run: |
        python3 .github/scripts/generate-microsoft-dashboard-data.py \
          --metrics consolidated-microsoft-security-reports/security-metrics.json \
          --output consolidated-microsoft-security-reports/executive-dashboard.html
          
    - name: Upload consolidated Microsoft security results
      uses: actions/upload-artifact@v4
      with:
        name: consolidated-microsoft-security-reports
        path: consolidated-microsoft-security-reports/
        retention-days: 90
```

## Microsoft Tool Configuration Templates

### Microsoft Application Inspector Configuration for BFSI

```json
{
  "appinspector-config": {
    "SourcePath": "src/",
    "OutputFilePath": "security-reports/appinspector-results.sarif",
    "OutputFileFormat": "sarif",
    "ConfidenceFilters": ["high", "medium"],
    "SeverityFilters": ["critical", "important", "moderate"],
    "CustomRulesPath": ".github/security/bfsi-security-rules/",
    "FileTimeOut": 60000,
    "ProcessingTimeOut": 0,
    "SingleThread": false,
    "TagsOnly": false,
    "NoShowProgress": true,
    "LogFileLevel": "Error",
    "LogFilePath": "security-reports/appinspector.log",
    "ConsoleVerbosityLevel": "Medium"
  },
  "bfsi-custom-rules": {
    "financial-patterns": [
      "crypto-implementation",
      "payment-processing", 
      "authentication-mechanisms",
      "session-management",
      "data-validation",
      "secure-communications"
    ],
    "compliance-checks": [
      "rbi-guidelines",
      "sebi-requirements", 
      "irdai-standards",
      "iso27001-controls"
    ]
  }
}
```

### Azure Security Center Policy Configuration for Financial Services

```json
{
  "azure-security-policies": {
    "policyDefinitionId": "/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policySetDefinitions/financial-services-security",
    "displayName": "BFSI Security Baseline",
    "description": "Comprehensive security policies for Banking, Financial Services, and Insurance",
    "parameters": {
      "effect": {
        "type": "String",
        "defaultValue": "AuditIfNotExists",
        "allowedValues": ["AuditIfNotExists", "Deny", "Disabled"]
      },
      "minimumTlsVersion": {
        "type": "String", 
        "defaultValue": "1.2",
        "allowedValues": ["1.2", "1.3"]
      },
      "enableAdvancedThreatProtection": {
        "type": "Boolean",
        "defaultValue": true
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Web/sites"
          },
          {
            "field": "tags['environment']",
            "in": ["production", "staging"]
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Security/assessments",
          "name": "bfsi-security-assessment"
        }
      }
    }
  }
}
```

## Compliance Integration

### SARIF to Microsoft Security Compliance Mapping

```python
# .github/scripts/microsoft-sarif-to-compliance.py
import json
import sys
from pathlib import Path

MICROSOFT_COMPLIANCE_MAPPINGS = {
    'RBI': {
        'sql-injection': 'RBI-IT-4.2.1',
        'weak-cryptographic-algorithm': 'RBI-IT-4.3.2',
        'hardcoded-credentials': 'RBI-IT-4.1.3',
        'sensitive-data-exposure': 'RBI-IT-4.3.1',
        'xss': 'RBI-IT-4.2.1',
        'authentication-bypass': 'RBI-IT-4.1.1'
    },
    'SEBI': {
        'access-control': 'SEBI-GOV-3.1',
        'audit-trail': 'SEBI-GOV-3.3',
        'data-integrity': 'SEBI-GOV-3.4'
    },
    'ISO27001': {
        'access-control': 'A.9.1.1',
        'cryptography': 'A.10.1.1',
        'logging': 'A.12.4.1',
        'incident-management': 'A.16.1.1'
    }
}

# Microsoft-specific mapping for Defender for DevOps and Application Inspector
MICROSOFT_TOOLS_MAPPING = {
    'ApplicationInspector': {
        'Financial.Payment.CreditCard': 'RBI-IT-4.3.1',
        'Authentication.Weak': 'RBI-IT-4.1.1',
        'Cryptography.Weak.Hash': 'RBI-IT-4.3.2',
        'Data.Sensitive.PersonalData': 'RBI-IT-4.3.1'
    },
    'DefenderForDevOps': {
        'ContainerVulnerability': 'ISO27001-A.12.6.1',
        'InfrastructureMisconfiguration': 'ISO27001-A.12.1.2',
        'SecretsExposure': 'RBI-IT-4.1.3'
    }
}

def map_microsoft_sarif_to_compliance(sarif_file, framework):
    """Map Microsoft security tool SARIF findings to compliance frameworks"""
    with open(sarif_file, 'r') as f:
        sarif_data = json.load(f)
    
    compliance_findings = []
    
    for run in sarif_data.get('runs', []):
        tool_name = run.get('tool', {}).get('driver', {}).get('name', '')
        
        for result in run.get('results', []):
            rule_id = result.get('ruleId', '')
            
            # Map to compliance control based on Microsoft tool
            control = None
            if tool_name in MICROSOFT_TOOLS_MAPPING:
                for pattern, control_id in MICROSOFT_TOOLS_MAPPING[tool_name].items():
                    if pattern.lower() in rule_id.lower():
                        control = control_id
                        break
            
            # Fallback to general mapping
            if not control:
                for pattern, control_id in MICROSOFT_COMPLIANCE_MAPPINGS.get(framework, {}).items():
                    if pattern in rule_id.lower():
                        control = control_id
                        break
            
            if control:
                compliance_findings.append({
                    'control': control,
                    'finding': result,
                    'severity': result.get('level', 'note'),
                    'framework': framework,
                    'tool': tool_name,
                    'microsoft_security_score': calculate_microsoft_security_score(result)
                })
    
    return compliance_findings

def calculate_microsoft_security_score(result):
    """Calculate Microsoft Security Score impact"""
    severity_scores = {
        'error': 10,
        'warning': 5,
        'note': 1,
        'info': 0
    }
    
    base_score = severity_scores.get(result.get('level', 'info'), 0)
    
    # Adjust based on Microsoft-specific properties
    properties = result.get('properties', {})
    if properties.get('microsoft-security-impact') == 'high':
        base_score *= 2
    elif properties.get('microsoft-security-impact') == 'critical':
        base_score *= 3
    
    return base_score

if __name__ == '__main__':
    sarif_file = sys.argv[1]
    framework = sys.argv[2]
    output_file = sys.argv[3]
    
    findings = map_microsoft_sarif_to_compliance(sarif_file, framework)
    
    with open(output_file, 'w') as f:
        json.dump(findings, f, indent=2)
```

## Monitoring and Alerting

### Microsoft Security Dashboard Integration

```yaml
# .github/workflows/microsoft-security-dashboard-update.yml
name: "Microsoft Security Dashboard Update"

on:
  workflow_run:
    workflows: ["Comprehensive Microsoft Security Pipeline"]
    types: [completed]

jobs:
  update-microsoft-dashboard:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Download Microsoft security results
      uses: actions/download-artifact@v4
      with:
        name: consolidated-microsoft-security-reports
        path: microsoft-security-results/
        
    - name: Update Microsoft security metrics in Azure
      run: |
        # Login to Azure
        az login --service-principal -u ${{ secrets.AZURE_CLIENT_ID }} -p ${{ secrets.AZURE_CLIENT_SECRET }} --tenant ${{ secrets.AZURE_TENANT_ID }}
        
        # Update Azure Monitor metrics
        python3 .github/scripts/update-azure-security-metrics.py \
          --results microsoft-security-results/ \
          --workspace-id ${{ secrets.AZURE_LOG_ANALYTICS_WORKSPACE_ID }} \
          --workspace-key ${{ secrets.AZURE_LOG_ANALYTICS_WORKSPACE_KEY }}
          
    - name: Update Microsoft Sentinel security events
      run: |
        # Send security events to Microsoft Sentinel
        python3 .github/scripts/send-to-sentinel.py \
          --results microsoft-security-results/ \
          --sentinel-workspace ${{ secrets.SENTINEL_WORKSPACE_ID }} \
          --api-key ${{ secrets.SENTINEL_API_KEY }}
          
    - name: Generate Microsoft compliance report
      run: |
        python3 .github/scripts/generate-microsoft-compliance-report.py \
          --metrics microsoft-security-results/security-metrics.json \
          --frameworks RBI,SEBI,ISO27001,IRDAI \
          --output microsoft-compliance-report.json
          
    - name: Send Microsoft Teams notifications
      if: contains(fromJSON(steps.*.outputs.compliance_status), 'NON_COMPLIANT')
      run: |
        # Send alerts for compliance violations via Microsoft Teams
        python3 .github/scripts/send-teams-security-alerts.py \
          --report microsoft-compliance-report.json \
          --webhook-url ${{ secrets.TEAMS_WEBHOOK_URL }} \
          --mention-users ${{ secrets.SECURITY_TEAM_USERS }}
          
    - name: Update Azure DevOps security dashboard
      run: |
        # Update Azure DevOps dashboard with security metrics
        python3 .github/scripts/update-azure-devops-dashboard.py \
          --organization ${{ secrets.AZURE_DEVOPS_ORG }} \
          --project ${{ secrets.AZURE_DEVOPS_PROJECT }} \
          --pat ${{ secrets.AZURE_DEVOPS_PAT }} \
          --security-data microsoft-security-results/
```

## Best Practices

### 1. Microsoft Tool Selection Criteria
- **Coverage**: Ensure Microsoft tools cover SAST, DAST, SCA, and container security
- **Compliance**: Select Microsoft security tools that support financial regulatory requirements
- **Integration**: Leverage native GitHub and Azure integration for seamless workflows
- **Performance**: Consider scan time impact on CI/CD pipeline performance with Microsoft tooling

### 2. Microsoft Security Configuration Management
- **Centralized**: Maintain Microsoft tool configurations in Azure DevOps or GitHub repositories
- **Environment-specific**: Use different Microsoft security configurations for dev/staging/production
- **Regular updates**: Keep Microsoft security tool configurations updated with latest threat intelligence

### 3. Microsoft Security Result Management
- **Deduplication**: Avoid duplicate findings across multiple Microsoft security tools
- **Prioritization**: Use Microsoft Security Score for risk-based prioritization
- **Tracking**: Maintain traceability from finding to remediation using Azure DevOps work items

### 4. Microsoft Security Performance Optimization
- **Parallel execution**: Run Microsoft security scans in parallel using Azure DevOps agents
- **Incremental scanning**: Use Microsoft differential analysis for large repositories
- **Caching**: Cache Microsoft security databases and dependencies in Azure Storage

## Conclusion

This comprehensive integration guide provides a robust Microsoft-only security scanning framework for BFSI applications using GitHub Advanced Security and Microsoft security tools. The Microsoft-centric approach ensures thorough coverage while maintaining compliance with Indian financial regulatory requirements and eliminates conflicts with non-Microsoft tools. Regular updates and monitoring through Microsoft's security ecosystem ensure the security posture remains effective against evolving threats.