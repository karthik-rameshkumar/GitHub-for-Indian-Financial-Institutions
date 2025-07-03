# Cost Management and Controls for BFSI Codespaces

## Overview

This document outlines cost management strategies, resource controls, and budget optimization techniques for GitHub Codespaces deployments in Indian Financial Institutions, ensuring efficient resource utilization while maintaining compliance and security standards.

## 💰 Cost Control Framework

### Resource-Based Pricing Model

```yaml
codespaces_pricing:
  machine_types:
    2_core_4gb:
      cost_per_hour: "$0.18"
      recommended_for: "Basic development, documentation"
      bfsi_use_cases: ["Policy documentation", "Compliance reviews"]
    
    4_core_8gb:
      cost_per_hour: "$0.36"
      recommended_for: "Python microservices development"
      bfsi_use_cases: ["API development", "Database operations"]
    
    8_core_16gb:
      cost_per_hour: "$0.72"
      recommended_for: "Full-stack development, testing"
      bfsi_use_cases: ["Integration testing", "Performance testing"]
    
    16_core_32gb:
      cost_per_hour: "$1.44"
      recommended_for: "Resource-intensive development"
      bfsi_use_cases: ["Data processing", "ML model training"]
  
  storage_pricing:
    included_storage: "15GB"
    additional_storage: "$0.07/GB/month"
    premium_ssd: "$0.15/GB/month"
```

### Cost Allocation Model

```yaml
cost_allocation:
  by_department:
    development_team: 60%
    security_team: 15%
    compliance_team: 10%
    testing_team: 10%
    infrastructure_team: 5%
  
  by_project:
    core_banking_system: 40%
    payment_gateway: 25%
    risk_management: 15%
    compliance_automation: 10%
    mobile_banking: 10%
  
  by_environment:
    development: 50%
    testing: 30%
    staging: 15%
    security_testing: 5%
```

## 🎯 Budget Controls

### Organization-Level Limits

```yaml
organization_budget:
  monthly_limit: "$50,000"
  quarterly_limit: "$140,000"
  annual_limit: "$500,000"
  
  alert_thresholds:
    warning_50: "$25,000"
    warning_75: "$37,500"
    critical_90: "$45,000"
    emergency_95: "$47,500"
  
  auto_actions:
    at_90_percent:
      - "Disable new Codespace creation"
      - "Send alert to finance team"
      - "Require approval for extensions"
    
    at_95_percent:
      - "Stop all non-critical Codespaces"
      - "Escalate to C-level executives"
      - "Initiate budget review process"
```

### Team-Level Budgets

```yaml
team_budgets:
  senior_developers:
    monthly_limit: "$2,000"
    machine_type_limit: "8_core_16gb"
    max_concurrent: 2
    max_hours_per_month: 200
  
  developers:
    monthly_limit: "$1,000"
    machine_type_limit: "4_core_8gb"
    max_concurrent: 1
    max_hours_per_month: 150
  
  junior_developers:
    monthly_limit: "$500"
    machine_type_limit: "2_core_4gb"
    max_concurrent: 1
    max_hours_per_month: 100
  
  security_team:
    monthly_limit: "$3,000"
    machine_type_limit: "16_core_32gb"
    max_concurrent: 3
    max_hours_per_month: 180
    special_permissions: ["security_scanning", "penetration_testing"]
```

### Project-Level Controls

```yaml
project_controls:
  core_banking:
    budget_allocation: "$20,000/month"
    resource_limits:
      max_codespaces: 10
      max_machine_type: "8_core_16gb"
      storage_limit: "500GB"
    
    compliance_requirements:
      audit_logging: "enhanced"
      data_residency: "strict"
      network_restrictions: "maximum"
  
  payment_gateway:
    budget_allocation: "$12,000/month"
    resource_limits:
      max_codespaces: 6
      max_machine_type: "4_core_8gb"
      storage_limit: "300GB"
    
    security_requirements:
      pci_compliance: true
      encryption_mandatory: true
      access_review_frequency: "weekly"
```

## 📊 Usage Monitoring and Analytics

### Real-Time Monitoring Dashboard

```yaml
monitoring_metrics:
  cost_metrics:
    - "Real-time spend rate"
    - "Monthly burn rate"
    - "Budget utilization percentage"
    - "Cost per user/team/project"
    - "Forecast vs actual spending"
  
  usage_metrics:
    - "Active Codespaces count"
    - "Average session duration"
    - "Resource utilization rates"
    - "Idle time percentage"
    - "Peak usage periods"
  
  efficiency_metrics:
    - "Cost per development hour"
    - "Resource efficiency score"
    - "Idle resource waste"
    - "Optimization opportunities"
    - "ROI on development tools"
```

### Automated Cost Monitoring

```python
#!/usr/bin/env python3
"""
BFSI Codespaces Cost Monitoring System
Real-time cost tracking and alerting for financial institutions
"""

import json
import logging
import datetime
from dataclasses import dataclass
from typing import Dict, List, Optional
import requests
import smtplib
from email.mime.text import MimeText

@dataclass
class CostAlert:
    threshold: float
    current_spend: float
    budget_period: str
    team: str
    alert_level: str

class BFSICodespacesCostMonitor:
    """Cost monitoring system for BFSI Codespaces with compliance logging."""
    
    def __init__(self, config_file: str):
        with open(config_file, 'r') as f:
            self.config = json.load(f)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('/workspace/logs/audit/cost-monitoring.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def get_current_usage(self) -> Dict:
        """Fetch current Codespaces usage data."""
        try:
            # GitHub API call to get Codespaces usage
            headers = {
                'Authorization': f"token {self.config['github_token']}",
                'Accept': 'application/vnd.github.v3+json'
            }
            
            # Get organization usage
            org_usage = requests.get(
                f"https://api.github.com/orgs/{self.config['org']}/codespaces/billing",
                headers=headers
            ).json()
            
            # Get detailed usage per user/team
            detailed_usage = self._get_detailed_usage(headers)
            
            usage_data = {
                'timestamp': datetime.datetime.utcnow().isoformat(),
                'total_spend': org_usage.get('total_cost_usd', 0),
                'current_period_spend': org_usage.get('current_billing_cycle', {}).get('cost_usd', 0),
                'detailed_usage': detailed_usage
            }
            
            self.logger.info(f"Retrieved usage data: ${usage_data['current_period_spend']:.2f}")
            return usage_data
            
        except Exception as e:
            self.logger.error(f"Failed to fetch usage data: {e}")
            return {}
    
    def check_budget_thresholds(self, usage_data: Dict) -> List[CostAlert]:
        """Check current spending against budget thresholds."""
        alerts = []
        current_spend = usage_data.get('current_period_spend', 0)
        
        # Organization-level budget checks
        org_budget = self.config['budgets']['organization']['monthly_limit']
        org_thresholds = self.config['budgets']['organization']['alert_thresholds']
        
        for threshold_name, threshold_amount in org_thresholds.items():
            if current_spend >= threshold_amount:
                alert = CostAlert(
                    threshold=threshold_amount,
                    current_spend=current_spend,
                    budget_period='monthly',
                    team='organization',
                    alert_level=threshold_name.split('_')[1]
                )
                alerts.append(alert)
                self.logger.warning(
                    f"Budget threshold {threshold_name} reached: "
                    f"${current_spend:.2f} >= ${threshold_amount:.2f}"
                )
        
        # Team-level budget checks
        for team, team_usage in usage_data.get('detailed_usage', {}).items():
            team_budget = self.config['budgets']['teams'].get(team, {}).get('monthly_limit', 0)
            team_spend = team_usage.get('cost', 0)
            
            if team_spend >= team_budget * 0.9:  # 90% threshold
                alert = CostAlert(
                    threshold=team_budget * 0.9,
                    current_spend=team_spend,
                    budget_period='monthly',
                    team=team,
                    alert_level='warning'
                )
                alerts.append(alert)
        
        return alerts
    
    def take_automated_actions(self, alerts: List[CostAlert]):
        """Execute automated cost control actions based on alerts."""
        for alert in alerts:
            if alert.alert_level == 'critical' and alert.team == 'organization':
                # Organization-wide critical threshold reached
                self._disable_new_codespaces()
                self._notify_finance_team(alert)
                
            elif alert.alert_level == 'warning':
                # Team or project warning threshold
                self._notify_team_leads(alert)
                self._suggest_optimization(alert)
    
    def generate_cost_report(self, usage_data: Dict) -> str:
        """Generate detailed cost analysis report."""
        report = {
            'report_date': datetime.datetime.utcnow().isoformat(),
            'summary': {
                'total_monthly_spend': usage_data.get('current_period_spend', 0),
                'budget_utilization': self._calculate_budget_utilization(usage_data),
                'cost_trends': self._analyze_cost_trends(usage_data),
                'optimization_opportunities': self._identify_optimizations(usage_data)
            },
            'detailed_breakdown': usage_data.get('detailed_usage', {}),
            'compliance_notes': {
                'audit_trail': 'All cost data logged for regulatory compliance',
                'data_residency': 'Usage tracking within Indian boundaries',
                'retention_period': '7 years as per RBI requirements'
            }
        }
        
        # Save report for audit purposes
        report_file = f"/workspace/logs/audit/cost-report-{datetime.date.today()}.json"
        with open(report_file, 'w') as f:
            json.dump(report, f, indent=2)
        
        self.logger.info(f"Cost report generated: {report_file}")
        return json.dumps(report, indent=2)
    
    def _disable_new_codespaces(self):
        """Disable creation of new Codespaces when budget limits are reached."""
        self.logger.critical("COST CONTROL: Disabling new Codespace creation due to budget limits")
        
        # Implementation would involve GitHub API calls to disable Codespaces
        # This is a placeholder for the actual implementation
        try:
            # API call to disable Codespaces creation
            # headers = {'Authorization': f"token {self.config['github_token']}"}
            # requests.patch(f"https://api.github.com/orgs/{self.config['org']}/codespaces/policy", 
            #               json={'enabled': False}, headers=headers)
            
            # Log the action for audit compliance
            audit_entry = {
                'timestamp': datetime.datetime.utcnow().isoformat(),
                'action': 'disable_codespaces_creation',
                'reason': 'budget_limit_exceeded',
                'compliance_framework': 'BFSI_cost_controls'
            }
            
            with open('/workspace/logs/audit/cost-control-actions.log', 'a') as f:
                f.write(json.dumps(audit_entry) + '\n')
                
        except Exception as e:
            self.logger.error(f"Failed to disable Codespaces creation: {e}")
    
    def _notify_finance_team(self, alert: CostAlert):
        """Send cost alert notifications to finance team."""
        subject = f"BFSI Codespaces Budget Alert - {alert.alert_level.upper()}"
        message = f"""
        Budget Alert for BFSI Codespaces Environment
        
        Alert Level: {alert.alert_level.upper()}
        Current Spend: ${alert.current_spend:.2f}
        Budget Threshold: ${alert.threshold:.2f}
        Period: {alert.budget_period}
        Team: {alert.team}
        
        Immediate action may be required to manage costs.
        
        For compliance: This alert is logged in audit trail.
        """
        
        self._send_email(
            to_addresses=self.config['notifications']['finance_team'],
            subject=subject,
            message=message
        )
    
    def _send_email(self, to_addresses: List[str], subject: str, message: str):
        """Send email notifications with audit logging."""
        try:
            msg = MimeText(message)
            msg['Subject'] = subject
            msg['From'] = self.config['notifications']['from_address']
            msg['To'] = ', '.join(to_addresses)
            
            # Send email (implementation depends on mail server configuration)
            # smtp = smtplib.SMTP(self.config['smtp']['server'])
            # smtp.send_message(msg)
            
            # Log notification for audit compliance
            self.logger.info(f"Cost alert notification sent to: {', '.join(to_addresses)}")
            
        except Exception as e:
            self.logger.error(f"Failed to send cost alert notification: {e}")

# Usage monitoring script
def main():
    """Main cost monitoring function."""
    monitor = BFSICodespacesCostMonitor('/workspace/config/cost-monitoring-config.json')
    
    # Get current usage data
    usage_data = monitor.get_current_usage()
    
    # Check budget thresholds
    alerts = monitor.check_budget_thresholds(usage_data)
    
    # Take automated actions if needed
    if alerts:
        monitor.take_automated_actions(alerts)
    
    # Generate daily cost report
    report = monitor.generate_cost_report(usage_data)
    print(report)

if __name__ == "__main__":
    main()
```

