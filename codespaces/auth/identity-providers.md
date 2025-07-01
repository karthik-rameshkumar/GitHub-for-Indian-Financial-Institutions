# Identity Provider Integration for BFSI Codespaces

## Overview

This document provides detailed integration guidance for connecting various enterprise identity providers with GitHub Codespaces for Indian Financial Institutions, ensuring seamless authentication while maintaining regulatory compliance and security standards.

## 🏢 Supported Identity Providers

### Enterprise Identity Provider Matrix

```yaml
identity_provider_support:
  tier_1_providers:
    azure_active_directory:
      protocols: ["SAML 2.0", "OpenID Connect", "WS-Federation"]
      compliance_certifications: ["SOC 2", "ISO 27001", "FedRAMP"]
      indian_data_residency: "Available in India South/Central regions"
      mfa_support: "Native with Conditional Access"
      risk_rating: "Low"
      implementation_complexity: "Low"
      
    okta:
      protocols: ["SAML 2.0", "OpenID Connect", "OAuth 2.0"]
      compliance_certifications: ["SOC 2", "ISO 27001", "HIPAA"]
      indian_data_residency: "Available with Indian data centers"
      mfa_support: "Adaptive MFA with risk assessment"
      risk_rating: "Low"
      implementation_complexity: "Medium"
      
    ping_identity:
      protocols: ["SAML 2.0", "OpenID Connect", "OAuth 2.0"]
      compliance_certifications: ["SOC 2", "ISO 27001", "Common Criteria"]
      indian_data_residency: "Configurable with local deployment"
      mfa_support: "PingID with fraud detection"
      risk_rating: "Low"
      implementation_complexity: "Medium"
  
  tier_2_providers:
    auth0:
      protocols: ["SAML 2.0", "OpenID Connect", "OAuth 2.0"]
      compliance_certifications: ["SOC 2", "ISO 27001"]
      indian_data_residency: "Available in Asia-Pacific regions"
      mfa_support: "Guardian MFA"
      risk_rating: "Medium"
      implementation_complexity: "Low"
      
    onelogin:
      protocols: ["SAML 2.0", "OpenID Connect"]
      compliance_certifications: ["SOC 2", "ISO 27001"]
      indian_data_residency: "Limited availability"
      mfa_support: "OneLogin Protect"
      risk_rating: "Medium"
      implementation_complexity: "Medium"
  
  not_recommended:
    public_cloud_only:
      reason: "Data residency concerns for BFSI"
      alternatives: ["Private cloud deployment", "Hybrid solutions"]
      
    limited_compliance:
      reason: "Insufficient compliance certifications"
      alternatives: ["Tier 1 providers with full compliance"]
```

## 🔧 Azure Active Directory Integration

### Detailed Configuration

```yaml
azure_ad_integration:
  prerequisites:
    azure_subscription: "Required with Indian region preference"
    azure_ad_license: "Azure AD Premium P1 minimum, P2 recommended"
    github_enterprise: "Organization with SAML SSO capability"
    network_connectivity: "Secure connection to Azure endpoints"
    
  step_by_step_configuration:
    azure_ad_setup:
      enterprise_application:
        name: "GitHub Enterprise BFSI"
        template: "GitHub Enterprise Managed User"
        assignment_required: true
        visible_to_users: true
        
      application_properties:
        homepage_url: "https://github.com/orgs/${GITHUB_ORG}"
        identifier_uris: ["https://github.com/orgs/${GITHUB_ORG}"]
        reply_urls: 
          - "https://github.com/orgs/${GITHUB_ORG}/saml/consume"
          - "https://github.com/orgs/${GITHUB_ORG}/saml/acs"
        logout_url: "https://github.com/logout"
      
      certificate_configuration:
        signing_option: "Sign SAML assertion"
        signing_algorithm: "SHA-256"
        certificate_validity: "3 years"
        notification_email: "identity-admin@bfsi-org.com"
        
      claims_configuration:
        name_identifier:
          format: "Email address"
          source: "user.mail"
          
        additional_claims:
          - name: "givenname"
            source: "user.givenname"
          - name: "surname"  
            source: "user.surname"
          - name: "emailaddress"
            source: "user.mail"
          - name: "department"
            source: "user.department"
          - name: "employeeid"
            source: "user.employeeid"
          - name: "groups"
            source: "user.assignedroles"
    
    github_configuration:
      organization_settings:
        enable_saml_sso: true
        require_saml_sso: true
        
      identity_provider_settings:
        sign_on_url: "https://login.microsoftonline.com/${TENANT_ID}/saml2"
        issuer: "https://sts.windows.net/${TENANT_ID}/"
        public_certificate: "${BASE64_ENCODED_CERTIFICATE}"
        
      attribute_mapping:
        administrator: "user.assignedroles contains 'GitHub Admin'"
        login: "user.mail"
        name: "user.displayname"
        email: "user.mail"
        public_profile_info: "user.givenname + ' ' + user.surname"
```

