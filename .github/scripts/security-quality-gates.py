#!/usr/bin/env python3
"""
Security Quality Gates for BFSI Applications
Enforces security standards and fails builds for non-compliant applications
"""

import json
import sys
import argparse
from pathlib import Path

class SecurityQualityGates:
    def __init__(self):
        self.quality_gates = {
            'critical': {
                'max_allowed': 0,
                'fail_build': True,
                'message': 'Critical security vulnerabilities must be resolved before deployment'
            },
            'high': {
                'max_allowed': 0,
                'fail_build': True,
                'message': 'High severity security issues must be addressed'
            },
            'medium': {
                'max_allowed': 5,
                'fail_build': False,
                'message': 'Medium severity issues should be reviewed and scheduled for remediation'
            },
            'low': {
                'max_allowed': 20,
                'fail_build': False,
                'message': 'Low severity issues should be tracked for future remediation'
            }
        }
        
        self.compliance_gates = {
            'rbi': {
                'min_score': 90,
                'fail_build': True,
                'message': 'RBI IT Framework compliance score below minimum threshold'
            },
            'sebi': {
                'min_score': 85,
                'fail_build': True,
                'message': 'SEBI Guidelines compliance score below minimum threshold'
            },
            'iso27001': {
                'min_score': 80,
                'fail_build': False,
                'message': 'ISO 27001 compliance score below target'
            }
        }

    def evaluate_sarif_results(self, sarif_dir):
        """Evaluate SARIF results against quality gates"""
        findings = {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
        violations = []
        
        # Process all SARIF files
        for sarif_file in Path(sarif_dir).glob('**/*.sarif'):
            try:
                with open(sarif_file, 'r') as f:
                    sarif_data = json.load(f)
                
                # Count findings by severity
                for run in sarif_data.get('runs', []):
                    for result in run.get('results', []):
                        level = result.get('level', 'note')
                        if level == 'error':
                            findings['critical'] += 1
                        elif level == 'warning':
                            findings['high'] += 1
                        elif level == 'note':
                            findings['medium'] += 1
                        else:
                            findings['low'] += 1
                            
            except Exception as e:
                print(f"Error processing SARIF file {sarif_file}: {e}")
        
        # Evaluate against quality gates
        for severity, count in findings.items():
            gate = self.quality_gates.get(severity, {})
            max_allowed = gate.get('max_allowed', float('inf'))
            
            if count > max_allowed:
                violations.append({
                    'type': 'security_finding',
                    'severity': severity,
                    'count': count,
                    'max_allowed': max_allowed,
                    'fail_build': gate.get('fail_build', False),
                    'message': gate.get('message', f'{severity} findings exceed threshold')
                })
        
        return findings, violations

    def evaluate_compliance_scores(self, compliance_file):
        """Evaluate compliance scores against quality gates"""
        violations = []
        
        try:
            with open(compliance_file, 'r') as f:
                compliance_data = json.load(f)
            
            frameworks = compliance_data.get('frameworks', {})
            
            for framework, score_data in frameworks.items():
                score = score_data.get('score', 0)
                gate = self.compliance_gates.get(framework, {})
                min_score = gate.get('min_score', 0)
                
                if score < min_score:
                    violations.append({
                        'type': 'compliance_score',
                        'framework': framework,
                        'score': score,
                        'min_score': min_score,
                        'fail_build': gate.get('fail_build', False),
                        'message': gate.get('message', f'{framework} compliance score below threshold')
                    })
                    
        except Exception as e:
            print(f"Error processing compliance file: {e}")
        
        return violations

    def check_financial_specific_rules(self, sarif_dir):
        """Check BFSI-specific security rules"""
        violations = []
        
        # Critical rules for financial applications
        critical_rules = [
            'payment-data-exposure',
            'weak-transaction-encryption', 
            'pii-exposure',
            'rbi-data-localization'
        ]
        
        found_critical_violations = []
        
        for sarif_file in Path(sarif_dir).glob('**/*.sarif'):
            try:
                with open(sarif_file, 'r') as f:
                    sarif_data = json.load(f)
                
                for run in sarif_data.get('runs', []):
                    for result in run.get('results', []):
                        rule_id = result.get('ruleId', '')
                        
                        # Check for critical financial rules
                        for critical_rule in critical_rules:
                            if critical_rule in rule_id.lower():
                                found_critical_violations.append({
                                    'rule': critical_rule,
                                    'rule_id': rule_id,
                                    'message': result.get('message', {}).get('text', ''),
                                    'level': result.get('level', 'note')
                                })
                                
            except Exception as e:
                print(f"Error processing SARIF file {sarif_file}: {e}")
        
        # Any critical financial rule violation fails the build
        if found_critical_violations:
            violations.append({
                'type': 'financial_security_violation',
                'violations': found_critical_violations,
                'fail_build': True,
                'message': 'Critical financial security violations found'
            })
        
        return violations

    def generate_quality_gate_report(self, findings, all_violations):
        """Generate quality gate evaluation report"""
        report = {
            'quality_gate_status': 'PASS',
            'timestamp': '2024-06-30T12:00:00Z',
            'findings_summary': findings,
            'violations': all_violations,
            'build_decision': 'PASS'
        }
        
        # Determine overall status
        fail_build_violations = [v for v in all_violations if v.get('fail_build', False)]
        
        if fail_build_violations:
            report['quality_gate_status'] = 'FAIL'
            report['build_decision'] = 'FAIL'
        elif all_violations:
            report['quality_gate_status'] = 'WARNING'
            report['build_decision'] = 'PASS'
        
        return report

def main():
    parser = argparse.ArgumentParser(description='Evaluate security quality gates for BFSI applications')
    parser.add_argument('--sarif-dir', required=True, help='Directory containing SARIF files')
    parser.add_argument('--compliance-file', help='Compliance assessment JSON file')
    parser.add_argument('--fail-on-critical', type=bool, default=True, help='Fail build on critical issues')
    parser.add_argument('--fail-on-high', type=bool, default=True, help='Fail build on high severity issues')
    parser.add_argument('--max-medium', type=int, default=5, help='Maximum allowed medium severity issues')
    parser.add_argument('--compliance-standards', help='Comma-separated list of compliance standards to check')
    parser.add_argument('--output', default='quality-gate-report.json', help='Output report file')
    
    args = parser.parse_args()
    
    quality_gates = SecurityQualityGates()
    
    # Override default settings based on arguments
    if not args.fail_on_critical:
        quality_gates.quality_gates['critical']['fail_build'] = False
    if not args.fail_on_high:
        quality_gates.quality_gates['high']['fail_build'] = False
    
    quality_gates.quality_gates['medium']['max_allowed'] = args.max_medium
    
    # Evaluate SARIF results
    findings, security_violations = quality_gates.evaluate_sarif_results(args.sarif_dir)
    
    # Evaluate compliance scores
    compliance_violations = []
    if args.compliance_file and Path(args.compliance_file).exists():
        compliance_violations = quality_gates.evaluate_compliance_scores(args.compliance_file)
    
    # Check financial-specific rules
    financial_violations = quality_gates.check_financial_specific_rules(args.sarif_dir)
    
    # Combine all violations
    all_violations = security_violations + compliance_violations + financial_violations
    
    # Generate report
    report = quality_gates.generate_quality_gate_report(findings, all_violations)
    
    # Write report
    with open(args.output, 'w') as f:
        json.dump(report, f, indent=2)
    
    # Print summary
    print(f"Quality Gate Evaluation Summary:")
    print(f"Status: {report['quality_gate_status']}")
    print(f"Build Decision: {report['build_decision']}")
    print(f"Total Findings: {sum(findings.values())}")
    print(f"Total Violations: {len(all_violations)}")
    
    if all_violations:
        print("\nViolations:")
        for i, violation in enumerate(all_violations, 1):
            print(f"{i}. {violation['message']}")
            if violation.get('fail_build'):
                print("   ❌ FAILS BUILD")
            else:
                print("   ⚠️  WARNING")
    
    # Exit with appropriate code
    fail_build_violations = [v for v in all_violations if v.get('fail_build', False)]
    if fail_build_violations:
        print(f"\n❌ BUILD FAILED: {len(fail_build_violations)} quality gate violations")
        sys.exit(1)
    elif all_violations:
        print(f"\n⚠️  BUILD PASSED WITH WARNINGS: {len(all_violations)} issues to address")
        sys.exit(0)
    else:
        print("\n✅ BUILD PASSED: All quality gates satisfied")
        sys.exit(0)

if __name__ == '__main__':
    main()