## 🚨 Cost Optimization Strategies

### Automated Optimization

```yaml
optimization_rules:
  idle_codespace_detection:
    criteria:
      - "No activity for 30 minutes"
      - "CPU usage < 5%"
      - "No active VS Code sessions"
    
    actions:
      - "Send idle notification to user"
      - "Auto-stop after 1 hour idle"
      - "Suggest smaller machine type"
  
  right_sizing_recommendations:
    monitor_period: "7 days"
    criteria:
      low_usage: "CPU < 25%, Memory < 50%"
      high_usage: "CPU > 80%, Memory > 85%"
    
    actions:
      - "Recommend machine type downgrade"
      - "Recommend machine type upgrade"
      - "Optimize storage allocation"
  
  schedule_based_optimization:
    working_hours: "09:00-18:00 IST"
    weekend_policy: "auto_stop_non_critical"
    holiday_policy: "stop_all_development"
```

### Cost Allocation and Chargeback

```yaml
chargeback_model:
  allocation_method: "usage_based"
  billing_frequency: "monthly"
  
  cost_categories:
    compute_hours:
      rate_calculation: "machine_type * hours_used"
      minimum_charge: "$10/month per user"
    
    storage_usage:
      rate_calculation: "$0.07/GB/month"
      free_tier: "15GB per user"
    
    data_transfer:
      rate_calculation: "$0.05/GB"
      internal_transfer: "free"
  
  department_billing:
    development: "direct_allocation"
    security: "overhead_allocation"
    compliance: "project_based"
    management: "usage_percentage"
```

