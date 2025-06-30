#!/usr/bin/env python3
"""
SARIF Processing Script for BFSI Compliance
Processes CodeQL SARIF results for financial services compliance reporting
"""

import json
import sys
import argparse
from datetime import datetime
from pathlib import Path

class SARIFProcessor:
    def __init__(self):
        self.rbi_mappings = {
            "sql-injection": "RBI-IT-4.2.1",
            "weak-cryptographic-algorithm": "RBI-IT-4.3.2", 
            "hardcoded-credentials": "RBI-IT-4.1.3",
            "sensitive-data-exposure": "RBI-IT-4.3.1",
            "payment-data-exposure": "RBI-IT-4.3.3"
        }
        
        self.iso27001_mappings = {
            "sql-injection": "A.14.2.5",
            "weak-cryptographic-algorithm": "A.10.1.1",
            "hardcoded-credentials": "A.9.4.3",
            "access-control": "A.9.1.1",
            "authentication": "A.9.2.1"
        }
        
        self.sebi_mappings = {
            "system-governance": "SEBI-IT-1.1",
            "risk-management": "SEBI-IT-2.1", 
            "data-integrity": "SEBI-IT-3.1",
            "audit-trail": "SEBI-IT-4.1"
        }

    def process_sarif_file(self, sarif_path):
        """Process a single SARIF file and extract compliance data"""
        try:
            with open(sarif_path, 'r') as f:
                sarif_data = json.load(f)
            
            results = []
            for run in sarif_data.get('runs', []):
                for result in run.get('results', []):
                    processed_result = self.process_result(result, run)
                    if processed_result:
                        results.append(processed_result)
            
            return results
            
        except Exception as e:
            print(f"Error processing SARIF file {sarif_path}: {e}")
            return []

    def process_result(self, result, run):
        """Process individual SARIF result"""
        rule_id = result.get('ruleId', '')
        message = result.get('message', {}).get('text', '')
        level = result.get('level', 'note')
        
        # Map to compliance frameworks
        compliance_mappings = {
            'rbi': self.get_rbi_mapping(rule_id),
            'iso27001': self.get_iso27001_mapping(rule_id),
            'sebi': self.get_sebi_mapping(rule_id)
        }
        
        # Extract location information
        locations = []
        for location in result.get('locations', []):
            physical_location = location.get('physicalLocation', {})
            artifact_location = physical_location.get('artifactLocation', {})
            region = physical_location.get('region', {})
            
            locations.append({
                'file': artifact_location.get('uri', ''),
                'start_line': region.get('startLine', 0),
                'start_column': region.get('startColumn', 0),
                'end_line': region.get('endLine', 0),
                'end_column': region.get('endColumn', 0)
            })
        
        return {
            'rule_id': rule_id,
            'message': message,
            'level': level,
            'compliance_mappings': compliance_mappings,
            'locations': locations,
            'fingerprint': result.get('fingerprints', {}),
            'timestamp': datetime.now().isoformat()
        }

    def get_rbi_mapping(self, rule_id):
        """Map CodeQL rule to RBI IT Framework controls"""
        for pattern, mapping in self.rbi_mappings.items():
            if pattern in rule_id.lower():
                return {
                    'control': mapping,
                    'description': f'RBI IT Framework control {mapping}',
                    'category': 'Information Security'
                }
        return None

    def get_iso27001_mapping(self, rule_id):
        """Map CodeQL rule to ISO 27001 controls"""
        for pattern, mapping in self.iso27001_mappings.items():
            if pattern in rule_id.lower():
                return {
                    'control': mapping,
                    'description': f'ISO 27001 control {mapping}',
                    'category': 'Information Security Management'
                }
        return None

    def get_sebi_mapping(self, rule_id):
        """Map CodeQL rule to SEBI IT Governance controls"""
        for pattern, mapping in self.sebi_mappings.items():
            if pattern in rule_id.lower():
                return {
                    'control': mapping,
                    'description': f'SEBI IT Governance {mapping}',
                    'category': 'System Governance'
                }
        return None

    def generate_compliance_summary(self, results):
        """Generate compliance summary from processed results"""
        summary = {
            'total_findings': len(results),
            'by_severity': {'critical': 0, 'high': 0, 'medium': 0, 'low': 0},
            'by_framework': {'rbi': 0, 'iso27001': 0, 'sebi': 0},
            'compliance_status': 'PASS',
            'generated_at': datetime.now().isoformat()
        }
        
        critical_count = 0
        high_count = 0
        
        for result in results:
            # Count by severity
            level = result['level']
            if level == 'error':
                summary['by_severity']['critical'] += 1
                critical_count += 1
            elif level == 'warning':
                summary['by_severity']['high'] += 1
                high_count += 1
            elif level == 'note':
                summary['by_severity']['medium'] += 1
            else:
                summary['by_severity']['low'] += 1
            
            # Count by framework
            mappings = result['compliance_mappings']
            if mappings.get('rbi'):
                summary['by_framework']['rbi'] += 1
            if mappings.get('iso27001'):
                summary['by_framework']['iso27001'] += 1
            if mappings.get('sebi'):
                summary['by_framework']['sebi'] += 1
        
        # Determine compliance status
        if critical_count > 0:
            summary['compliance_status'] = 'CRITICAL'
        elif high_count > 5:  # More than 5 high severity issues
            summary['compliance_status'] = 'HIGH_RISK'
        elif high_count > 0:
            summary['compliance_status'] = 'MEDIUM_RISK'
        
        return summary

def main():
    parser = argparse.ArgumentParser(description='Process SARIF files for BFSI compliance')
    parser.add_argument('sarif_file', help='Path to SARIF file')
    parser.add_argument('--output', '-o', help='Output file path', default='compliance-report.json')
    
    args = parser.parse_args()
    
    processor = SARIFProcessor()
    results = processor.process_sarif_file(args.sarif_file)
    summary = processor.generate_compliance_summary(results)
    
    # Generate compliance report
    report = {
        'metadata': {
            'sarif_file': args.sarif_file,
            'processed_at': datetime.now().isoformat(),
            'processor_version': '1.0.0'
        },
        'summary': summary,
        'detailed_results': results
    }
    
    # Write output
    with open(args.output, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"Compliance report generated: {args.output}")
    print(f"Total findings: {summary['total_findings']}")
    print(f"Compliance status: {summary['compliance_status']}")
    
    # Exit with error code if critical issues found
    if summary['compliance_status'] == 'CRITICAL':
        sys.exit(1)

if __name__ == '__main__':
    main()