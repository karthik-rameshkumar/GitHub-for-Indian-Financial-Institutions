# Deployment Approval Process for BFSI Applications

## Overview
This document outlines the comprehensive deployment approval process for Indian Financial Institutions, ensuring compliance with RBI, SEBI, and IRDAI regulatory requirements while maintaining operational efficiency.

## Regulatory Framework

### RBI IT Framework Requirements
- **Change Management**: All changes must follow documented approval processes
- **Risk Assessment**: Comprehensive risk analysis before production deployments
- **Audit Trail**: Complete documentation of all approval decisions
- **Segregation of Duties**: Multiple approvers from different teams
- **Testing Requirements**: Mandatory testing at each environment level

### SEBI IT Governance
- **System Governance**: Board-level oversight for critical systems
- **Risk Management**: Continuous risk monitoring and assessment
- **Business Continuity**: Impact assessment on business operations
- **Incident Management**: Rollback procedures and incident response

## Multi-Stage Approval Workflow

### Stage 1: Technical Review
**Purpose**: Validate technical implementation and code quality
**Approvers**: Senior Developers, Tech Leads, Solution Architects
**Required Count**: 2 approvals

```yaml
technical_review:
  required_checks:
    - "✅ Code review completed"
    - "✅ Unit tests passing (>85% coverage)"
    - "✅ Integration tests successful"
    - "✅ Code quality gate passed"
    - "✅ Performance benchmarks met"
    - "✅ API documentation updated"
  
  approval_criteria:
    - Code follows organizational standards
    - No critical or high-severity issues
    - Backward compatibility maintained
    - Performance impact acceptable
    - Documentation complete and accurate
  
  approvers:
    teams: ["senior-developers", "tech-leads", "solution-architects"]
    required_count: 2
    timeout: "24 hours"
```

### Stage 2: Security Review
**Purpose**: Ensure security compliance and vulnerability management
**Approvers**: Security Team, InfoSec Team, Cyber Security Officers
**Required Count**: 2 approvals

```yaml
security_review:
  required_checks:
    - "🔒 Security scan passed (no critical vulnerabilities)"
    - "🔒 Dependency check completed"
    - "🔒 Container security scan successful"
    - "🔒 Secrets management validated"
    - "🔒 Authentication/authorization verified"
    - "🔒 Data encryption compliance confirmed"
  
  approval_criteria:
    - No critical or high security vulnerabilities
    - Proper authentication and authorization
    - Data protection measures implemented
    - Secure communication protocols used
    - Audit logging properly configured
    - Incident response procedures documented
  
  approvers:
    teams: ["security-team", "infosec-team", "cyber-security"]
    required_count: 2
    timeout: "48 hours"
  
  escalation:
    - level: "CISO"
      condition: "Critical security findings"
      required: true
```

### Stage 3: Compliance Review
**Purpose**: Validate regulatory compliance and audit requirements
**Approvers**: Compliance Team, Legal Team, Regulatory Experts
**Required Count**: 1 approval

```yaml
compliance_review:
  required_checks:
    - "⚖️ RBI IT Framework compliance verified"
    - "⚖️ SEBI governance requirements met"
    - "⚖️ Data localization compliance confirmed"
    - "⚖️ Audit trail requirements satisfied"
    - "⚖️ Regulatory reporting capability tested"
    - "⚖️ Privacy impact assessment completed"
  
  approval_criteria:
    - Regulatory requirements compliance
    - Data governance standards met
    - Audit trail completeness
    - Privacy and data protection
    - Incident reporting procedures
    - Business continuity planning
  
  approvers:
    teams: ["compliance-team", "legal-team", "regulatory-experts"]
    required_count: 1
    timeout: "72 hours"
  
  documentation_required:
    - "Compliance Assessment Report"
    - "Risk Impact Analysis"
    - "Data Protection Impact Assessment"
    - "Business Continuity Plan"
```