### Conditional Access Policies

```yaml
conditional_access_policies:
  github_codespaces_access:
    policy_name: "BFSI - GitHub Codespaces Access Control"
    state: "enabled"
    
    assignments:
      users_and_groups:
        include: 
          - "GitHub Developers"
          - "GitHub Senior Developers"
          - "GitHub Security Team"
        exclude:
          - "Break Glass Accounts"
          - "Service Accounts"
      
      cloud_apps:
        include: ["GitHub Enterprise BFSI"]
        exclude: []
      
      conditions:
        locations:
          include: 
            - "India Office Locations"
            - "Approved Remote Locations"
          exclude:
            - "High Risk Countries"
            - "Unknown Locations"
        
        device_platforms:
          include: ["Windows", "macOS", "Linux"]
          exclude: ["iOS", "Android"]  # Mobile access restricted
        
        client_apps:
          include: ["Browser", "Modern authentication clients"]
          exclude: ["Legacy authentication protocols"]
        
        sign_in_risk:
          include: ["Low", "Medium"]
          exclude: ["High"]  # High risk blocked
        
        user_risk:
          include: ["Low", "Medium"]
          exclude: ["High"]  # High risk users blocked
    
    access_controls:
      grant:
        operator: "AND"
        controls:
          - "Require multi-factor authentication"
          - "Require device to be marked as compliant"
          - "Require hybrid Azure AD joined device"
          - "Require approved client app"
      
      session:
        - "Sign-in frequency: 8 hours"
        - "Persistent browser session: Never"
        - "Conditional Access App Control: Monitor only"
  
  privileged_access:
    policy_name: "BFSI - GitHub Privileged Access"
    state: "enabled"
    
    assignments:
      users_and_groups:
        include:
          - "GitHub Organization Owners"
          - "GitHub Security Administrators"
      
      cloud_apps:
        include: ["GitHub Enterprise BFSI"]
    
    access_controls:
      grant:
        operator: "AND"
        controls:
          - "Require multi-factor authentication"
          - "Require device to be marked as compliant"
          - "Require approved client app"
          - "Require password change"  # For high-privilege access
      
      session:
        - "Sign-in frequency: 1 hour"
        - "Persistent browser session: Never"
```

## 🔐 Okta Integration Configuration

### Okta SAML Setup

