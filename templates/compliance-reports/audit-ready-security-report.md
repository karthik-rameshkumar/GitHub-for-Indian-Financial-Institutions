# Audit-Ready Security Report Template

## Executive Summary

**Report Date**: {{report_date}}  
**Report Period**: {{report_period}}  
**Application/System**: {{application_name}}  
**Prepared By**: Security Architecture Team  
**Reviewed By**: {{reviewer_name}}, {{reviewer_title}}  

### Overall Security Posture

| Metric | Current Status | Target | Trend |
|--------|---------------|--------|-------|
| Overall Security Score | {{security_score}}/100 | ≥90 | {{trend_indicator}} |
| Critical Vulnerabilities | {{critical_count}} | 0 | {{critical_trend}} |
| High Priority Issues | {{high_count}} | ≤5 | {{high_trend}} |
| Compliance Score | {{compliance_score}}% | ≥95% | {{compliance_trend}} |
| Mean Time to Remediation | {{mttr}} days | ≤3 days | {{mttr_trend}} |

### Key Findings

{{#if critical_findings}}
#### 🔴 Critical Security Issues
{{#each critical_findings}}
- **{{title}}**: {{description}} ({{component}})
  - **Risk**: {{risk_level}}
  - **Status**: {{status}}
  - **Due Date**: {{due_date}}
{{/each}}
{{else}}
✅ No critical security issues identified
{{/if}}

#### ⚠️ High Priority Recommendations
{{#each high_priority_recommendations}}
1. **{{title}}**: {{description}}
   - **Impact**: {{impact}}
   - **Timeline**: {{timeline}}
   - **Owner**: {{owner}}
{{/each}}

## Regulatory Compliance Assessment

### RBI IT Framework Compliance

**Overall RBI Compliance**: {{rbi_compliance_percentage}}%

| Control Area | Status | Score | Issues | Actions Required |
|-------------|--------|-------|--------|------------------|
| Information Security (4.1) | {{rbi_4_1_status}} | {{rbi_4_1_score}}% | {{rbi_4_1_issues}} | {{rbi_4_1_actions}} |
| Application Security (4.2) | {{rbi_4_2_status}} | {{rbi_4_2_score}}% | {{rbi_4_2_issues}} | {{rbi_4_2_actions}} |
| Data Security (4.3) | {{rbi_4_3_status}} | {{rbi_4_3_score}}% | {{rbi_4_3_issues}} | {{rbi_4_3_actions}} |
| Audit & Monitoring (4.4) | {{rbi_4_4_status}} | {{rbi_4_4_score}}% | {{rbi_4_4_issues}} | {{rbi_4_4_actions}} |

#### RBI Compliance Gaps
{{#each rbi_gaps}}
- **{{control_id}}**: {{description}}
  - **Finding**: {{finding}}
  - **Remediation**: {{remediation}}
  - **Timeline**: {{timeline}}
  - **Priority**: {{priority}}
{{/each}}

### SEBI IT Governance Compliance

**Overall SEBI Compliance**: {{sebi_compliance_percentage}}%

| Governance Area | Status | Score | Issues | Actions Required |
|----------------|--------|-------|--------|------------------|
| System Governance (3.1) | {{sebi_3_1_status}} | {{sebi_3_1_score}}% | {{sebi_3_1_issues}} | {{sebi_3_1_actions}} |
| Risk Management (3.2) | {{sebi_3_2_status}} | {{sebi_3_2_score}}% | {{sebi_3_2_issues}} | {{sebi_3_2_actions}} |
| Business Continuity (4.0) | {{sebi_4_0_status}} | {{sebi_4_0_score}}% | {{sebi_4_0_issues}} | {{sebi_4_0_actions}} |

### ISO 27001:2013 Compliance

**Overall ISO 27001 Compliance**: {{iso_compliance_percentage}}%

| Control Domain | Status | Score | Findings | Remediation |
|---------------|--------|-------|----------|-------------|
| Access Control (A.9) | {{iso_a9_status}} | {{iso_a9_score}}% | {{iso_a9_findings}} | {{iso_a9_remediation}} |
| Cryptography (A.10) | {{iso_a10_status}} | {{iso_a10_score}}% | {{iso_a10_findings}} | {{iso_a10_remediation}} |
| Operations Security (A.12) | {{iso_a12_status}} | {{iso_a12_score}}% | {{iso_a12_findings}} | {{iso_a12_remediation}} |
| Communications Security (A.13) | {{iso_a13_status}} | {{iso_a13_score}}% | {{iso_a13_findings}} | {{iso_a13_remediation}} |
| System Acquisition (A.14) | {{iso_a14_status}} | {{iso_a14_score}}% | {{iso_a14_findings}} | {{iso_a14_remediation}} |
| Incident Management (A.16) | {{iso_a16_status}} | {{iso_a16_score}}% | {{iso_a16_findings}} | {{iso_a16_remediation}} |

## Technical Security Assessment

### Static Application Security Testing (SAST)

#### CodeQL Analysis Results

| Severity | Count | Change from Last Scan | Status |
|----------|-------|---------------------|---------|
| Critical | {{codeql_critical}} | {{codeql_critical_change}} | {{codeql_critical_status}} |
| High | {{codeql_high}} | {{codeql_high_change}} | {{codeql_high_status}} |
| Medium | {{codeql_medium}} | {{codeql_medium_change}} | {{codeql_medium_status}} |
| Low | {{codeql_low}} | {{codeql_low_change}} | {{codeql_low_status}} |

#### Top Security Findings

{{#each top_sast_findings}}
**{{index}}. {{title}}** ({{severity}})
- **Rule**: {{rule_id}}
- **Component**: {{component}}
- **Description**: {{description}}
- **Remediation**: {{remediation}}
- **Compliance Impact**: {{compliance_impact}}

{{/each}}

### Software Composition Analysis (SCA)

#### Dependency Security Assessment

| Category | Count | Risk Level | Action Required |
|----------|-------|-----------|-----------------|
| Critical Vulnerabilities | {{sca_critical}} | {{sca_critical_risk}} | {{sca_critical_action}} |
| High Vulnerabilities | {{sca_high}} | {{sca_high_risk}} | {{sca_high_action}} |
| License Issues | {{sca_license_issues}} | {{sca_license_risk}} | {{sca_license_action}} |
| Outdated Dependencies | {{sca_outdated}} | {{sca_outdated_risk}} | {{sca_outdated_action}} |

#### High-Risk Dependencies

{{#each high_risk_dependencies}}
**{{name}}** ({{current_version}} → {{recommended_version}})
- **CVE**: {{cve_id}} (CVSS: {{cvss_score}})
- **Impact**: {{impact_description}}
- **Financial Risk**: {{financial_risk}}
- **Remediation**: {{remediation_steps}}
- **Timeline**: {{remediation_timeline}}

{{/each}}

### Container Security Assessment

#### Container Vulnerability Scan Results

| Image | Critical | High | Medium | Low | Security Score |
|-------|----------|------|--------|-----|----------------|
{{#each container_results}}
| {{image_name}} | {{critical}} | {{high}} | {{medium}} | {{low}} | {{security_score}}/100 |
{{/each}}

#### Container Configuration Issues

{{#each container_config_issues}}
- **{{severity}}**: {{title}}
  - **Description**: {{description}}
  - **Remediation**: {{remediation}}
  - **Compliance Framework**: {{compliance_framework}}
{{/each}}

### Dynamic Application Security Testing (DAST)

#### Web Application Security Scan

| Test Category | Pass | Fail | Info | Risk Score |
|--------------|------|------|------|------------|
| Authentication | {{dast_auth_pass}} | {{dast_auth_fail}} | {{dast_auth_info}} | {{dast_auth_risk}} |
| Session Management | {{dast_session_pass}} | {{dast_session_fail}} | {{dast_session_info}} | {{dast_session_risk}} |
| Input Validation | {{dast_input_pass}} | {{dast_input_fail}} | {{dast_input_info}} | {{dast_input_risk}} |
| Error Handling | {{dast_error_pass}} | {{dast_error_fail}} | {{dast_error_info}} | {{dast_error_risk}} |
| Cryptography | {{dast_crypto_pass}} | {{dast_crypto_fail}} | {{dast_crypto_info}} | {{dast_crypto_risk}} |

## Financial Services Specific Assessments

### Payment Processing Security

#### PCI DSS Relevant Findings
{{#each pci_findings}}
- **Requirement {{requirement_id}}**: {{description}}
  - **Status**: {{status}}
  - **Evidence**: {{evidence}}
  - **Gap**: {{gap_description}}
  - **Remediation**: {{remediation_plan}}
{{/each}}

#### Payment Data Protection
- **Cardholder Data Environment**: {{cde_status}}
- **Tokenization Status**: {{tokenization_status}}  
- **Encryption Implementation**: {{encryption_status}}
- **Key Management**: {{key_management_status}}

### Customer Data Protection

#### PII Handling Assessment
{{#each pii_assessments}}
- **Data Type**: {{data_type}}
- **Protection Status**: {{protection_status}}
- **Encryption**: {{encryption_method}}
- **Access Controls**: {{access_controls}}
- **Data Localization**: {{localization_status}}
{{/each}}

#### Data Localization Compliance (RBI)
- **Data Residence**: {{data_residence_status}}
- **Cloud Provider**: {{cloud_provider}}
- **Data Center Location**: {{datacenter_location}}
- **Cross-Border Transfer**: {{cross_border_status}}

## Risk Assessment

### Risk Matrix

| Risk Factor | Likelihood | Impact | Overall Risk | Mitigation Status |
|-------------|------------|--------|--------------|-------------------|
{{#each risk_factors}}
| {{factor}} | {{likelihood}} | {{impact}} | {{overall_risk}} | {{mitigation_status}} |
{{/each}}

### Top Business Risks

{{#each top_business_risks}}
**{{index}}. {{title}}** ({{risk_level}})
- **Likelihood**: {{likelihood}}
- **Business Impact**: {{business_impact}}
- **Financial Impact**: {{financial_impact}}
- **Regulatory Impact**: {{regulatory_impact}}
- **Mitigation Plan**: {{mitigation_plan}}
- **Timeline**: {{mitigation_timeline}}
- **Owner**: {{risk_owner}}

{{/each}}

## Remediation Plan

### Immediate Actions (0-7 days)

{{#each immediate_actions}}
**{{index}}. {{title}}**
- **Description**: {{description}}
- **Priority**: {{priority}}
- **Assignee**: {{assignee}}
- **Due Date**: {{due_date}}
- **Resources Required**: {{resources}}
- **Success Criteria**: {{success_criteria}}

{{/each}}

### Short-term Actions (1-4 weeks)

{{#each short_term_actions}}
**{{index}}. {{title}}**
- **Description**: {{description}}
- **Priority**: {{priority}}
- **Assignee**: {{assignee}}
- **Due Date**: {{due_date}}
- **Dependencies**: {{dependencies}}
- **Budget Impact**: {{budget_impact}}

{{/each}}

### Long-term Actions (1-6 months)

{{#each long_term_actions}}
**{{index}}. {{title}}**
- **Description**: {{description}}
- **Strategic Value**: {{strategic_value}}
- **Investment Required**: {{investment}}
- **Timeline**: {{timeline}}
- **Success Metrics**: {{success_metrics}}

{{/each}}

## Security Metrics and KPIs

### Vulnerability Management Metrics

| Metric | Current Period | Previous Period | Target | Trend |
|--------|---------------|-----------------|--------|-------|
| Mean Time to Detection (MTTD) | {{mttd_current}} | {{mttd_previous}} | {{mttd_target}} | {{mttd_trend}} |
| Mean Time to Response (MTTR) | {{mttr_current}} | {{mttr_previous}} | {{mttr_target}} | {{mttr_trend}} |
| Vulnerability Closure Rate | {{closure_rate_current}}% | {{closure_rate_previous}}% | {{closure_rate_target}}% | {{closure_rate_trend}} |
| False Positive Rate | {{fp_rate_current}}% | {{fp_rate_previous}}% | {{fp_rate_target}}% | {{fp_rate_trend}} |

### Compliance Metrics

| Framework | Compliance Score | Previous Score | Target | Status |
|-----------|-----------------|----------------|--------|--------|
| RBI IT Framework | {{rbi_score}}% | {{rbi_previous}}% | 95% | {{rbi_status}} |
| SEBI Guidelines | {{sebi_score}}% | {{sebi_previous}}% | 90% | {{sebi_status}} |
| ISO 27001 | {{iso_score}}% | {{iso_previous}}% | 85% | {{iso_status}} |
| IRDAI Guidelines | {{irdai_score}}% | {{irdai_previous}}% | 90% | {{irdai_status}} |

### Security Investment ROI

- **Security Tool Investment**: {{security_investment}}
- **Risk Reduction Value**: {{risk_reduction_value}}
- **Compliance Cost Avoidance**: {{compliance_cost_avoidance}}
- **Incident Prevention Value**: {{incident_prevention_value}}
- **Total ROI**: {{total_roi}}%

## Audit Evidence

### Documentation Artifacts

{{#each audit_artifacts}}
- **{{type}}**: {{name}}
  - **Location**: {{location}}
  - **Last Updated**: {{last_updated}}
  - **Owner**: {{owner}}
  - **Retention Period**: {{retention_period}}
{{/each}}

### Security Scan Reports

{{#each scan_reports}}
- **{{scan_type}}**: {{report_name}}
  - **Date**: {{scan_date}}
  - **Tool**: {{tool_name}}
  - **Version**: {{tool_version}}
  - **Coverage**: {{coverage_percentage}}%
  - **File Location**: {{file_location}}
{{/each}}

### Change Management Records

{{#each change_records}}
- **Change ID**: {{change_id}}
  - **Date**: {{change_date}}
  - **Type**: {{change_type}}
  - **Security Impact**: {{security_impact}}
  - **Approver**: {{approver}}
  - **Testing Evidence**: {{testing_evidence}}
{{/each}}

## Recommendations for Leadership

### Strategic Recommendations

{{#each strategic_recommendations}}
**{{index}}. {{title}}**
- **Business Justification**: {{business_justification}}
- **Investment Required**: {{investment_required}}
- **ROI Timeline**: {{roi_timeline}}
- **Risk Reduction**: {{risk_reduction}}
- **Compliance Benefit**: {{compliance_benefit}}

{{/each}}

### Operational Improvements

{{#each operational_improvements}}
**{{index}}. {{title}}**
- **Current State**: {{current_state}}
- **Proposed State**: {{proposed_state}}
- **Implementation Effort**: {{implementation_effort}}
- **Business Impact**: {{business_impact}}
- **Success Metrics**: {{success_metrics}}

{{/each}}

## Appendices

### Appendix A: Detailed Findings

[Detailed technical findings with full descriptions, reproduction steps, and remediation guidance]

### Appendix B: Compliance Control Mappings

[Complete mapping of security findings to regulatory controls]

### Appendix C: Tool Configurations

[Security tool configurations and rule sets used for scanning]

### Appendix D: Risk Assessment Methodology

[Detailed explanation of risk scoring and assessment methodology]

---

**Report Classification**: CONFIDENTIAL  
**Distribution**: CISO, CTO, Compliance Officer, Risk Committee  
**Next Review Date**: {{next_review_date}}  
**Report Version**: {{report_version}}

*This report contains sensitive security information and should be handled according to organizational data classification policies.*