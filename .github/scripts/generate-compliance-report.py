#!/usr/bin/env python3
"""
Compliance Report Generation Tool for BFSI Applications

This script generates compliance reports from SARIF files, mapping security 
findings to regulatory frameworks like RBI IT Framework, SEBI Guidelines, 
and ISO 27001 standards.

Author: Security Architecture Team
Version: 1.0.0
"""

import json
import argparse
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional
import glob


class ComplianceReportGenerator:
    """Generate compliance reports from SARIF security findings."""
    
    def __init__(self, standards: List[str]):
        self.standards = standards
        self.report = {
            "metadata": {
                "generated_at": datetime.utcnow().isoformat(),
                "version": "1.0.0",
                "standards": standards
            },
            "executive_summary": {
                "total_findings": 0,
                "critical_findings": 0,
                "compliance_score": 0.0,
                "risk_level": "LOW"
            },
            "compliance_mappings": {},
            "detailed_findings": [],
            "remediation_summary": {},
            "audit_trail": []
        }
        
        # Initialize compliance frameworks
        for standard in standards:
            self.report["compliance_mappings"][standard] = {
                "total_controls": 0,
                "failed_controls": 0,
                "compliance_percentage": 100.0,
                "findings_by_control": {}
            }
            
    def generate_report(self, sarif_dir: str, output_dir: str) -> None:
        """Generate compliance report from SARIF files."""
        sarif_files = glob.glob(os.path.join(sarif_dir, "**/*.sarif"), recursive=True)
        
        if not sarif_files:
            print(f"Warning: No SARIF files found in {sarif_dir}")
            # Create empty report
            self._finalize_report()
            self._write_report(output_dir)
            return
            
        print(f"Processing {len(sarif_files)} SARIF file(s) for compliance mapping")
        
        for sarif_file in sarif_files:
            try:
                self._process_sarif_file(sarif_file)
            except Exception as e:
                print(f"Error processing {sarif_file}: {e}")
                continue
                
        self._finalize_report()
        self._write_report(output_dir)
        
    def _process_sarif_file(self, sarif_file: str) -> None:
        """Process a single SARIF file for compliance mapping."""
        print(f"Processing: {sarif_file}")
        
        with open(sarif_file, 'r', encoding='utf-8') as f:
            sarif_data = json.load(f)
            
        for run in sarif_data.get('runs', []):
            self._process_run(run, sarif_file)
            
    def _process_run(self, run: Dict[str, Any], source_file: str) -> None:
        """Process a single run from SARIF data."""
        results = run.get('results', [])
        self.report["executive_summary"]["total_findings"] += len(results)
        
        for result in results:
            self._map_finding_to_compliance(result, source_file)
            
    def _map_finding_to_compliance(self, result: Dict[str, Any], source_file: str) -> None:
        """Map a security finding to compliance frameworks."""
        rule_id = result.get('ruleId', 'unknown')
        level = result.get('level', 'note').lower()
        message = result.get('message', {}).get('text', '')
        
        # Track critical findings
        if level in ['error', 'critical']:
            self.report["executive_summary"]["critical_findings"] += 1
            
        # Create detailed finding record
        finding = {
            "rule_id": rule_id,
            "severity": level,
            "message": message,
            "source_file": source_file,
            "compliance_mappings": [],
            "remediation_priority": self._calculate_priority(level, rule_id)
        }
        
        # Map to specific compliance frameworks
        if "ISO27001" in self.standards:
            iso_mappings = self._map_to_iso27001(rule_id, level)
            if iso_mappings:
                finding["compliance_mappings"].extend(iso_mappings)
                self._update_compliance_stats("ISO27001", iso_mappings, level)
                
        if "RBI-IT-Framework" in self.standards:
            rbi_mappings = self._map_to_rbi_framework(rule_id, level)
            if rbi_mappings:
                finding["compliance_mappings"].extend(rbi_mappings)
                self._update_compliance_stats("RBI-IT-Framework", rbi_mappings, level)
                
        if "SEBI-Guidelines" in self.standards:
            sebi_mappings = self._map_to_sebi_guidelines(rule_id, level)
            if sebi_mappings:
                finding["compliance_mappings"].extend(sebi_mappings)
                self._update_compliance_stats("SEBI-Guidelines", sebi_mappings, level)
                
        self.report["detailed_findings"].append(finding)
        
    def _map_to_iso27001(self, rule_id: str, level: str) -> List[Dict[str, str]]:
        """Map finding to ISO 27001 controls."""
        mappings = []
        rule_lower = rule_id.lower()
        
        # A.12.6.1 - Management of technical vulnerabilities
        if any(term in rule_lower for term in ['sql-injection', 'xss', 'vulnerability']):
            mappings.append({
                "framework": "ISO27001",
                "control": "A.12.6.1",
                "description": "Management of technical vulnerabilities",
                "severity_impact": level
            })
            
        # A.10.1.1 - Policy on the use of cryptographic controls
        if any(term in rule_lower for term in ['crypto', 'encryption', 'cipher', 'hash']):
            mappings.append({
                "framework": "ISO27001",
                "control": "A.10.1.1",
                "description": "Policy on the use of cryptographic controls",
                "severity_impact": level
            })
            
        # A.9.1.1 - Access control policy
        if any(term in rule_lower for term in ['auth', 'access', 'authorization']):
            mappings.append({
                "framework": "ISO27001",
                "control": "A.9.1.1",
                "description": "Access control policy",
                "severity_impact": level
            })
            
        return mappings
        
    def _map_to_rbi_framework(self, rule_id: str, level: str) -> List[Dict[str, str]]:
        """Map finding to RBI IT Framework controls."""
        mappings = []
        rule_lower = rule_id.lower()
        
        # RBI-IT-4.2.1 - Application Security
        if any(term in rule_lower for term in ['sql-injection', 'xss', 'injection']):
            mappings.append({
                "framework": "RBI-IT-Framework",
                "control": "RBI-IT-4.2.1",
                "description": "Application Security - Secure coding practices",
                "severity_impact": level
            })
            
        # RBI-IT-4.1.3 - Access Control
        if any(term in rule_lower for term in ['auth', 'session', 'access']):
            mappings.append({
                "framework": "RBI-IT-Framework",
                "control": "RBI-IT-4.1.3",
                "description": "Access Control and Authentication",
                "severity_impact": level
            })
            
        # RBI-IT-4.3.3 - Data Protection
        if any(term in rule_lower for term in ['pii', 'personal', 'data-protection']):
            mappings.append({
                "framework": "RBI-IT-Framework",
                "control": "RBI-IT-4.3.3",
                "description": "Customer Data Protection",
                "severity_impact": level
            })
            
        return mappings
        
    def _map_to_sebi_guidelines(self, rule_id: str, level: str) -> List[Dict[str, str]]:
        """Map finding to SEBI Guidelines."""
        mappings = []
        rule_lower = rule_id.lower()
        
        # SEBI-SG-2.1 - System Governance
        if any(term in rule_lower for term in ['governance', 'policy', 'procedure']):
            mappings.append({
                "framework": "SEBI-Guidelines",
                "control": "SEBI-SG-2.1",
                "description": "System Governance and Risk Management",
                "severity_impact": level
            })
            
        # SEBI-DI-3.1 - Data Integrity
        if any(term in rule_lower for term in ['data-integrity', 'validation', 'consistency']):
            mappings.append({
                "framework": "SEBI-Guidelines",
                "control": "SEBI-DI-3.1",
                "description": "Data Integrity and Validation",
                "severity_impact": level
            })
            
        return mappings
        
    def _update_compliance_stats(self, framework: str, mappings: List[Dict], level: str) -> None:
        """Update compliance statistics."""
        if framework not in self.report["compliance_mappings"]:
            return
            
        for mapping in mappings:
            control = mapping["control"]
            if control not in self.report["compliance_mappings"][framework]["findings_by_control"]:
                self.report["compliance_mappings"][framework]["findings_by_control"][control] = {
                    "total_findings": 0,
                    "critical_findings": 0,
                    "description": mapping["description"]
                }
                
            self.report["compliance_mappings"][framework]["findings_by_control"][control]["total_findings"] += 1
            
            if level in ['error', 'critical']:
                self.report["compliance_mappings"][framework]["findings_by_control"][control]["critical_findings"] += 1
                
    def _calculate_priority(self, level: str, rule_id: str) -> str:
        """Calculate remediation priority."""
        if level in ['error', 'critical']:
            return "HIGH"
        elif level == 'warning':
            return "MEDIUM"
        else:
            return "LOW"
            
    def _finalize_report(self) -> None:
        """Finalize the compliance report with summary calculations."""
        # Calculate compliance scores
        for framework, data in self.report["compliance_mappings"].items():
            failed_controls = len([
                control for control, details in data["findings_by_control"].items()
                if details["critical_findings"] > 0
            ])
            total_controls = max(1, len(data["findings_by_control"]))
            
            data["failed_controls"] = failed_controls
            data["total_controls"] = total_controls
            data["compliance_percentage"] = max(0, 100 - (failed_controls / total_controls * 100))
            
        # Calculate overall compliance score
        if self.report["compliance_mappings"]:
            avg_compliance = sum(
                data["compliance_percentage"] 
                for data in self.report["compliance_mappings"].values()
            ) / len(self.report["compliance_mappings"])
            self.report["executive_summary"]["compliance_score"] = avg_compliance
        else:
            self.report["executive_summary"]["compliance_score"] = 100.0
            
        # Determine risk level
        critical_findings = self.report["executive_summary"]["critical_findings"]
        if critical_findings > 5:
            self.report["executive_summary"]["risk_level"] = "HIGH"
        elif critical_findings > 0:
            self.report["executive_summary"]["risk_level"] = "MEDIUM"
        else:
            self.report["executive_summary"]["risk_level"] = "LOW"
            
    def _write_report(self, output_dir: str) -> None:
        """Write compliance report to output directory."""
        os.makedirs(output_dir, exist_ok=True)
        
        # Write main report
        report_file = os.path.join(output_dir, "compliance-report.json")
        with open(report_file, 'w', encoding='utf-8') as f:
            json.dump(self.report, f, indent=2)
            
        # Write summary report
        summary_file = os.path.join(output_dir, "compliance-summary.json")
        summary = {
            "metadata": self.report["metadata"],
            "executive_summary": self.report["executive_summary"],
            "compliance_scores": {
                framework: {
                    "compliance_percentage": data["compliance_percentage"],
                    "failed_controls": data["failed_controls"],
                    "total_controls": data["total_controls"]
                }
                for framework, data in self.report["compliance_mappings"].items()
            }
        }
        
        with open(summary_file, 'w', encoding='utf-8') as f:
            json.dump(summary, f, indent=2)
            
        print(f"Compliance report generated: {report_file}")
        print(f"Compliance summary generated: {summary_file}")


def main():
    """Main execution function."""
    parser = argparse.ArgumentParser(
        description="Generate compliance reports from SARIF files for BFSI applications"
    )
    parser.add_argument(
        "--sarif-dir",
        required=True,
        help="Directory containing SARIF files"
    )
    parser.add_argument(
        "--output-dir",
        required=True,
        help="Output directory for compliance reports"
    )
    parser.add_argument(
        "--standards",
        required=True,
        help="Comma-separated list of compliance standards (e.g., ISO27001,RBI-IT-Framework,SEBI-Guidelines)"
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Enable verbose output"
    )
    
    args = parser.parse_args()
    
    # Validate input directory
    if not os.path.exists(args.sarif_dir):
        print(f"Error: SARIF directory {args.sarif_dir} does not exist")
        return 1
        
    # Parse standards
    standards = [s.strip() for s in args.standards.split(',')]
    
    # Generate compliance report
    generator = ComplianceReportGenerator(standards)
    generator.generate_report(args.sarif_dir, args.output_dir)
    
    if args.verbose:
        print(f"Compliance report generation completed")
        print(f"Standards analyzed: {', '.join(standards)}")
        print(f"Output directory: {args.output_dir}")
        
    return 0


if __name__ == "__main__":
    sys.exit(main())