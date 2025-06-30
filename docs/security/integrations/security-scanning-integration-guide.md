# Security Scanning Tool Integration Guide for BFSI Applications

## Overview

This guide provides comprehensive instructions for integrating various security scanning tools with GitHub Advanced Security for Indian Financial Institutions. The integration ensures comprehensive security coverage while maintaining compliance with RBI, SEBI, and IRDAI guidelines.

## Supported Security Tools

### 1. Static Application Security Testing (SAST)

#### GitHub CodeQL (Primary)
- **Purpose**: Native GitHub SAST solution with BFSI-specific queries
- **Languages**: Java, JavaScript, TypeScript, Python, C#, Go, Ruby
- **Integration**: Built-in GitHub Actions
- **Compliance**: Supports all Indian financial regulatory frameworks

#### SonarQube Enterprise
- **Purpose**: Comprehensive code quality and security analysis
- **Integration**: GitHub Actions with SonarCloud/SonarQube Server
- **BFSI Features**: Financial services security rules, PCI DSS compliance

```yaml
# .github/workflows/sonarqube-integration.yml
name: "SonarQube Security Analysis"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  sonarqube:
    name: SonarQube Analysis
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
    
    - name: Set up JDK 17
      uses: actions/setup-java@v4
      with:
        java-version: 17
        distribution: 'temurin'
    
    - name: Cache SonarQube packages
      uses: actions/cache@v4
      with:
        path: ~/.sonar/cache
        key: ${{ runner.os }}-sonar
    
    - name: Cache Maven packages
      uses: actions/cache@v4
      with:
        path: ~/.m2
        key: ${{ runner.os }}-m2-${{ hashFiles('**/pom.xml') }}
    
    - name: Build and analyze
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}
      run: |
        mvn clean verify sonar:sonar \
          -Dsonar.projectKey=bfsi-financial-app \
          -Dsonar.organization=your-org \
          -Dsonar.host.url=https://sonarcloud.io \
          -Dsonar.qualitygate.wait=true \
          -Dsonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
    
    - name: Process SonarQube Results for BFSI Compliance
      run: |
        # Convert SonarQube results to SARIF for compliance reporting
        python3 .github/scripts/sonarqube-to-sarif.py \
          --sonar-report target/sonar/report-task.txt \
          --output security-reports/sonarqube-results.sarif
```

#### Veracode Static Analysis
- **Purpose**: Enterprise-grade SAST with financial services focus
- **Integration**: GitHub Actions with Veracode API
- **BFSI Features**: PCI DSS compliance, banking security standards

```yaml
# .github/workflows/veracode-integration.yml
name: "Veracode Security Scan"

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * 1'  # Weekly Monday 2 AM

jobs:
  veracode-scan:
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
    
    - name: Veracode Upload And Scan
      uses: veracode/veracode-uploadandscan-action@0.2.6
      with:
        appname: 'BFSI-PaymentApp'
        createprofile: false
        filepath: 'target/payment-app.jar'
        vid: ${{ secrets.VERACODE_API_ID }}
        vkey: ${{ secrets.VERACODE_API_KEY }}
        criticality: 'VeryHigh'
        scantimeout: 20
        include: '*.jar'
        
    - name: Download Veracode Results
      uses: veracode/veracode-flaws-to-sarif@v2.1.4
      with:
        vid: ${{ secrets.VERACODE_API_ID }}
        vkey: ${{ secrets.VERACODE_API_KEY }}
        appname: 'BFSI-PaymentApp'
        outputfile: 'veracode-results.sarif'
        
    - name: Upload SARIF to GitHub
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: 'veracode-results.sarif'
```

### 2. Dynamic Application Security Testing (DAST)

#### OWASP ZAP
- **Purpose**: Open-source DAST for web applications
- **Integration**: GitHub Actions with ZAP Docker container
- **BFSI Focus**: Financial application security testing