```yaml
okta_integration:
  application_configuration:
    app_type: "SAML 2.0"
    app_name: "GitHub Enterprise BFSI"
    label: "GitHub Enterprise SSO"
    
    general_settings:
      single_sign_on_url: "https://github.com/orgs/${GITHUB_ORG}/saml/consume"
      audience_uri: "https://github.com/orgs/${GITHUB_ORG}"
      default_relay_state: ""
      name_id_format: "EmailAddress"
      application_username: "Email"
      
    attribute_statements:
      - name: "login"
        format: "Basic"
        value: "user.login"
      - name: "email"
        format: "Basic"
        value: "user.email"
      - name: "name"
        format: "Basic"
        value: "user.firstName + ' ' + user.lastName"
      - name: "department"
        format: "Basic"
        value: "user.department"
      - name: "employee_id"
        format: "Basic"
        value: "user.employeeNumber"
    
    group_attribute_statements:
      - name: "groups"
        format: "Basic"
        filter: "Starts with: GitHub_"
        value: "group.name"
  
  sign_on_policy:
    policy_name: "BFSI GitHub Access Policy"
    priority: 1
    
    conditions:
      network_connection: "Specific networks"
      allowed_networks:
        - "BFSI Corporate Network"
        - "BFSI VPN"
        - "Approved Remote Locations"
      
      device_platform: "Any device platform"
      
    actions:
      access: "Allow"
      multifactor_authentication:
        required: true
        type: "Factor Sequence"
        factors:
          - "Password"
          - "Okta Verify Push"
        
      re_authentication_frequency: "8 hours"
      session_persistent: false
  
  adaptive_mfa:
    risk_assessment:
      enabled: true
      factors:
        - "Device fingerprint"
        - "IP reputation"
        - "Geolocation"
        - "Time-based patterns"
        - "Behavioral analysis"
    
    risk_policies:
      low_risk:
        action: "Allow"
        additional_factors: []
        
      medium_risk:
        action: "Require additional factor"
        additional_factors: ["Okta Verify Push"]
        
      high_risk:
        action: "Deny"
        additional_factors: []
        notification: "Security team alert"
```

## 🏛️ BFSI-Specific Configuration

### Regulatory Compliance Mapping

```yaml
regulatory_compliance_mapping:
  rbi_it_framework:
    authentication_requirements:
      multi_factor_auth:
        implementation: "Azure AD Conditional Access / Okta Adaptive MFA"
        verification: "Policy enforcement logs"
        audit_trail: "Authentication event logs"
        
      strong_passwords:
        implementation: "Azure AD Password Policy / Okta Password Policy"
        verification: "Password complexity validation"
        audit_trail: "Password change events"
        
      session_management:
        implementation: "Conditional Access Session Controls"
        verification: "Session timeout enforcement"
        audit_trail: "Session lifecycle events"
    
    audit_requirements:
      authentication_logging:
        events_logged:
          - "Successful authentications"
          - "Failed authentication attempts"
          - "MFA challenges and responses"
          - "Session establishments and terminations"
          - "Administrative actions"
        
        log_retention: "7 years"
        log_integrity: "Digital signatures"
        log_access: "Role-based with audit trail"
  
  sebi_it_governance:
    access_control_requirements:
      role_based_access:
        implementation: "Azure AD Groups / Okta Groups"
        mapping: "Job roles to GitHub teams"
        verification: "Access certification process"
        
      segregation_of_duties:
        implementation: "Conflicting role detection"
        monitoring: "Access analytics"
        enforcement: "Automated controls"
        
      regular_reviews:
        frequency: "Quarterly"
        scope: "All user access rights"
        approval: "Manager and security team"
  
  irdai_cybersecurity:
    cybersecurity_framework:
      identity_governance:
        implementation: "Automated provisioning/deprovisioning"
        monitoring: "Identity lifecycle management"
        compliance: "Regulatory reporting"
        
      incident_response:
        integration: "SIEM and SOC integration"
        alerting: "Real-time security alerts"
        response: "Automated threat response"
```

### Data Residency and Localization

```yaml
data_residency_configuration:
  azure_ad_india:
    primary_region: "Central India"
    secondary_region: "South India"
    
    data_types:
      identity_data:
        location: "India data centers"
        replication: "Within India only"
        backup: "India region backup"
        
      authentication_logs:
        location: "India data centers"
        retention: "7 years in India"
        access: "India-based administrators only"
        
      metadata:
        location: "India data centers"
        processing: "Within Indian boundaries"
        cross_border_controls: "Blocked"
    
    compliance_verification:
      data_mapping: "Complete data flow documentation"
      residency_audit: "Quarterly verification"
      vendor_attestation: "Annual compliance certificate"
  
  okta_india:
    deployment_model: "Private cloud in India"
    
    data_localization:
      customer_data: "Stored in Indian data centers"
      system_logs: "Retained within India"
      metadata: "Processed locally"
      
    cross_border_restrictions:
      data_transfer: "Prohibited without approval"
      support_access: "India-based support team only"
      escalation: "Compliance officer approval required"
```

