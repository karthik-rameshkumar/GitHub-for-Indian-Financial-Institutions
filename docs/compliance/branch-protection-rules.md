# Branch Protection Rules for BFSI Applications

## Overview
This document outlines branch protection rule templates specifically designed for Indian Financial Institutions to ensure compliance with regulatory requirements and maintain secure development practices.

## Standard Branch Protection Configuration

### Main Branch Protection
```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "security-scan",
      "build-and-test",
      "quality-gate",
      "regulatory-compliance",
      "vulnerability-scan"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 3,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "dismissal_restrictions": {
      "users": [],
      "teams": ["security-team", "compliance-team"]
    },
    "required_approving_review_count_for_compliance": 2
  },
  "restrictions": {
    "users": [],
    "teams": ["senior-developers", "tech-leads", "security-team"],
    "apps": ["github-actions"]
  },
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
```

### Develop Branch Protection
```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "security-scan",
      "build-and-test",
      "unit-tests",
      "integration-tests"
    ]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "required_approving_review_count": 2,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "restrictions": {
    "users": [],
    "teams": ["developers", "tech-leads"],
    "apps": ["github-actions"]
  },
  "allow_force_pushes": false,
  "allow_deletions": false
}
```

### Release Branch Protection
```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "security-scan",
      "build-and-test",
      "quality-gate",
      "performance-test",
      "regulatory-compliance",
      "penetration-test"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 4,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true,
    "dismissal_restrictions": {
      "users": [],
      "teams": ["security-team", "compliance-team", "risk-committee"]
    }
  },
  "restrictions": {
    "users": [],
    "teams": ["release-managers", "security-team"],
    "apps": []
  },
  "required_linear_history": true,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
```

## CODEOWNERS Configuration

### Repository-wide CODEOWNERS
```
# CODEOWNERS file for BFSI repository
# This file defines code ownership for different parts of the repository

# Global owners (required for all changes)
* @security-team @compliance-team

# Core application code
/src/main/java/com/bfsi/core/ @tech-leads @senior-developers
/src/main/java/com/bfsi/security/ @security-team @crypto-specialists
/src/main/java/com/bfsi/compliance/ @compliance-team @regulatory-experts

# Database and migration scripts
/src/main/resources/db/ @database-team @security-team
/flyway/ @database-team @tech-leads

# Configuration files
/config/ @devops-team @security-team
/config/secrets/ @security-team @infosec-team
*.yml @devops-team
*.properties @devops-team

# CI/CD pipelines
/.github/workflows/ @devops-team @security-team
/scripts/ @devops-team @tech-leads

# Docker and containerization
/Dockerfile @devops-team @security-team
/docker-compose*.yml @devops-team
/k8s/ @devops-team @sre-team

# Documentation
/docs/ @tech-writers @compliance-team
README.md @tech-leads @compliance-team

# Financial/Credit specific code
/src/main/java/com/bfsi/credit/ @credit-risk-team @actuaries
/src/main/java/com/bfsi/underwriting/ @underwriting-team @risk-analysts
/src/main/java/com/bfsi/regulatory/ @compliance-team @legal-team

# API endpoints
/src/main/java/com/bfsi/api/ @api-team @security-team
/src/main/java/com/bfsi/controllers/ @backend-team @api-team

# Test files
/src/test/ @qa-team @developers
/src/test/java/com/bfsi/security/ @security-team @qa-team

# Build and dependency management
pom.xml @tech-leads @security-team
/gradle/ @tech-leads @devops-team
build.gradle @tech-leads @devops-team

# Regulatory and compliance specific
/compliance/ @compliance-team @legal-team @auditors
/audit/ @auditors @compliance-team
/regulatory-reports/ @regulatory-experts @compliance-team
```

## Environment-Specific Protection Rules

### Production Environment Rules
```yaml
# .github/branch-protection/production.yml
name: "Production Branch Protection"
branches:
  - "main"
  - "master"
  - "production"

protection_rules:
  required_status_checks:
    strict: true
    contexts:
      - "security/codeql-analysis"
      - "security/dependency-check"
      - "security/container-scan"
      - "compliance/regulatory-check"
      - "compliance/audit-trail"
      - "quality/sonarqube-gate"
      - "testing/integration-tests"
      - "testing/performance-tests"
      - "testing/security-tests"
      - "approval/risk-committee"
      - "approval/security-team"
      - "approval/compliance-officer"

  required_reviews:
    count: 4
    dismiss_stale: true
    require_code_owners: true
    required_approvers:
      - security-team
      - compliance-team  
      - risk-committee
      - release-managers
    dismissal_restrictions:
      - security-team
      - compliance-team

  restrictions:
    push_restrictions:
      - release-managers
      - security-team
    merge_restrictions:
      - release-managers
      - cto
      - security-head

  additional_rules:
    require_linear_history: true
    allow_force_pushes: false
    allow_deletions: false
    require_conversation_resolution: true
    require_signed_commits: true
```