### Stage 4: Business Approval
**Purpose**: Business stakeholder sign-off and impact assessment
**Approvers**: Product Owners, Business Stakeholders, Risk Committee
**Required Count**: 1 approval

```yaml
business_approval:
  required_checks:
    - "📊 Business impact assessment completed"
    - "📊 User acceptance testing passed"
    - "📊 Performance impact evaluated"
    - "📊 Rollback plan validated"
    - "📊 Communication plan prepared"
    - "📊 Training requirements assessed"
  
  approval_criteria:
    - Business requirements satisfied
    - Acceptable risk level
    - User experience validated
    - Operational impact acceptable
    - Support procedures ready
    - Communication plan approved
  
  approvers:
    teams: ["product-owners", "business-stakeholders", "risk-committee"]
    required_count: 1
    timeout: "48 hours"
```

### Stage 5: Final Authorization
**Purpose**: Executive approval for production deployment
**Approvers**: CTO, CISO, Head of Compliance, Release Manager
**Required Count**: 3 approvals

```yaml
final_authorization:
  required_checks:
    - "✅ All previous stages approved"
    - "✅ Deployment window confirmed"
    - "✅ Support team availability verified"
    - "✅ Rollback procedures tested"
    - "✅ Monitoring and alerting configured"
    - "✅ Incident response team ready"
  
  approval_criteria:
    - All stage approvals completed
    - Deployment timing appropriate
    - Risk level acceptable
    - Support readiness confirmed
    - Contingency plans in place
    - Regulatory obligations met
  
  approvers:
    users: ["cto", "ciso", "head-compliance", "release-manager"]
    required_count: 3
    timeout: "24 hours"
  
  special_conditions:
    - quarter_end: "Additional CFO approval required"
    - critical_system: "Board notification required"
    - high_risk: "CEO approval required"
```

## Environment-Specific Approval Requirements

### Development Environment
```yaml
development:
  approval_stages: ["technical_review"]
  required_approvals: 1
  automated_deployment: true
  rollback_automatic: true
```

### UAT Environment
```yaml
uat:
  approval_stages: ["technical_review", "security_review"]
  required_approvals: 2
  automated_deployment: true
  business_validation_required: true
```

### Production Environment
```yaml
production:
  approval_stages: 
    - "technical_review"
    - "security_review" 
    - "compliance_review"
    - "business_approval"
    - "final_authorization"
  required_approvals: 9
  automated_deployment: false
  manual_intervention_required: true
  deployment_window_restricted: true
```

## GitHub Actions Workflow Implementation

### Manual Approval Action
```yaml
- name: '📋 Manual Approval Required'
  uses: trstringer/manual-approval@v1
  with:
    secret: ${{ github.TOKEN }}
    approvers: |
      bfsi-release-managers,
      security-team,
      compliance-officers,
      risk-committee
    minimum-approvals: 3
    issue-title: 'Production Deployment Approval - ${{ github.event.head_commit.message }}'
    issue-body: |
      ## Production Deployment Approval Request
      
      **📋 Deployment Details**
      - **Application**: ${{ github.repository }}
      - **Version**: ${{ github.sha }}
      - **Environment**: Production
      - **Requestor**: ${{ github.actor }}
      - **Deployment Date**: ${{ steps.date.outputs.date }}
      
      **🔍 Pre-Deployment Checklist**
      - [ ] Security scan passed (no critical vulnerabilities)
      - [ ] All tests passing (unit, integration, UAT)
      - [ ] Performance benchmarks met
      - [ ] Code quality gates satisfied
      - [ ] Compliance requirements verified
      - [ ] Business acceptance obtained
      - [ ] Rollback procedures validated
      - [ ] Support team notification sent
      - [ ] Monitoring and alerting configured
      
      **⚖️ Regulatory Compliance Verification**
      - [ ] RBI IT Framework compliance confirmed
      - [ ] SEBI governance requirements satisfied
      - [ ] Data localization requirements met
      - [ ] Audit trail implementation verified
      - [ ] Privacy impact assessment completed
      - [ ] Incident response procedures updated
      
      **🎯 Business Impact Assessment**
      - [ ] User experience impact evaluated
      - [ ] Performance impact acceptable
      - [ ] Business continuity plan reviewed
      - [ ] Customer communication prepared (if required)
      - [ ] Training materials updated (if required)
      
      **🚨 Risk Assessment**
      - **Risk Level**: [LOW/MEDIUM/HIGH/CRITICAL]
      - **Blast Radius**: [LIMITED/MODERATE/EXTENSIVE]
      - **Rollback Complexity**: [SIMPLE/MODERATE/COMPLEX]
      - **Business Impact**: [MINIMAL/MODERATE/SIGNIFICANT]
      
      **📞 Emergency Contacts**
      - **Primary On-Call**: [Name/Contact]
      - **Secondary On-Call**: [Name/Contact]
      - **Business Owner**: [Name/Contact]
      - **Incident Commander**: [Name/Contact]
      
      **⏰ Deployment Window**
      - **Planned Start**: [Date/Time IST]
      - **Expected Duration**: [Duration]
      - **Maintenance Window**: [If applicable]
      
      ---
      
      **Required Approvers:**
      - [ ] **Release Manager** - Deployment authorization
      - [ ] **Security Team Lead** - Security compliance confirmation
      - [ ] **Compliance Officer** - Regulatory compliance sign-off
      - [ ] **Business Owner** - Business impact acceptance
      - [ ] **Technical Lead** - Technical readiness confirmation
      
      **⚠️ Note**: This deployment requires **minimum 3 approvals** from the designated approvers above.
      
      **📝 Instructions for Approvers:**
      1. Review all checklist items above
      2. Verify compliance with your area of responsibility
      3. Comment with your approval reasoning
      4. React with 👍 to approve or 👎 to reject
      
      **🔄 Auto-close**: This issue will auto-close if not approved within 72 hours.
```

### Conditional Approval Based on Risk
```yaml
- name: '🎯 Risk-Based Approval Routing'
  id: risk-assessment
  run: |
    # Determine risk level based on changes
    RISK_LEVEL="LOW"
    
    # Check for high-risk file changes
    if git diff --name-only HEAD~1 | grep -E "(database|migration|config)" > /dev/null; then
      RISK_LEVEL="HIGH"
    fi
    
    # Check commit message for risk indicators
    if echo "${{ github.event.head_commit.message }}" | grep -iE "(critical|urgent|hotfix)" > /dev/null; then
      RISK_LEVEL="CRITICAL"
    fi
    
    echo "risk_level=$RISK_LEVEL" >> $GITHUB_OUTPUT

- name: '📋 Standard Approval (Low Risk)'
  if: steps.risk-assessment.outputs.risk_level == 'LOW'
  uses: trstringer/manual-approval@v1
  with:
    approvers: tech-leads,security-team
    minimum-approvals: 2

- name: '📋 Enhanced Approval (High Risk)'
  if: steps.risk-assessment.outputs.risk_level == 'HIGH'
  uses: trstringer/manual-approval@v1
  with:
    approvers: tech-leads,security-team,compliance-team,risk-committee
    minimum-approvals: 4

- name: '📋 Executive Approval (Critical Risk)'
  if: steps.risk-assessment.outputs.risk_level == 'CRITICAL'
  uses: trstringer/manual-approval@v1
  with:
    approvers: cto,ciso,head-compliance,ceo
    minimum-approvals: 3
```

## Approval Tracking and Audit

