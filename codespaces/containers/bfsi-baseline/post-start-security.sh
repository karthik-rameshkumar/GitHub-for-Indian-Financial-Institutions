#!/bin/bash

# BFSI Post-Start Security Script
# Additional security checks and monitoring after container start

set -euo pipefail

log() {
    echo -e "\033[0;32m[POST-START] $(date +'%Y-%m-%d %H:%M:%S')] $1\033[0m"
}

log "🔒 Running post-start security verification..."

# Verify security baseline is active
if [[ -f "/workspace/.security-baseline" ]]; then
    log "✅ Security baseline verified"
else
    echo "❌ Security baseline not found - setup may have failed"
    exit 1
fi

# Start security monitoring in background
if [[ -x "/workspace/scripts/security-monitor.sh" ]]; then
    log "🔍 Starting security monitoring..."
    nohup /workspace/scripts/security-monitor.sh > /workspace/logs/security/monitor.log 2>&1 &
fi

# Log container start event
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "{\"timestamp\":\"$timestamp\",\"event\":\"container_start\",\"user\":\"$(whoami)\",\"baseline\":\"active\"}" >> /workspace/logs/audit/container-events.log

log "🏛️ BFSI security environment ready for development"