```yaml
# .github/workflows/zap-dast.yml
name: "OWASP ZAP DAST"

on:
  push:
    branches: [ main ]
  schedule:
    - cron: '0 3 * * 2'  # Weekly Tuesday 3 AM

jobs:
  zap-dast:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Start test application
      run: |
        # Start application in test mode
        docker-compose -f docker-compose.test.yml up -d
        sleep 30
        
    - name: ZAP Baseline Scan
      uses: zaproxy/action-baseline@v0.10.0
      with:
        target: 'http://localhost:8080'
        rules_file_name: '.zap/rules.tsv'
        cmd_options: '-a -d -T 60 -m 10'
        
    - name: ZAP Full Scan (Financial APIs)
      uses: zaproxy/action-full-scan@v0.8.0
      with:
        target: 'http://localhost:8080/api/'
        rules_file_name: '.zap/api-rules.tsv'
        cmd_options: '-a -j -T 60'
        
    - name: Process ZAP Results for Financial Compliance
      run: |
        # Convert ZAP results to BFSI compliance format
        python3 .github/scripts/zap-to-bfsi-report.py \
          --zap-report report_html.html \
          --zap-json report_json.json \
          --output security-reports/dast-compliance.json
        
    - name: Upload ZAP Results
      uses: actions/upload-artifact@v4
      with:
        name: zap-dast-results
        path: |
          report_html.html
          report_json.json
          security-reports/dast-compliance.json
```

#### Burp Suite Enterprise
- **Purpose**: Professional DAST for financial applications
- **Integration**: REST API integration with GitHub Actions
- **BFSI Features**: Banking-specific security tests

### 3. Software Composition Analysis (SCA)

#### OWASP Dependency-Check (Primary)
- **Purpose**: Identify vulnerable dependencies
- **Integration**: Maven plugin with GitHub Actions
- **BFSI Focus**: Financial services dependency management

```yaml
# Enhanced dependency check configuration
# pom.xml addition
<plugin>
    <groupId>org.owasp</groupId>
    <artifactId>dependency-check-maven</artifactId>
    <version>8.4.0</version>
    <configuration>
        <format>ALL</format>
        <suppressionFiles>
            <suppressionFile>.github/security/owasp-suppressions.xml</suppressionFile>
        </suppressionFiles>
        <failBuildOnCVSS>7</failBuildOnCVSS>
        <nvdApiKey>${env.NVD_API_KEY}</nvdApiKey>
        <assemblyAnalyzerEnabled>false</assemblyAnalyzerEnabled>
        <nodeAnalyzerEnabled>false</nodeAnalyzerEnabled>
        <nodePackageAnalyzerEnabled>false</nodePackageAnalyzerEnabled>
        <retireJsAnalyzerEnabled>false</retireJsAnalyzerEnabled>
        <bundleAuditAnalyzerEnabled>false</bundleAuditAnalyzerEnabled>
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

#### Snyk
- **Purpose**: Developer-first SCA with container scanning
- **Integration**: GitHub Actions with Snyk CLI
- **BFSI Features**: License compliance, vulnerability prioritization

```yaml
# .github/workflows/snyk-security.yml
name: "Snyk Security Analysis"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  snyk:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Set up Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
        
    - name: Install Snyk CLI
      run: npm install -g snyk
        
    - name: Authenticate Snyk
      run: snyk auth ${{ secrets.SNYK_TOKEN }}
      
    - name: Snyk Test (Dependencies)
      run: |
        snyk test --severity-threshold=medium \
          --json-file-output=snyk-dependencies.json \
          --sarif-file-output=snyk-dependencies.sarif
      continue-on-error: true
      
    - name: Snyk Test (Container)
      if: hashFiles('Dockerfile') != ''
      run: |
        docker build -t snyk-test .
        snyk container test snyk-test \
          --severity-threshold=medium \
          --json-file-output=snyk-container.json \
          --sarif-file-output=snyk-container.sarif
      continue-on-error: true
      
    - name: Upload Snyk Results to GitHub
      uses: github/codeql-action/upload-sarif@v3
      if: always()
      with:
        sarif_file: |
          snyk-dependencies.sarif
          snyk-container.sarif
```

### 4. Container Security

#### Trivy (Primary)
- **Purpose**: Container vulnerability and misconfiguration scanning
- **Integration**: GitHub Actions with Trivy
- **BFSI Focus**: Financial application container security

```yaml
# .github/workflows/trivy-container.yml
name: "Trivy Container Security"

on:
  push:
    branches: [ main ]
    paths: [ 'Dockerfile', 'docker-compose.yml' ]

jobs:
  trivy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Build Docker image
      run: docker build -t bfsi-app:${{ github.sha }} .
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: 'bfsi-app:${{ github.sha }}'
        format: 'sarif'
        output: 'trivy-results.sarif'
        severity: 'CRITICAL,HIGH,MEDIUM'
        
    - name: Run Trivy config scan
      uses: aquasecurity/trivy-action@master
      with:
        scan-type: 'config'
        format: 'sarif'
        output: 'trivy-config.sarif'
        severity: 'CRITICAL,HIGH,MEDIUM'
        
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v3
      with:
        sarif_file: |
          trivy-results.sarif
          trivy-config.sarif
          
    - name: Generate Financial Compliance Report
      run: |
        python3 .github/scripts/trivy-compliance-report.py \
          --trivy-sarif trivy-results.sarif \
          --config-sarif trivy-config.sarif \
          --compliance-standards RBI,SEBI,ISO27001 \
          --output security-reports/container-compliance.json
```

#### Anchore Grype
- **Purpose**: Container vulnerability scanning
- **Integration**: GitHub Actions with Anchore
- **BFSI Features**: Policy-based scanning with financial compliance rules

### 5. Infrastructure as Code (IaC) Security

#### Checkov
- **Purpose**: Static analysis for IaC security and compliance
- **Integration**: GitHub Actions
- **BFSI Focus**: Cloud security and compliance validation

```yaml
# .github/workflows/checkov-iac.yml
name: "Checkov IaC Security"

on:
  push:
    branches: [ main ]
    paths: 
      - '**/*.tf'
      - '**/*.yml'
      - '**/*.yaml'
      - 'Dockerfile'

jobs:
  checkov:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Run Checkov action
      id: checkov
      uses: bridgecrewio/checkov-action@master
      with:
        directory: .
        framework: terraform,dockerfile,github_actions,kubernetes
        output_format: sarif
        output_file_path: checkov-results.sarif
        skip_check: CKV_AWS_18,CKV_AWS_19  # Skip specific checks if needed
        
    - name: Upload Checkov results
      uses: github/codeql-action/upload-sarif@v3
      if: always()
      with:
        sarif_file: checkov-results.sarif
        
    - name: Generate IaC Compliance Report
      run: |
        python3 .github/scripts/iac-compliance-report.py \
          --checkov-sarif checkov-results.sarif \
          --compliance-frameworks RBI,SEBI,ISO27001 \
          --output security-reports/iac-compliance.json
```

#### Terrascan
- **Purpose**: Static analysis for Terraform, Kubernetes, Docker
- **Integration**: GitHub Actions
- **BFSI Features**: Financial services cloud security policies

### 6. Secrets Management

#### TruffleHog (Primary)
- **Purpose**: Detect secrets in code repositories
- **Integration**: GitHub Actions
- **BFSI Focus**: Financial API keys and credentials

```yaml
# .github/workflows/trufflehog-secrets.yml
name: "TruffleHog Secret Scan"

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  trufflehog:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0
        
    - name: TruffleHog OSS
      uses: trufflesecurity/trufflehog@main
      with:
        path: ./
        base: main
        head: HEAD
        extra_args: --debug --only-verified
        
    - name: Generate Secrets Compliance Report
      if: always()
      run: |
        python3 .github/scripts/secrets-compliance-report.py \
          --scan-results . \
          --compliance-standards RBI,SEBI \
          --output security-reports/secrets-compliance.json
```

#### GitLeaks
- **Purpose**: Alternative secrets detection
- **Integration**: GitHub Actions
- **BFSI Features**: Custom patterns for financial data

## Integration Workflow

### Master Security Pipeline

```yaml
# .github/workflows/comprehensive-security.yml
name: "Comprehensive Security Pipeline"

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

