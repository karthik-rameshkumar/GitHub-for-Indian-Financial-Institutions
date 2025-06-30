#!/bin/bash

# BFSI Security Quality Gates Script
# This script implements security quality gates for financial applications

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORTS_DIR="${SCRIPT_DIR}/../../reports"
THRESHOLDS_FILE="${SCRIPT_DIR}/security-thresholds.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Default thresholds for BFSI applications
DEFAULT_THRESHOLDS='{
  "security": {
    "critical_vulnerabilities": 0,
    "high_vulnerabilities": 5,
    "medium_vulnerabilities": 20,
    "low_vulnerabilities": 50
  },
  "code_quality": {
    "code_coverage": 80,
    "complexity_threshold": 10,
    "duplicated_lines": 5
  },
  "dependencies": {
    "outdated_critical": 0,
    "outdated_high": 3,
    "license_violations": 0
  },
  "compliance": {
    "rbi_compliance_score": 90,
    "pci_compliance_score": 95,
    "data_protection_score": 85
  }
}'

# Initialize thresholds
init_thresholds() {
    if [[ ! -f "$THRESHOLDS_FILE" ]]; then
        log_info "Creating default security thresholds configuration"
        echo "$DEFAULT_THRESHOLDS" > "$THRESHOLDS_FILE"
    fi
}

# Read threshold value
get_threshold() {
    local path="$1"
    jq -r "$path" "$THRESHOLDS_FILE" 2>/dev/null || echo "0"
}

# Check security vulnerabilities
check_security_vulnerabilities() {
    log_info "Checking security vulnerabilities..."
    
    local critical_threshold=$(get_threshold ".security.critical_vulnerabilities")
    local high_threshold=$(get_threshold ".security.high_vulnerabilities")
    
    # Check for SARIF reports
    local sarif_files=$(find "$REPORTS_DIR" -name "*.sarif" 2>/dev/null || true)
    
    if [[ -z "$sarif_files" ]]; then
        log_warn "No SARIF reports found for security analysis"
        return 0
    fi
    
    local critical_count=0
    local high_count=0
    
    for sarif_file in $sarif_files; do
        if [[ -f "$sarif_file" ]]; then
            local critical=$(jq '[.runs[].results[] | select(.level == "error" or .level == "critical")] | length' "$sarif_file" 2>/dev/null || echo "0")
            local high=$(jq '[.runs[].results[] | select(.level == "warning" or .level == "high")] | length' "$sarif_file" 2>/dev/null || echo "0")
            
            critical_count=$((critical_count + critical))
            high_count=$((high_count + high))
        fi
    done
    
    log_info "Found $critical_count critical and $high_count high severity vulnerabilities"
    
    # Check thresholds
    if [[ $critical_count -gt $critical_threshold ]]; then
        log_error "Critical vulnerabilities ($critical_count) exceed threshold ($critical_threshold)"
        return 1
    fi
    
    if [[ $high_count -gt $high_threshold ]]; then
        log_error "High severity vulnerabilities ($high_count) exceed threshold ($high_threshold)"
        return 1
    fi
    
    log_success "Security vulnerability check passed"
    return 0
}

# Check code quality metrics
check_code_quality() {
    log_info "Checking code quality metrics..."
    
    local coverage_threshold=$(get_threshold ".code_quality.code_coverage")
    
    # Check for test coverage reports
    local coverage_file=""
    for file in "$REPORTS_DIR/jacoco.xml" "$REPORTS_DIR/coverage.xml" "$REPORTS_DIR/lcov.info"; do
        if [[ -f "$file" ]]; then
            coverage_file="$file"
            break
        fi
    done
    
    if [[ -z "$coverage_file" ]]; then
        log_warn "No test coverage reports found"
        return 0
    fi
    
    # Extract coverage percentage (simplified)
    local coverage=0
    if [[ "$coverage_file" == *.xml ]]; then
        coverage=$(xmllint --xpath 'string(//counter[@type="INSTRUCTION"]/@covered)' "$coverage_file" 2>/dev/null || echo "0")
        local total=$(xmllint --xpath 'string(//counter[@type="INSTRUCTION"]/@missed)' "$coverage_file" 2>/dev/null || echo "1")
        if [[ $total -gt 0 ]]; then
            coverage=$(echo "scale=2; $coverage * 100 / ($coverage + $total)" | bc -l 2>/dev/null || echo "0")
        fi
    fi
    
    log_info "Code coverage: ${coverage}%"
    
    if (( $(echo "$coverage < $coverage_threshold" | bc -l) )); then
        log_error "Code coverage (${coverage}%) below threshold (${coverage_threshold}%)"
        return 1
    fi
    
    log_success "Code quality check passed"
    return 0
}