### Approval Database Schema
```sql
-- Approval tracking for audit compliance
CREATE TABLE deployment_approvals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deployment_id VARCHAR(255) NOT NULL,
    repository VARCHAR(255) NOT NULL,
    commit_sha VARCHAR(40) NOT NULL,
    environment VARCHAR(50) NOT NULL,
    approval_stage VARCHAR(100) NOT NULL,
    approver_id VARCHAR(255) NOT NULL,
    approver_role VARCHAR(100) NOT NULL,
    approval_status VARCHAR(20) NOT NULL, -- APPROVED, REJECTED, PENDING
    approval_reason TEXT,
    approved_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for audit queries
CREATE INDEX idx_deployment_approvals_audit 
ON deployment_approvals(deployment_id, environment, approved_at);

-- Compliance audit view
CREATE VIEW compliance_audit_trail AS
SELECT 
    da.deployment_id,
    da.repository,
    da.commit_sha,
    da.environment,
    STRING_AGG(da.approval_stage, ', ' ORDER BY da.created_at) as approval_stages,
    STRING_AGG(da.approver_role, ', ' ORDER BY da.created_at) as approver_roles,
    COUNT(*) as total_approvals,
    MIN(da.created_at) as approval_started,
    MAX(da.approved_at) as approval_completed
FROM deployment_approvals da
WHERE da.approval_status = 'APPROVED'
GROUP BY da.deployment_id, da.repository, da.commit_sha, da.environment;
```

### Audit Report Generation
```python
#!/usr/bin/env python3
# generate-approval-audit-report.py

import psycopg2
import pandas as pd
from datetime import datetime, timedelta
import json

def generate_audit_report(start_date, end_date):
    """Generate comprehensive audit report for deployment approvals"""
    
    # Database connection
    conn = psycopg2.connect(
        host=os.environ['DB_HOST'],
        database=os.environ['DB_NAME'],
        user=os.environ['DB_USER'],
        password=os.environ['DB_PASSWORD']
    )
    
    # Query approval data
    query = """
    SELECT 
        deployment_id,
        repository,
        environment,
        approval_stage,
        approver_id,
        approver_role,
        approval_status,
        approved_at,
        EXTRACT(EPOCH FROM (approved_at - created_at))/3600 as approval_duration_hours
    FROM deployment_approvals 
    WHERE created_at BETWEEN %s AND %s
    ORDER BY created_at DESC
    """
    
    df = pd.read_sql_query(query, conn, params=[start_date, end_date])
    
    # Generate summary statistics
    summary = {
        'total_deployments': df['deployment_id'].nunique(),
        'total_approvals': len(df),
        'approval_rate': len(df[df['approval_status'] == 'APPROVED']) / len(df) * 100,
        'average_approval_time_hours': df['approval_duration_hours'].mean(),
        'approvals_by_environment': df.groupby('environment').size().to_dict(),
        'approvals_by_role': df.groupby('approver_role').size().to_dict()
    }
    
    # Generate compliance metrics
    compliance_metrics = {
        'segregation_of_duties': check_segregation_of_duties(df),
        'approval_completeness': check_approval_completeness(df),
        'time_compliance': check_time_compliance(df)
    }
    
    # Create audit report
    report = {
        'report_period': {
            'start_date': start_date.isoformat(),
            'end_date': end_date.isoformat()
        },
        'summary': summary,
        'compliance_metrics': compliance_metrics,
        'detailed_data': df.to_dict('records')
    }
    
    return report

def check_segregation_of_duties(df):
    """Verify segregation of duties compliance"""
    # Check that approvers are from different roles
    violations = []
    
    for deployment_id in df['deployment_id'].unique():
        deployment_approvals = df[df['deployment_id'] == deployment_id]
        roles = deployment_approvals['approver_role'].unique()
        
        if len(roles) < 2:
            violations.append({
                'deployment_id': deployment_id,
                'issue': 'Insufficient role diversity in approvals'
            })
    
    return {
        'compliant': len(violations) == 0,
        'violations': violations
    }

if __name__ == "__main__":
    # Generate report for last 30 days
    end_date = datetime.now()
    start_date = end_date - timedelta(days=30)
    
    report = generate_audit_report(start_date, end_date)
    
    # Save report
    with open(f'approval-audit-report-{end_date.strftime("%Y%m%d")}.json', 'w') as f:
        json.dump(report, f, indent=2, default=str)
    
    print("Audit report generated successfully!")
```