### UAT Environment Rules
```yaml
# .github/branch-protection/uat.yml
name: "UAT Branch Protection"
branches:
  - "uat"
  - "staging"
  - "pre-production"

protection_rules:
  required_status_checks:
    strict: true
    contexts:
      - "security/basic-scan"
      - "quality/code-quality"
      - "testing/unit-tests"
      - "testing/integration-tests"
      - "compliance/basic-check"

  required_reviews:
    count: 2
    dismiss_stale: true
    require_code_owners: true
    required_approvers:
      - tech-leads
      - qa-team

  restrictions:
    push_restrictions:
      - developers
      - tech-leads
      - qa-team
```

## Compliance-Specific Rules

### RBI IT Framework Compliance
```yaml
# RBI IT Framework specific branch protection
rbi_compliance:
  mandatory_checks:
    - "security/data-localization-check"
    - "security/encryption-validation"
    - "audit/change-management"
    - "audit/approval-workflow"
    - "security/access-control-review"
    
  required_approvals:
    - role: "Chief Information Security Officer"
      required: true
    - role: "Compliance Officer"
      required: true
    - role: "Risk Manager"
      required: true
      
  documentation_requirements:
    - "Change Impact Assessment"
    - "Security Risk Assessment"
    - "Business Continuity Impact"
    - "Regulatory Compliance Certificate"
```

### SEBI Guidelines Compliance
```yaml
# SEBI IT Governance specific rules
sebi_compliance:
  mandatory_checks:
    - "governance/system-audit"
    - "governance/risk-assessment"
    - "security/cyber-resilience"
    - "audit/system-documentation"
    
  required_approvals:
    - role: "Chief Technology Officer"
      required: true
    - role: "Chief Risk Officer"
      required: true
    - role: "Compliance Head"
      required: true
```

## Advanced Protection Patterns

### Multi-Stage Approval Workflow
```yaml
# Multi-stage approval for critical changes
approval_stages:
  stage_1_technical:
    required_approvers: 2
    allowed_teams:
      - "senior-developers"
      - "tech-leads"
    required_checks:
      - "build-and-test"
      - "code-quality"
      
  stage_2_security:
    required_approvers: 2
    allowed_teams:
      - "security-team"
      - "infosec-team"
    required_checks:
      - "security-scan"
      - "vulnerability-assessment"
      
  stage_3_compliance:
    required_approvers: 1
    allowed_teams:
      - "compliance-team"
    required_checks:
      - "regulatory-compliance"
      - "audit-requirements"
      
  stage_4_business:
    required_approvers: 1
    allowed_teams:
      - "business-stakeholders"
      - "product-owners"
    required_checks:
      - "business-impact-assessment"
```

### Time-Based Restrictions
```yaml
# Time-based deployment windows
deployment_windows:
  production:
    allowed_times:
      - day: "monday"
        start: "02:00"
        end: "04:00"
        timezone: "Asia/Kolkata"
      - day: "wednesday"
        start: "02:00"
        end: "04:00"
        timezone: "Asia/Kolkata"
    
    blocked_periods:
      - name: "Quarter End"
        description: "No deployments during quarter end"
        pattern: "last_week_of_quarter"
      - name: "RBI Reporting Period"
        description: "No changes during RBI reporting"
        dates: ["2024-03-31", "2024-06-30", "2024-09-30", "2024-12-31"]
```

## GitHub CLI Scripts for Setup

### Bulk Branch Protection Setup
```bash
#!/bin/bash
# setup-branch-protection.sh

REPO="your-org/bfsi-application"
GITHUB_TOKEN="${GITHUB_TOKEN}"

# Setup main branch protection
gh api repos/$REPO/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["security-scan","build-and-test","quality-gate"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":3,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  --field restrictions='{"users":[],"teams":["security-team","release-managers"],"apps":["github-actions"]}' \
  --field required_linear_history=true \
  --field allow_force_pushes=false \
  --field allow_deletions=false

# Setup develop branch protection
gh api repos/$REPO/branches/develop/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["security-scan","build-and-test"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":2,"dismiss_stale_reviews":true,"require_code_owner_reviews":true}' \
  --field restrictions='{"users":[],"teams":["developers","tech-leads"],"apps":["github-actions"]}'

echo "Branch protection rules applied successfully!"
```