jobs:
  # Phase 1: Static Analysis
  static-analysis:
    name: "Static Security Analysis"
    runs-on: ubuntu-latest
    strategy:
      matrix:
        tool: [codeql, sonarqube, veracode]
    
    steps:
    - uses: actions/checkout@v4
      
    - name: Run ${{ matrix.tool }} analysis
      uses: ./.github/workflows/${{ matrix.tool }}-integration.yml
      
  # Phase 2: Dependency Analysis  
  dependency-analysis:
    name: "Dependency Security Analysis"
    runs-on: ubuntu-latest
    strategy:
      matrix:
        tool: [owasp-dependency-check, snyk]
        
    steps:
    - uses: actions/checkout@v4
      
    - name: Run ${{ matrix.tool }} analysis
      uses: ./.github/workflows/${{ matrix.tool }}-integration.yml

  # Phase 3: Container Security
  container-analysis:
    name: "Container Security Analysis"
    runs-on: ubuntu-latest
    if: hashFiles('Dockerfile') != ''
    strategy:
      matrix:
        tool: [trivy, anchore]
        
    steps:
    - uses: actions/checkout@v4
      
    - name: Run ${{ matrix.tool }} analysis
      uses: ./.github/workflows/${{ matrix.tool }}-integration.yml

  # Phase 4: Dynamic Analysis (only on main branch)
  dynamic-analysis:
    name: "Dynamic Security Analysis"
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    needs: [static-analysis, dependency-analysis]
    
    steps:
    - uses: actions/checkout@v4
      
    - name: Run DAST analysis
      uses: ./.github/workflows/zap-dast.yml

  # Phase 5: Compliance Consolidation
  compliance-consolidation:
    name: "Security Compliance Consolidation"
    runs-on: ubuntu-latest
    needs: [static-analysis, dependency-analysis, container-analysis]
    if: always()
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Download all security artifacts
      uses: actions/download-artifact@v4
      
    - name: Consolidate security results
      run: |
        python3 .github/scripts/consolidate-security-results.py \
          --input-dir . \
          --frameworks RBI,SEBI,ISO27001,IRDAI \
          --output-dir consolidated-security-reports/
          
    - name: Generate executive dashboard
      run: |
        python3 .github/scripts/generate-dashboard-data.py \
          --metrics consolidated-security-reports/security-metrics.json \
          --output consolidated-security-reports/executive-dashboard.html
          
    - name: Upload consolidated results
      uses: actions/upload-artifact@v4
      with:
        name: consolidated-security-reports
        path: consolidated-security-reports/
        retention-days: 90
```

## Tool Configuration Templates

### SonarQube Quality Profile for BFSI

```xml
<!-- sonar-project.properties -->
sonar.projectKey=bfsi-financial-app
sonar.projectName=BFSI Financial Application
sonar.projectVersion=1.0

# Source directories
sonar.sources=src/main/java
sonar.tests=src/test/java
sonar.java.binaries=target/classes
sonar.java.test.binaries=target/test-classes

# Coverage reports
sonar.coverage.jacoco.xmlReportPaths=target/site/jacoco/jacoco.xml
sonar.junit.reportPaths=target/surefire-reports

# Quality gates for financial applications
sonar.qualitygate.wait=true

# Security-focused rules for BFSI
sonar.java.checkstyle.reportPaths=target/checkstyle-result.xml
sonar.java.pmd.reportPaths=target/pmd.xml
sonar.java.spotbugs.reportPaths=target/spotbugsXml.xml

# Exclude test files from security analysis
sonar.coverage.exclusions=**/*Test.java,**/*IT.java
sonar.cpd.exclusions=**/*Test.java,**/*IT.java
```

### ZAP Configuration for Financial APIs

```
# .zap/rules.tsv
10010	IGNORE	# Cookie No HttpOnly Flag - handled by framework
10011	IGNORE	# Cookie Without Secure Flag - handled by load balancer
10015	IGNORE	# Incomplete or No Cache-control and Pragma HTTP Header Set
10017	IGNORE	# Cross-Domain JavaScript Source File Inclusion
10020	IGNORE	# X-Frame-Options Header Scanner
10021	IGNORE	# X-Content-Type-Options Header Missing
10023	IGNORE	# Information Disclosure - Debug Error Messages
10025	IGNORE	# Information Disclosure - Sensitive Information in URL
10026	IGNORE	# HTTP Parameter Override
10027	IGNORE	# Information Disclosure - Suspicious Comments
10028	IGNORE	# Open Redirect
10029	IGNORE	# Cookie Poisoning
10030	IGNORE	# User Controllable Charset
10031	IGNORE	# User Controllable HTML Element Attribute (Potential XSS)