## Emergency Deployment Procedures

### Emergency Override Process
```yaml
emergency_deployment:
  trigger_conditions:
    - "Critical security vulnerability"
    - "System outage affecting customers"
    - "Regulatory deadline compliance"
    - "Data breach containment"
  
  approval_requirements:
    immediate_approvers:
      - "CTO or Deputy CTO"
      - "CISO or Deputy CISO"
      - "Head of Compliance"
    
    post_deployment:
      - "Retrospective review within 24 hours"
      - "Full audit trail documentation"
      - "Risk assessment update"
      - "Board notification (if applicable)"
  
  documentation_required:
    - "Emergency justification"
    - "Risk mitigation measures"
    - "Rollback plan"
    - "Post-deployment validation plan"
```

### Emergency Override Workflow
```yaml
- name: '🚨 Emergency Deployment Override'
  if: contains(github.event.head_commit.message, '[EMERGENCY]')
  uses: trstringer/manual-approval@v1
  with:
    secret: ${{ github.TOKEN }}
    approvers: cto,deputy-cto,ciso,deputy-ciso,head-compliance
    minimum-approvals: 2
    timeout-minutes: 60
    issue-title: '🚨 EMERGENCY DEPLOYMENT - Immediate Action Required'
    issue-body: |
      # 🚨 EMERGENCY DEPLOYMENT AUTHORIZATION
      
      **⚠️ CRITICAL**: This is an emergency deployment request requiring immediate attention.
      
      **Emergency Details:**
      - **Repository**: ${{ github.repository }}
      - **Commit**: ${{ github.sha }}
      - **Requestor**: ${{ github.actor }}
      - **Emergency Type**: [Please specify]
      
      **Emergency Justification:**
      [Please provide detailed justification for emergency deployment]
      
      **Risk Mitigation:**
      - [ ] Rollback plan prepared and tested
      - [ ] Monitoring enhanced for deployment
      - [ ] Support team on standby
      - [ ] Communication plan activated
      
      **Post-Deployment Actions:**
      - [ ] Retrospective review scheduled within 24 hours
      - [ ] Full audit documentation to be completed
      - [ ] Risk assessment to be updated
      - [ ] Regulatory notification (if required)
      
      **Required Emergency Approvers (2 of 5):**
      - [ ] CTO or Deputy CTO
      - [ ] CISO or Deputy CISO  
      - [ ] Head of Compliance
      
      **⏰ Approval Timeout**: 1 hour from creation
```

## Metrics and KPIs

### Approval Process Metrics
- **Mean Time to Approval (MTTA)**: Average time from request to final approval
- **Approval Success Rate**: Percentage of requests approved vs. rejected
- **Compliance Score**: Percentage of deployments meeting all compliance requirements
- **Emergency Override Rate**: Percentage of deployments using emergency procedures

### Monitoring Dashboard
```yaml
approval_metrics_dashboard:
  kpis:
    - name: "Mean Time to Approval"
      target: "< 48 hours"
      measurement: "average"
      
    - name: "Approval Success Rate"
      target: "> 95%"
      measurement: "percentage"
      
    - name: "Compliance Score"
      target: "100%"
      measurement: "percentage"
      
    - name: "Emergency Override Rate"
      target: "< 5%"
      measurement: "percentage"
  
  alerts:
    - condition: "mtta > 72 hours"
      action: "escalate_to_management"
    - condition: "compliance_score < 98%"
      action: "audit_review_required"
```

## Contact Information
- **Release Management**: release-mgmt@bfsi-org.com
- **Security Team**: security@bfsi-org.com
- **Compliance Office**: compliance@bfsi-org.com
- **Emergency Hotline**: +91-XXX-XXX-XXXX