### Protection Rule Validation Script
```bash
#!/bin/bash
# validate-protection-rules.sh

REPO="your-org/bfsi-application"
BRANCHES=("main" "develop" "release/v1.0")

for branch in "${BRANCHES[@]}"; do
    echo "Checking protection rules for branch: $branch"
    
    # Get current protection rules
    protection_rules=$(gh api repos/$REPO/branches/$branch/protection 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "✅ Protection rules exist for $branch"
        
        # Validate required checks
        required_checks=$(echo $protection_rules | jq -r '.required_status_checks.contexts[]')
        echo "Required status checks: $required_checks"
        
        # Validate review requirements
        review_count=$(echo $protection_rules | jq -r '.required_pull_request_reviews.required_approving_review_count')
        echo "Required approving reviews: $review_count"
        
    else
        echo "❌ No protection rules found for $branch"
    fi
    echo "---"
done
```

## Monitoring and Compliance

### Branch Protection Audit Script
```python
#!/usr/bin/env python3
# audit-branch-protection.py

import requests
import json
import os
from datetime import datetime

def audit_branch_protection(org, repo, token):
    """Audit branch protection rules for compliance"""
    
    headers = {
        'Authorization': f'token {token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    # Get all branches
    branches_url = f'https://api.github.com/repos/{org}/{repo}/branches'
    response = requests.get(branches_url, headers=headers)
    branches = response.json()
    
    audit_report = {
        'repository': f'{org}/{repo}',
        'audit_date': datetime.now().isoformat(),
        'branches': []
    }
    
    for branch in branches:
        branch_name = branch['name']
        protection_url = f'https://api.github.com/repos/{org}/{repo}/branches/{branch_name}/protection'
        
        try:
            protection_response = requests.get(protection_url, headers=headers)
            if protection_response.status_code == 200:
                protection_data = protection_response.json()
                
                # Analyze compliance
                compliance_score = calculate_compliance_score(protection_data)
                
                audit_report['branches'].append({
                    'name': branch_name,
                    'protected': True,
                    'compliance_score': compliance_score,
                    'protection_rules': protection_data
                })
            else:
                audit_report['branches'].append({
                    'name': branch_name,
                    'protected': False,
                    'compliance_score': 0,
                    'issues': ['No protection rules configured']
                })
                
        except Exception as e:
            audit_report['branches'].append({
                'name': branch_name,
                'protected': False,
                'compliance_score': 0,
                'error': str(e)
            })
    
    return audit_report

def calculate_compliance_score(protection_data):
    """Calculate compliance score based on RBI/SEBI requirements"""
    score = 0
    max_score = 100
    
    # Required status checks (20 points)
    if protection_data.get('required_status_checks', {}).get('strict'):
        score += 20
    
    # Required reviews (30 points)
    reviews = protection_data.get('required_pull_request_reviews', {})
    if reviews.get('required_approving_review_count', 0) >= 2:
        score += 30
    
    # Admin enforcement (20 points)
    if protection_data.get('enforce_admins'):
        score += 20
    
    # Linear history (15 points)
    if protection_data.get('required_linear_history'):
        score += 15
    
    # Force push restrictions (15 points)
    if not protection_data.get('allow_force_pushes'):
        score += 15
    
    return min(score, max_score)

if __name__ == "__main__":
    org = os.environ.get('GITHUB_ORG')
    repo = os.environ.get('GITHUB_REPO')
    token = os.environ.get('GITHUB_TOKEN')
    
    report = audit_branch_protection(org, repo, token)
    
    # Generate compliance report
    with open('branch-protection-audit.json', 'w') as f:
        json.dump(report, f, indent=2)
    
    print("Branch protection audit completed!")
    print(f"Report saved to: branch-protection-audit.json")
```

## Troubleshooting

### Common Issues and Solutions

1. **Status Check Failures**
   ```bash
   # Check required status checks
   gh api repos/org/repo/branches/main/protection --jq '.required_status_checks.contexts'
   ```

2. **Permission Issues**
   ```bash
   # Verify user permissions
   gh api repos/org/repo/collaborators/username/permission
   ```

3. **Review Requirements Not Met**
   ```bash
   # Check review configuration
   gh api repos/org/repo/branches/main/protection --jq '.required_pull_request_reviews'
   ```

## Best Practices

1. **Regular Audits**: Conduct monthly audits of branch protection rules
2. **Compliance Monitoring**: Automated monitoring of rule compliance
3. **Documentation**: Maintain up-to-date documentation of all rules
4. **Training**: Regular training for development teams on protection rules
5. **Exception Handling**: Clear process for handling rule exceptions

## Contact Information
- **Security Team**: security@bfsi-org.com
- **Compliance Office**: compliance@bfsi-org.com
- **DevOps Team**: devops@bfsi-org.com