# Financial application specific rules
40012	PASS	# Cross Site Scripting (Reflected) - Critical for payment forms
40013	PASS	# Session Fixation - Critical for banking sessions  
40014	PASS	# Cross Site Scripting (Persistent) - Critical for user data
40016	PASS	# Cross Site Scripting (Persistent) - Prime
40017	PASS	# Cross Site Scripting (Persistent) - Spider
40018	PASS	# SQL Injection - Critical for financial data
40019	PASS	# SQL Injection - MySQL - Critical for databases
40020	PASS	# SQL Injection - Hypersonic SQL - Critical for H2 databases
40021	PASS	# SQL Injection - Oracle - Critical for Oracle databases
40022	PASS	# SQL Injection - PostgreSQL - Critical for PostgreSQL
40023	PASS	# Possible Username Enumeration - Security concern for banking
40024	PASS	# SQL Injection - SQLite - Critical for embedded databases
40025	PASS	# Proxy Disclosure - Information disclosure concern
40026	PASS	# Cross Site Scripting (DOM Based)
40027	PASS	# SQL Injection - MsSQL
40028	PASS	# CRLF Injection
```

## Compliance Integration

### SARIF to Compliance Mapping

```python
# .github/scripts/sarif-to-compliance.py
import json
import sys
from pathlib import Path

COMPLIANCE_MAPPINGS = {
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

def map_sarif_to_compliance(sarif_file, framework):
    """Map SARIF findings to compliance frameworks"""
    with open(sarif_file, 'r') as f:
        sarif_data = json.load(f)
    
    compliance_findings = []
    
    for run in sarif_data.get('runs', []):
        for result in run.get('results', []):
            rule_id = result.get('ruleId', '')
            
            # Map to compliance control
            control = None
            for pattern, control_id in COMPLIANCE_MAPPINGS.get(framework, {}).items():
                if pattern in rule_id.lower():
                    control = control_id
                    break
            
            if control:
                compliance_findings.append({
                    'control': control,
                    'finding': result,
                    'severity': result.get('level', 'note'),
                    'framework': framework
                })
    
    return compliance_findings

if __name__ == '__main__':
    sarif_file = sys.argv[1]
    framework = sys.argv[2]
    output_file = sys.argv[3]
    
    findings = map_sarif_to_compliance(sarif_file, framework)
    
    with open(output_file, 'w') as f:
        json.dump(findings, f, indent=2)
```

## Monitoring and Alerting

### Security Dashboard Integration

```yaml
# .github/workflows/security-dashboard-update.yml
name: "Security Dashboard Update"

on:
  workflow_run:
    workflows: ["Comprehensive Security Pipeline"]
    types: [completed]

jobs:
  update-dashboard:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Download security results
      uses: actions/download-artifact@v4
      with:
        name: consolidated-security-reports
        path: security-results/
        
    - name: Update security metrics database
      run: |
        python3 .github/scripts/update-security-metrics.py \
          --results security-results/ \
          --database-url ${{ secrets.SECURITY_DB_URL }} \
          --api-key ${{ secrets.SECURITY_API_KEY }}
          
    - name: Generate compliance report
      run: |
        python3 .github/scripts/generate-compliance-report.py \
          --metrics security-results/security-metrics.json \
          --frameworks RBI,SEBI,ISO27001,IRDAI \
          --output compliance-report.json
          
    - name: Send notifications
      if: contains(fromJSON(steps.*.outputs.compliance_status), 'NON_COMPLIANT')
      run: |
        # Send alerts for compliance violations
        python3 .github/scripts/send-security-alerts.py \
          --report compliance-report.json \
          --channels slack,email,teams
```

## Best Practices

### 1. Tool Selection Criteria
- **Coverage**: Ensure tools cover SAST, DAST, SCA, and container security
- **Compliance**: Select tools that support financial regulatory requirements
- **Integration**: Choose tools with native GitHub integration or good API support
- **Performance**: Consider scan time impact on CI/CD pipeline performance

### 2. Configuration Management
- **Centralized**: Maintain tool configurations in version control
- **Environment-specific**: Use different configurations for dev/staging/production
- **Regular updates**: Keep tool configurations updated with latest security rules

### 3. Result Management
- **Deduplication**: Avoid duplicate findings across multiple tools
- **Prioritization**: Use risk-based prioritization for remediation
- **Tracking**: Maintain traceability from finding to remediation

### 4. Performance Optimization
- **Parallel execution**: Run security scans in parallel where possible
- **Incremental scanning**: Use incremental scans for large repositories
- **Caching**: Cache dependencies and scan databases to improve performance

## Conclusion

This comprehensive integration guide provides a robust security scanning framework for BFSI applications using GitHub Advanced Security. The multi-tool approach ensures thorough coverage while maintaining compliance with Indian financial regulatory requirements. Regular updates and monitoring ensure the security posture remains effective against evolving threats.