## 🔍 Monitoring and Analytics

### Identity Provider Monitoring

```python
#!/usr/bin/env python3
"""
BFSI Identity Provider Monitoring System
Multi-IDP monitoring and compliance verification
"""

import json
import logging
import datetime
import requests
from typing import Dict, List, Optional, Union
from dataclasses import dataclass, asdict
from abc import ABC, abstractmethod

@dataclass
class IDPEvent:
    timestamp: str
    idp_type: str
    event_type: str
    user_id: str
    source_ip: str
    success: bool
    mfa_used: bool
    risk_score: float
    compliance_flags: List[str]

class IDPMonitor(ABC):
    """Abstract base class for IDP monitoring."""
    
    @abstractmethod
    def fetch_events(self, start_time: str, end_time: str) -> List[IDPEvent]:
        pass
    
    @abstractmethod
    def check_compliance(self, event: IDPEvent) -> Dict:
        pass

class AzureADMonitor(IDPMonitor):
    """Azure AD specific monitoring implementation."""
    
    def __init__(self, config: Dict):
        self.config = config
        self.logger = logging.getLogger(__name__)
    
    def fetch_events(self, start_time: str, end_time: str) -> List[IDPEvent]:
        """Fetch authentication events from Azure AD."""
        try:
            # Azure AD Graph API call
            headers = {
                'Authorization': f"Bearer {self._get_access_token()}",
                'Content-Type': 'application/json'
            }
            
            url = f"https://graph.microsoft.com/v1.0/auditLogs/signIns"
            params = {
                '$filter': f"createdDateTime ge {start_time} and createdDateTime le {end_time}",
                '$select': 'id,createdDateTime,userPrincipalName,clientAppUsed,ipAddress,location,riskDetail,status,mfaDetail'
            }
            
            response = requests.get(url, headers=headers, params=params)
            response.raise_for_status()
            
            events = []
            for item in response.json().get('value', []):
                event = IDPEvent(
                    timestamp=item['createdDateTime'],
                    idp_type='Azure AD',
                    event_type='authentication',
                    user_id=item['userPrincipalName'],
                    source_ip=item['ipAddress'],
                    success=item['status']['errorCode'] == 0,
                    mfa_used=bool(item.get('mfaDetail')),
                    risk_score=self._calculate_risk_score(item),
                    compliance_flags=self._extract_compliance_flags(item)
                )
                events.append(event)
            
            return events
            
        except Exception as e:
            self.logger.error(f"Failed to fetch Azure AD events: {e}")
            return []
    
    def check_compliance(self, event: IDPEvent) -> Dict:
        """Check Azure AD event compliance."""
        compliance_checks = {
            'rbi_mfa_required': event.mfa_used,
            'rbi_location_verified': self._verify_indian_location(event.source_ip),
            'sebi_role_based_access': self._verify_rbac(event.user_id),
            'irdai_data_residency': self._verify_data_residency(event)
        }
        
        return {
            'compliance_status': all(compliance_checks.values()),
            'checks': compliance_checks,
            'violations': [k for k, v in compliance_checks.items() if not v]
        }

class OktaMonitor(IDPMonitor):
    """Okta specific monitoring implementation."""
    
    def __init__(self, config: Dict):
        self.config = config
        self.logger = logging.getLogger(__name__)
    
    def fetch_events(self, start_time: str, end_time: str) -> List[IDPEvent]:
        """Fetch authentication events from Okta."""
        try:
            headers = {
                'Authorization': f"SSWS {self.config['api_token']}",
                'Content-Type': 'application/json'
            }
            
            url = f"https://{self.config['domain']}/api/v1/logs"
            params = {
                'since': start_time,
                'until': end_time,
                'filter': 'eventType eq "user.authentication.sso"'
            }
            
            response = requests.get(url, headers=headers, params=params)
            response.raise_for_status()
            
            events = []
            for item in response.json():
                event = IDPEvent(
                    timestamp=item['published'],
                    idp_type='Okta',
                    event_type='authentication',
                    user_id=item['actor']['alternateId'],
                    source_ip=item['client']['ipAddress'],
                    success=item['outcome']['result'] == 'SUCCESS',
                    mfa_used=self._check_mfa_used(item),
                    risk_score=self._calculate_okta_risk_score(item),
                    compliance_flags=self._extract_okta_compliance_flags(item)
                )
                events.append(event)
            
            return events
            
        except Exception as e:
            self.logger.error(f"Failed to fetch Okta events: {e}")
            return []
    
    def check_compliance(self, event: IDPEvent) -> Dict:
        """Check Okta event compliance."""
        compliance_checks = {
            'rbi_mfa_required': event.mfa_used,
            'rbi_session_timeout': self._verify_session_timeout(event),
            'sebi_access_controls': self._verify_access_controls(event.user_id),
            'irdai_cybersecurity': self._verify_cybersecurity_controls(event)
        }
        
        return {
            'compliance_status': all(compliance_checks.values()),
            'checks': compliance_checks,
            'violations': [k for k, v in compliance_checks.items() if not v]
        }

class MultiIDPMonitor:
    """Centralized monitoring for multiple identity providers."""
    
    def __init__(self, config_file: str):
        with open(config_file, 'r') as f:
            self.config = json.load(f)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('/workspace/logs/audit/idp-monitoring.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
        
        # Initialize IDP monitors
        self.monitors = {}
        if 'azure_ad' in self.config:
            self.monitors['azure_ad'] = AzureADMonitor(self.config['azure_ad'])
        if 'okta' in self.config:
            self.monitors['okta'] = OktaMonitor(self.config['okta'])
    
    def collect_all_events(self, start_time: str, end_time: str) -> List[IDPEvent]:
        """Collect events from all configured IDPs."""
        all_events = []
        
        for idp_name, monitor in self.monitors.items():
            try:
                events = monitor.fetch_events(start_time, end_time)
                all_events.extend(events)
                self.logger.info(f"Collected {len(events)} events from {idp_name}")
            except Exception as e:
                self.logger.error(f"Failed to collect events from {idp_name}: {e}")
        
        return sorted(all_events, key=lambda x: x.timestamp)
    
    def generate_compliance_report(self, events: List[IDPEvent]) -> Dict:
        """Generate comprehensive compliance report."""
        total_events = len(events)
        successful_events = sum(1 for e in events if e.success)
        mfa_events = sum(1 for e in events if e.mfa_used)
        
        compliance_violations = []
        for event in events:
            for idp_name, monitor in self.monitors.items():
                if event.idp_type.lower().replace(' ', '_') == idp_name:
                    compliance_result = monitor.check_compliance(event)
                    if not compliance_result['compliance_status']:
                        compliance_violations.extend(compliance_result['violations'])
        
        report = {
            'report_metadata': {
                'generated_at': datetime.datetime.utcnow().isoformat(),
                'total_events': total_events,
                'idp_sources': list(self.monitors.keys())
            },
            
            'summary_metrics': {
                'authentication_success_rate': (successful_events / total_events) * 100 if total_events > 0 else 0,
                'mfa_adoption_rate': (mfa_events / total_events) * 100 if total_events > 0 else 0,
                'compliance_violation_rate': (len(compliance_violations) / total_events) * 100 if total_events > 0 else 0
            },
            
            'compliance_analysis': {
                'rbi_compliance_score': self._calculate_rbi_compliance_score(events),
                'sebi_compliance_score': self._calculate_sebi_compliance_score(events),
                'irdai_compliance_score': self._calculate_irdai_compliance_score(events),
                'overall_compliance_score': self._calculate_overall_compliance_score(events)
            },
            
            'recommendations': self._generate_recommendations(events, compliance_violations),
            
            'audit_trail': {
                'data_sources': list(self.monitors.keys()),
                'collection_timestamp': datetime.datetime.utcnow().isoformat(),
                'retention_period': '7 years as per RBI requirements'
            }
        }
        
        return report

def main():
    """Main monitoring function."""
    monitor = MultiIDPMonitor('/workspace/config/multi-idp-config.json')
    
    # Collect events for the last 24 hours
    end_time = datetime.datetime.utcnow()
    start_time = end_time - datetime.timedelta(hours=24)
    
    events = monitor.collect_all_events(
        start_time.isoformat(),
        end_time.isoformat()
    )
    
    # Generate compliance report
    report = monitor.generate_compliance_report(events)
    
    # Save report
    report_file = f"/workspace/logs/audit/multi-idp-report-{datetime.date.today()}.json"
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"Multi-IDP compliance report generated: {report_file}")
    print(f"Total events processed: {len(events)}")
    print(f"Overall compliance score: {report['compliance_analysis']['overall_compliance_score']:.2f}")

if __name__ == "__main__":
    main()
```