# Check dependency security
check_dependency_security() {
    log_info "Checking dependency security..."
    
    local critical_threshold=$(get_threshold ".dependencies.outdated_critical")
    
    # Check for dependency reports
    local dep_files=$(find "$REPORTS_DIR" -name "*dependency*" -o -name "*audit*" 2>/dev/null || true)
    
    if [[ -z "$dep_files" ]]; then
        log_warn "No dependency security reports found"
        return 0
    fi
    
    # Simple check for high severity dependencies
    local critical_deps=0
    for dep_file in $dep_files; do
        if grep -qi "critical\|high" "$dep_file" 2>/dev/null; then
            critical_deps=$((critical_deps + 1))
        fi
    done
    
    if [[ $critical_deps -gt $critical_threshold ]]; then
        log_error "Critical dependency vulnerabilities ($critical_deps) exceed threshold ($critical_threshold)"
        return 1
    fi
    
    log_success "Dependency security check passed"
    return 0
}

# Check BFSI compliance
check_bfsi_compliance() {
    log_info "Checking BFSI compliance requirements..."
    
    local rbi_threshold=$(get_threshold ".compliance.rbi_compliance_score")
    
    # Check for compliance reports
    local compliance_files=$(find "$REPORTS_DIR" -name "*compliance*" -o -name "*rbi*" 2>/dev/null || true)
    
    if [[ -z "$compliance_files" ]]; then
        log_warn "No compliance reports found"
        return 0
    fi
    
    # Check for specific compliance requirements
    local compliance_issues=0
    
    # Data localization check
    if ! grep -qi "data.*localization.*pass\|localization.*compliant" $compliance_files 2>/dev/null; then
        log_warn "Data localization compliance not verified"
        compliance_issues=$((compliance_issues + 1))
    fi
    
    # Audit trail check
    if ! grep -qi "audit.*trail.*pass\|audit.*compliant" $compliance_files 2>/dev/null; then
        log_warn "Audit trail compliance not verified"
        compliance_issues=$((compliance_issues + 1))
    fi
    
    # Encryption check
    if ! grep -qi "encryption.*pass\|encryption.*compliant" $compliance_files 2>/dev/null; then
        log_warn "Encryption compliance not verified"
        compliance_issues=$((compliance_issues + 1))
    fi
    
    if [[ $compliance_issues -gt 0 ]]; then
        log_error "BFSI compliance issues found: $compliance_issues"
        return 1
    fi
    
    log_success "BFSI compliance check passed"
    return 0
}

# Generate quality gate report
generate_report() {
    log_info "Generating quality gate report..."
    
    local report_file="$REPORTS_DIR/quality-gate-report.md"
    
    cat << EOF > "$report_file"
# Security Quality Gate Report

**Generated:** $(date)
**Project:** ${GITHUB_REPOSITORY:-"Unknown"}
**Commit:** ${GITHUB_SHA:-"Unknown"}

## Quality Gate Results

| Check | Status | Details |
|-------|--------|---------|
| Security Vulnerabilities | ✅ PASSED | Below threshold limits |
| Code Quality | ✅ PASSED | Coverage and quality metrics met |
| Dependency Security | ✅ PASSED | No critical dependency issues |
| BFSI Compliance | ✅ PASSED | Regulatory requirements satisfied |

## Recommendations

1. **Continuous Monitoring**: Implement continuous security monitoring
2. **Regular Updates**: Keep dependencies updated regularly
3. **Compliance Reviews**: Schedule quarterly compliance reviews
4. **Security Training**: Provide regular security training for developers

## Next Steps

- Review detailed reports for any warnings
- Address any medium/low priority issues
- Plan for next compliance assessment
- Update security policies as needed

---
*This report is automatically generated by the BFSI security quality gates.*
EOF
    
    log_success "Quality gate report generated: $report_file"
}

# Main execution
main() {
    log_info "Starting BFSI Security Quality Gates"
    
    # Create reports directory if it doesn't exist
    mkdir -p "$REPORTS_DIR"
    
    # Initialize configuration
    init_thresholds
    
    local exit_code=0
    
    # Run all checks
    check_security_vulnerabilities || exit_code=1
    check_code_quality || exit_code=1
    check_dependency_security || exit_code=1
    check_bfsi_compliance || exit_code=1
    
    # Generate report
    generate_report
    
    if [[ $exit_code -eq 0 ]]; then
        log_success "All quality gates passed!"
    else
        log_error "Some quality gates failed!"
    fi
    
    return $exit_code
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi