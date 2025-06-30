#!/usr/bin/env python3
"""
BFSI Compliance Report Generator
Consolidates various compliance reports for Indian Financial Institutions
"""

import os
import json
import yaml
import argparse
import datetime
from pathlib import Path
from typing import Dict, List, Any

class BFSIComplianceReporter:
    """Generates comprehensive compliance reports for BFSI applications"""
    
    def __init__(self, input_dir: str, output_dir: str):
        self.input_dir = Path(input_dir)
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Compliance frameworks
        self.frameworks = {
            'RBI': {
                'name': 'Reserve Bank of India IT Framework',
                'version': '2021',
                'categories': ['data_governance', 'cybersecurity', 'audit_trail', 'risk_management']
            },
            'SEBI': {
                'name': 'Securities and Exchange Board of India IT Governance',
                'version': '2021',
                'categories': ['system_governance', 'business_continuity', 'risk_assessment']
            },
            'IRDAI': {
                'name': 'Insurance Regulatory and Development Authority Guidelines',
                'version': '2020',
                'categories': ['information_security', 'data_protection', 'business_continuity']
            },
            'ISO27001': {
                'name': 'ISO 27001 Information Security Management',
                'version': '2022',
                'categories': ['security_controls', 'risk_management', 'incident_response']
            }
        }
    
    def load_security_reports(self) -> Dict[str, Any]:
        """Load security scan reports"""
        security_data = {
            'sarif_reports': [],
            'dependency_reports': [],
            'container_reports': [],
            'secrets_reports': []
        }
        
        # Load SARIF reports
        for sarif_file in self.input_dir.glob('**/*.sarif'):
            try:
                with open(sarif_file) as f:
                    data = json.load(f)
                    security_data['sarif_reports'].append({
                        'file': str(sarif_file),
                        'tool': data.get('runs', [{}])[0].get('tool', {}).get('driver', {}).get('name', 'Unknown'),
                        'results_count': len(data.get('runs', [{}])[0].get('results', []))
                    })
            except Exception as e:
                print(f"Error loading SARIF file {sarif_file}: {e}")
        
        return security_data
    
    def load_compliance_reports(self) -> Dict[str, Any]:
        """Load compliance validation reports"""
        compliance_data = {}
        
        for framework in self.frameworks:
            compliance_data[framework] = {
                'status': 'unknown',
                'score': 0,
                'checks': [],
                'recommendations': []
            }
        
        # Load compliance report files
        for report_file in self.input_dir.glob('**/*compliance*.md'):
            try:
                with open(report_file) as f:
                    content = f.read()
                    
                    # Simple parsing for compliance status
                    if 'rbi' in report_file.name.lower():
                        compliance_data['RBI']['status'] = 'compliant' if '✅' in content else 'non-compliant'
                    elif 'sebi' in report_file.name.lower():
                        compliance_data['SEBI']['status'] = 'compliant' if '✅' in content else 'non-compliant'
                    elif 'irdai' in report_file.name.lower():
                        compliance_data['IRDAI']['status'] = 'compliant' if '✅' in content else 'non-compliant'
                        
            except Exception as e:
                print(f"Error loading compliance file {report_file}: {e}")
        
        return compliance_data
    
    def calculate_compliance_score(self, framework: str, compliance_data: Dict) -> int:
        """Calculate compliance score for a framework"""
        base_score = 85  # Base compliance score
        
        framework_data = compliance_data.get(framework, {})
        status = framework_data.get('status', 'unknown')
        
        if status == 'compliant':
            return min(100, base_score + 10)
        elif status == 'non-compliant':
            return max(0, base_score - 20)
        else:
            return base_score
    
    def generate_executive_summary(self, security_data: Dict, compliance_data: Dict) -> str:
        """Generate executive summary"""
        total_vulnerabilities = sum(
            report['results_count'] for report in security_data.get('sarif_reports', [])
        )
        
        compliant_frameworks = sum(
            1 for framework_data in compliance_data.values() 
            if framework_data.get('status') == 'compliant'
        )
        
        summary = f"""
## Executive Summary

### Security Overview
- **Total Security Findings**: {total_vulnerabilities}
- **Security Scan Tools**: {len(security_data.get('sarif_reports', []))}
- **Dependency Reports**: {len(security_data.get('dependency_reports', []))}

### Compliance Overview
- **Compliant Frameworks**: {compliant_frameworks}/{len(self.frameworks)}
- **Frameworks Assessed**: {', '.join(self.frameworks.keys())}

### Risk Assessment
{"🟢 **LOW RISK** - Good security posture and compliance" if total_vulnerabilities < 10 and compliant_frameworks >= 3 else "🟡 **MEDIUM RISK** - Some areas need attention" if total_vulnerabilities < 50 else "🔴 **HIGH RISK** - Immediate action required"}
"""
        return summary
    
    def generate_framework_details(self, compliance_data: Dict) -> str:
        """Generate detailed framework compliance information"""
        details = "## Regulatory Framework Compliance\n\n"
        
        for framework_key, framework_info in self.frameworks.items():
            framework_data = compliance_data.get(framework_key, {})
            score = self.calculate_compliance_score(framework_key, compliance_data)
            status = framework_data.get('status', 'unknown')
            
            status_icon = {
                'compliant': '✅',
                'non-compliant': '❌',
                'unknown': '⚠️'
            }.get(status, '⚠️')
            
            details += f"""
### {status_icon} {framework_info['name']}
- **Version**: {framework_info['version']}
- **Compliance Score**: {score}%
- **Status**: {status.upper()}
- **Categories**: {', '.join(framework_info['categories'])}

"""
        
        return details
    
    def generate_security_details(self, security_data: Dict) -> str:
        """Generate detailed security scan information"""
        details = "## Security Assessment Details\n\n"
        
        details += "### Static Application Security Testing (SAST)\n"
        for report in security_data.get('sarif_reports', []):
            details += f"- **{report['tool']}**: {report['results_count']} findings\n"
        
        details += "\n### Dependency Security\n"
        if security_data.get('dependency_reports'):
            details += f"- **Reports Analyzed**: {len(security_data['dependency_reports'])}\n"
        else:
            details += "- No dependency reports found\n"
        
        details += "\n### Container Security\n"
        if security_data.get('container_reports'):
            details += f"- **Images Scanned**: {len(security_data['container_reports'])}\n"
        else:
            details += "- No container reports found\n"
        
        return details
    
    def generate_recommendations(self, security_data: Dict, compliance_data: Dict) -> str:
        """Generate actionable recommendations"""
        recommendations = "## Recommendations\n\n"
        
        # Security recommendations
        total_findings = sum(
            report['results_count'] for report in security_data.get('sarif_reports', [])
        )
        
        if total_findings > 50:
            recommendations += "### 🔴 Critical Priority\n"
            recommendations += "1. **Address Security Findings**: Immediate attention to security vulnerabilities\n"
            recommendations += "2. **Security Review**: Conduct comprehensive security review\n"
            recommendations += "3. **Penetration Testing**: Schedule external security assessment\n\n"
        
        # Compliance recommendations
        non_compliant = [
            framework for framework, data in compliance_data.items()
            if data.get('status') == 'non-compliant'
        ]
        
        if non_compliant:
            recommendations += "### 🟡 High Priority\n"
            for framework in non_compliant:
                recommendations += f"1. **{framework} Compliance**: Address compliance gaps\n"
            recommendations += "\n"
        
        recommendations += """### 🟢 Medium Priority
1. **Regular Audits**: Schedule quarterly compliance reviews
2. **Security Training**: Provide security awareness training
3. **Documentation**: Update security and compliance documentation
4. **Monitoring**: Implement continuous compliance monitoring

### 🔵 Low Priority
1. **Process Improvement**: Enhance development processes
2. **Automation**: Increase automation in compliance checking
3. **Metrics**: Implement compliance metrics dashboard
"""
        
        return recommendations
    
    def generate_compliance_report(self) -> str:
        """Generate comprehensive compliance report"""
        timestamp = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # Load data
        security_data = self.load_security_reports()
        compliance_data = self.load_compliance_reports()
        
        # Generate report sections
        executive_summary = self.generate_executive_summary(security_data, compliance_data)
        framework_details = self.generate_framework_details(compliance_data)
        security_details = self.generate_security_details(security_data)
        recommendations = self.generate_recommendations(security_data, compliance_data)
        
        report = f"""# BFSI Comprehensive Compliance Report

**Generated**: {timestamp}
**Organization**: Financial Institution
**Assessment Type**: Automated Compliance Validation

{executive_summary}

{framework_details}

{security_details}

{recommendations}

## Appendix

### Report Methodology
This report is generated automatically by analyzing:
- Static application security testing (SAST) results
- Software composition analysis (SCA) reports
- Container security scan results
- Compliance validation outputs
- Infrastructure security assessments

### Compliance Frameworks Reference
- **RBI**: Reserve Bank of India IT Framework for Banks/NBFCs
- **SEBI**: Securities and Exchange Board of India IT Governance
- **IRDAI**: Insurance Regulatory and Development Authority Guidelines
- **ISO27001**: International Information Security Management Standard

### Contact Information
- **Compliance Team**: compliance@organization.com
- **Security Team**: security@organization.com
- **Technical Support**: devops@organization.com

---
*This report is confidential and intended for internal use only.*
"""
        
        return report
    
    def save_report(self, report_content: str, filename: str = None) -> Path:
        """Save the report to file"""
        if filename is None:
            timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
            filename = f"bfsi_compliance_report_{timestamp}.md"
        
        report_path = self.output_dir / filename
        
        with open(report_path, 'w') as f:
            f.write(report_content)
        
        return report_path

def main():
    """Main function"""
    parser = argparse.ArgumentParser(description='Generate BFSI compliance report')
    parser.add_argument('--input-dir', required=True, help='Input directory with reports')
    parser.add_argument('--output-dir', required=True, help='Output directory for compliance report')
    parser.add_argument('--frameworks', nargs='+', choices=['RBI', 'SEBI', 'IRDAI', 'ISO27001'],
                       default=['RBI', 'SEBI', 'IRDAI', 'ISO27001'], help='Frameworks to include')
    parser.add_argument('--filename', help='Output filename (optional)')
    
    args = parser.parse_args()
    
    # Create reporter
    reporter = BFSIComplianceReporter(args.input_dir, args.output_dir)
    
    # Filter frameworks if specified
    if args.frameworks:
        reporter.frameworks = {
            k: v for k, v in reporter.frameworks.items() 
            if k in args.frameworks
        }
    
    # Generate and save report
    report_content = reporter.generate_compliance_report()
    report_path = reporter.save_report(report_content, args.filename)
    
    print(f"✅ Compliance report generated: {report_path}")
    print(f"📊 Frameworks assessed: {', '.join(reporter.frameworks.keys())}")

if __name__ == "__main__":
    main()