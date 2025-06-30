#!/usr/bin/env python3
"""
Security Dashboard Generator for BFSI Applications
Creates interactive dashboards from security scan results
"""

import json
import sys
import argparse
from datetime import datetime, timedelta
from pathlib import Path
import html

class SecurityDashboardGenerator:
    def __init__(self):
        self.dashboard_template = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>BFSI Security Dashboard</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background-color: #f5f5f5; 
        }
        .header { 
            background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
            color: white; 
            padding: 20px; 
            border-radius: 8px; 
            margin-bottom: 20px;
        }
        .dashboard-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); 
            gap: 20px; 
        }
        .card { 
            background: white; 
            border-radius: 8px; 
            padding: 20px; 
            box-shadow: 0 2px 4px rgba(0,0,0,0.1); 
        }
        .metric { 
            text-align: center; 
            padding: 15px; 
            border-radius: 8px; 
            margin: 10px 0; 
        }
        .critical { background-color: #ffe6e6; color: #d63384; }
        .high { background-color: #fff3cd; color: #fd7e14; }
        .medium { background-color: #cff4fc; color: #0dcaf0; }
        .low { background-color: #d1e7dd; color: #198754; }
        .compliance-status { 
            padding: 10px; 
            border-radius: 5px; 
            margin: 5px 0; 
            font-weight: bold; 
        }
        .compliant { background-color: #d1e7dd; color: #198754; }
        .non-compliant { background-color: #f8d7da; color: #d63384; }
        .partial { background-color: #fff3cd; color: #fd7e14; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th, td { padding: 8px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }
        .chart-container { height: 300px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🏛️ BFSI Security Dashboard</h1>
        <p>Financial Services Security Monitoring and Compliance Reporting</p>
        <p><strong>Generated:</strong> {timestamp}</p>
    </div>

    <div class="dashboard-grid">
        <!-- Security Overview -->
        <div class="card">
            <h2>🔒 Security Overview</h2>
            {security_overview}
        </div>

        <!-- Compliance Status -->
        <div class="card">
            <h2>📋 Compliance Status</h2>
            {compliance_status}
        </div>

        <!-- Vulnerability Trends -->
        <div class="card">
            <h2>📈 Vulnerability Trends</h2>
            <div class="chart-container">
                <canvas id="trendsChart"></canvas>
            </div>
        </div>

        <!-- Top Security Issues -->
        <div class="card">
            <h2>⚠️ Top Security Issues</h2>
            {top_issues}
        </div>

        <!-- Dependency Security -->
        <div class="card">
            <h2>📦 Dependency Security</h2>
            {dependency_security}
        </div>

        <!-- Remediation Timeline -->
        <div class="card">
            <h2>🔧 Remediation Timeline</h2>
            {remediation_timeline}
        </div>
    </div>

    <script>
        // Vulnerability trends chart
        const trendsCtx = document.getElementById('trendsChart').getContext('2d');
        new Chart(trendsCtx, {{
            type: 'line',
            data: {trends_data},
            options: {{
                responsive: true,
                maintainAspectRatio: false,
                scales: {{
                    y: {{
                        beginAtZero: true,
                        title: {{
                            display: true,
                            text: 'Number of Vulnerabilities'
                        }}
                    }},
                    x: {{
                        title: {{
                            display: true,
                            text: 'Date'
                        }}
                    }}
                }}
            }}
        }});
    </script>
</body>
</html>
        """

    def generate_dashboard(self, metrics_file, output_file):
        """Generate HTML dashboard from security metrics"""
        try:
            with open(metrics_file, 'r') as f:
                metrics = json.load(f)
            
            # Generate dashboard sections
            security_overview = self.generate_security_overview(metrics)
            compliance_status = self.generate_compliance_status(metrics)
            top_issues = self.generate_top_issues(metrics)
            dependency_security = self.generate_dependency_security(metrics)
            remediation_timeline = self.generate_remediation_timeline(metrics)
            trends_data = self.generate_trends_data(metrics)
            
            # Generate HTML
            html_content = self.dashboard_template.format(
                timestamp=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                security_overview=security_overview,
                compliance_status=compliance_status,
                top_issues=top_issues,
                dependency_security=dependency_security,
                remediation_timeline=remediation_timeline,
                trends_data=json.dumps(trends_data)
            )
            
            # Write dashboard
            with open(output_file, 'w') as f:
                f.write(html_content)
            
            print(f"Security dashboard generated: {output_file}")
            
        except Exception as e:
            print(f"Error generating dashboard: {e}")
            sys.exit(1)

    def generate_security_overview(self, metrics):
        """Generate security overview section"""
        overview = metrics.get('summary', {})
        
        html = f"""
        <div class="metric critical">
            <h3>Critical Issues</h3>
            <div style="font-size: 24px; font-weight: bold;">
                {overview.get('critical', 0)}
            </div>
        </div>
        <div class="metric high">
            <h3>High Priority</h3>
            <div style="font-size: 24px; font-weight: bold;">
                {overview.get('high', 0)}
            </div>
        </div>
        <div class="metric medium">
            <h3>Medium Priority</h3>
            <div style="font-size: 24px; font-weight: bold;">
                {overview.get('medium', 0)}
            </div>
        </div>
        <div class="metric low">
            <h3>Low Priority</h3>
            <div style="font-size: 24px; font-weight: bold;">
                {overview.get('low', 0)}
            </div>
        </div>
        
        <div style="margin-top: 20px;">
            <strong>Security Score:</strong> {self.calculate_security_score(overview)}/100
        </div>
        """
        
        return html

    def generate_compliance_status(self, metrics):
        """Generate compliance status section"""
        compliance = metrics.get('compliance', {})
        
        frameworks = [
            ('RBI IT Framework', compliance.get('rbi', {})),
            ('SEBI Guidelines', compliance.get('sebi', {})),
            ('ISO 27001', compliance.get('iso27001', {})),
            ('IRDAI Guidelines', compliance.get('irdai', {}))
        ]
        
        html = ""
        for name, status_info in frameworks:
            status = status_info.get('status', 'unknown')
            score = status_info.get('score', 0)
            issues = status_info.get('issues', 0)
            
            css_class = 'compliant' if status == 'compliant' else \
                       'partial' if status == 'partial' else 'non-compliant'
            
            html += f"""
            <div class="compliance-status {css_class}">
                <strong>{name}</strong><br>
                Status: {status.upper()}<br>
                Score: {score}% | Issues: {issues}
            </div>
            """
        
        return html

    def generate_top_issues(self, metrics):
        """Generate top security issues section"""
        issues = metrics.get('top_issues', [])
        
        if not issues:
            return "<p>No critical security issues found.</p>"
        
        html = "<table><tr><th>Issue</th><th>Severity</th><th>Component</th><th>Status</th></tr>"
        
        for issue in issues[:10]:  # Top 10 issues
            severity_class = issue.get('severity', 'low').lower()
            html += f"""
            <tr>
                <td>{html.escape(issue.get('title', 'Unknown'))}</td>
                <td><span class="metric {severity_class}" style="padding: 3px 8px; font-size: 12px;">
                    {issue.get('severity', 'Unknown').upper()}
                </span></td>
                <td>{html.escape(issue.get('component', 'Unknown'))}</td>
                <td>{issue.get('status', 'Open')}</td>
            </tr>
            """
        
        html += "</table>"
        return html

    def generate_dependency_security(self, metrics):
        """Generate dependency security section"""
        deps = metrics.get('dependencies', {})
        
        html = f"""
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
            <div class="metric">
                <strong>Total Dependencies</strong><br>
                {deps.get('total', 0)}
            </div>
            <div class="metric">
                <strong>Vulnerable</strong><br>
                {deps.get('vulnerable', 0)}
            </div>
            <div class="metric">
                <strong>Outdated</strong><br>
                {deps.get('outdated', 0)}
            </div>
            <div class="metric">
                <strong>Security Score</strong><br>
                {deps.get('security_score', 0)}%
            </div>
        </div>
        
        <h4>High-Risk Dependencies</h4>
        """
        
        risky_deps = deps.get('high_risk', [])
        if risky_deps:
            html += "<table><tr><th>Dependency</th><th>Current</th><th>Latest</th><th>Risk</th></tr>"
            for dep in risky_deps[:5]:
                html += f"""
                <tr>
                    <td>{html.escape(dep.get('name', 'Unknown'))}</td>
                    <td>{dep.get('current_version', 'Unknown')}</td>
                    <td>{dep.get('latest_version', 'Unknown')}</td>
                    <td><span class="metric {dep.get('risk_level', 'low').lower()}" style="padding: 2px 6px; font-size: 11px;">
                        {dep.get('risk_level', 'Unknown').upper()}
                    </span></td>
                </tr>
                """
            html += "</table>"
        else:
            html += "<p>No high-risk dependencies identified.</p>"
        
        return html

    def generate_remediation_timeline(self, metrics):
        """Generate remediation timeline section"""
        timeline = metrics.get('remediation_timeline', [])
        
        if not timeline:
            return "<p>No pending remediations.</p>"
        
        html = "<table><tr><th>Issue</th><th>Priority</th><th>Due Date</th><th>Assignee</th></tr>"
        
        for item in timeline:
            priority_class = item.get('priority', 'P3').lower()
            due_date = item.get('due_date', 'TBD')
            
            html += f"""
            <tr>
                <td>{html.escape(item.get('issue', 'Unknown'))}</td>
                <td><span class="metric {priority_class}" style="padding: 2px 6px; font-size: 11px;">
                    {item.get('priority', 'P3')}
                </span></td>
                <td>{due_date}</td>
                <td>{item.get('assignee', 'Unassigned')}</td>
            </tr>
            """
        
        html += "</table>"
        return html

    def generate_trends_data(self, metrics):
        """Generate chart data for trends"""
        trends = metrics.get('trends', {})
        
        # Default trend data if not available
        if not trends:
            dates = [(datetime.now() - timedelta(days=i)).strftime("%Y-%m-%d") for i in range(7, 0, -1)]
            return {
                'labels': dates,
                'datasets': [
                    {
                        'label': 'Critical',
                        'data': [2, 3, 1, 2, 1, 0, 0],
                        'borderColor': '#d63384',
                        'backgroundColor': 'rgba(214, 51, 132, 0.1)'
                    },
                    {
                        'label': 'High',
                        'data': [5, 6, 4, 3, 2, 1, 1],
                        'borderColor': '#fd7e14',
                        'backgroundColor': 'rgba(253, 126, 20, 0.1)'
                    }
                ]
            }
        
        return trends

    def calculate_security_score(self, overview):
        """Calculate overall security score"""
        critical = overview.get('critical', 0)
        high = overview.get('high', 0)
        medium = overview.get('medium', 0)
        low = overview.get('low', 0)
        
        # Security score calculation (lower is better)
        total_issues = critical + high + medium + low
        if total_issues == 0:
            return 100
        
        # Weighted scoring
        weighted_score = (critical * 10) + (high * 5) + (medium * 2) + (low * 1)
        max_possible = total_issues * 10
        
        score = max(0, 100 - (weighted_score / max_possible * 100))
        return round(score, 1)

def main():
    parser = argparse.ArgumentParser(description='Generate BFSI security dashboard')
    parser.add_argument('--metrics', '-m', required=True, help='Security metrics JSON file')
    parser.add_argument('--output', '-o', default='security-dashboard.html', help='Output HTML file')
    
    args = parser.parse_args()
    
    generator = SecurityDashboardGenerator()
    generator.generate_dashboard(args.metrics, args.output)

if __name__ == '__main__':
    main()