## 📞 Support and Troubleshooting

### Common Integration Issues

```yaml
troubleshooting_guide:
  azure_ad_issues:
    certificate_errors:
      symptoms: "SAML signature validation failures"
      causes: ["Expired certificate", "Incorrect certificate format"]
      solutions: ["Renew certificate", "Re-upload in correct format"]
      
    attribute_mapping_errors:
      symptoms: "User provisioning failures, incorrect user data"
      causes: ["Incorrect claim configuration", "Missing user attributes"]
      solutions: ["Verify claim mapping", "Update user profile data"]
      
    conditional_access_blocks:
      symptoms: "Users unable to access despite valid credentials"
      causes: ["Overly restrictive policies", "Non-compliant devices"]
      solutions: ["Review CA policies", "Ensure device compliance"]
  
  okta_issues:
    group_assignment_problems:
      symptoms: "Users not getting proper GitHub team membership"
      causes: ["Incorrect group rules", "Missing group assignments"]
      solutions: ["Review group rules", "Verify user group membership"]
      
    mfa_enrollment_issues:
      symptoms: "Users unable to complete MFA setup"
      causes: ["Blocked devices", "Network restrictions"]
      solutions: ["Review device policies", "Check network access"]
  
  github_enterprise_issues:
    team_synchronization_failures:
      symptoms: "GitHub teams not syncing with IDP groups"
      causes: ["API rate limits", "Incorrect group mapping"]
      solutions: ["Check API limits", "Verify group name mapping"]
      
    scim_provisioning_errors:
      symptoms: "User provisioning/deprovisioning failures"
      causes: ["SCIM endpoint issues", "Attribute conflicts"]
      solutions: ["Check SCIM configuration", "Resolve attribute conflicts"]

support_escalation:
  level_1:
    scope: "User authentication issues, password resets"
    team: "IT Help Desk"
    contact: "helpdesk@bfsi-org.com"
    sla: "2 hours"
    
  level_2:
    scope: "IDP configuration, attribute mapping, group assignments"
    team: "Identity Team"
    contact: "identity-support@bfsi-org.com"
    sla: "4 hours"
    
  level_3:
    scope: "Security incidents, compliance violations, architecture issues"
    team: "Security Team"
    contact: "security-identity@bfsi-org.com"
    sla: "1 hour"
```

---

**Document Version**: 1.0.0  
**Identity Integration Lead**: [Name]  
**Last Updated**: November 2024  
**Review Frequency**: Semi-annually  
**Approval**: BFSI Identity Governance Committee