## 📈 Cost Forecasting and Planning

### Predictive Analytics

```python
def forecast_monthly_costs(historical_data: List[Dict]) -> Dict:
    """Forecast monthly costs based on historical usage patterns."""
    
    # Trend analysis
    usage_trends = analyze_usage_trends(historical_data)
    
    # Seasonal adjustments for BFSI
    seasonal_factors = {
        'quarter_end': 1.3,  # Higher activity during quarter-end
        'year_end': 1.5,     # Peak activity during year-end
        'audit_season': 1.2, # Increased compliance activities
        'regular_period': 1.0
    }
    
    # Project growth factors
    project_factors = {
        'new_features': 1.2,
        'scalability_testing': 1.4,
        'security_audits': 1.1,
        'compliance_updates': 1.15
    }
    
    base_forecast = calculate_base_forecast(usage_trends)
    adjusted_forecast = apply_seasonal_adjustments(base_forecast, seasonal_factors)
    final_forecast = apply_project_factors(adjusted_forecast, project_factors)
    
    return {
        'base_forecast': base_forecast,
        'seasonal_adjusted': adjusted_forecast,
        'final_forecast': final_forecast,
        'confidence_interval': calculate_confidence_interval(historical_data),
        'budget_recommendations': generate_budget_recommendations(final_forecast)
    }
```

## 📋 Cost Governance Framework

### Approval Workflows

```yaml
approval_workflows:
  high_cost_machines:
    threshold: "8_core_16gb"
    approvers: ["team_lead", "tech_lead"]
    auto_approval_conditions:
      - "Security testing requirements"
      - "Performance testing needs"
      - "Production support activities"
  
  extended_usage:
    threshold: "200_hours_per_month"
    approvers: ["manager", "finance_partner"]
    justification_required: true
  
  premium_features:
    features: ["premium_storage", "gpu_instances"]
    approvers: ["director", "finance_director"]
    business_case_required: true
```

### Regular Reviews

```yaml
review_schedule:
  weekly_reviews:
    participants: ["team_leads", "scrum_masters"]
    focus: "Usage optimization, idle resource identification"
  
  monthly_reviews:
    participants: ["managers", "finance_partners"]
    focus: "Budget vs actual, trend analysis"
  
  quarterly_reviews:
    participants: ["directors", "finance_director", "cto"]
    focus: "Strategic planning, budget allocation"
  
  annual_reviews:
    participants: ["c_level", "board_members"]
    focus: "ROI analysis, strategic investment decisions"
```

## 📞 Cost Management Contacts

- **Finance Team**: finance-team@bfsi-org.com
- **Budget Manager**: budget-manager@bfsi-org.com
- **Cost Optimization**: cost-optimization@bfsi-org.com
- **Technical Lead**: tech-lead@bfsi-org.com

---

**Document Version**: 1.0.0  
**Cost Controller**: [Name]  
**Last Updated**: November 2024  
**Review Frequency**: Monthly  
**Approval**: BFSI Finance Committee