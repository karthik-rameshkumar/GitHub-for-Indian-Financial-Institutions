#!/bin/bash

# BFSI Development Environment Setup Script
# Security-hardened setup for Indian Financial Institutions
# Compliance: RBI IT Framework, SEBI IT Governance, IRDAI Guidelines

set -euo pipefail

echo "🏛️  Setting up BFSI-compliant development environment..."

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

# Check if running as non-root user
if [[ $EUID -eq 0 ]]; then
    error "This script should not be run as root for security compliance"
    exit 1
fi

log "🔒 Initializing BFSI security baseline..."

# Create necessary directories with proper permissions
log "📁 Creating project structure..."
mkdir -p /workspace/{src,tests,docs,config,logs,scripts,data,backups}
mkdir -p /workspace/src/{api,models,services,utils,security}
mkdir -p /workspace/tests/{unit,integration,security,performance}
mkdir -p /workspace/config/{development,testing,staging}
mkdir -p /workspace/logs/{application,audit,security}
mkdir -p /workspace/scripts/{deployment,migration,backup}

# Set proper permissions for BFSI compliance
chmod 755 /workspace
chmod 755 /workspace/src /workspace/tests /workspace/docs /workspace/config
chmod 750 /workspace/logs /workspace/scripts /workspace/data /workspace/backups
chmod 750 /workspace/logs/audit /workspace/logs/security

log "🐍 Setting up Python virtual environment..."
python3 -m venv /workspace/.venv
source /workspace/.venv/bin/activate

# Upgrade pip and install wheel for better package installation
pip install --upgrade pip setuptools wheel

log "📦 Installing Python dependencies..."
if [ -f "/workspace/requirements.txt" ]; then
    pip install -r /workspace/requirements.txt
else
    # Install essential BFSI development packages
    pip install fastapi[all] uvicorn[standard] sqlalchemy alembic asyncpg redis
    pip install pytest pytest-asyncio pytest-cov httpx
    pip install black flake8 pylint mypy bandit safety
    pip install structlog prometheus-client python-dotenv
fi

log "🔧 Configuring development tools..."

# Configure Git for BFSI compliance
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input
git config --global user.name "${GITHUB_USER:-BFSI-Developer}"
git config --global user.email "${GITHUB_EMAIL:-developer@bfsi-org.com}"

# Set up pre-commit hooks for security
if command -v pre-commit &> /dev/null; then
    log "🚨 Setting up pre-commit security hooks..."
    cat > /workspace/.pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-json
      - id: check-added-large-files
      - id: check-merge-conflict
      - id: detect-private-key
  
  - repo: https://github.com/psf/black
    rev: 23.11.0
    hooks:
      - id: black
        language_version: python3
  
  - repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
  
  - repo: https://github.com/pycqa/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ['-r', '.']
        exclude: ^tests/
  
  - repo: https://github.com/gitguardian/ggshield
    rev: v1.21.0
    hooks:
      - id: ggshield
        language: python
        stages: [commit]
EOF
    
    pre-commit install
fi

log "🛡️  Setting up security scanning configuration..."

# Create bandit security configuration
cat > /workspace/.bandit << 'EOF'
[bandit]
exclude_dirs = tests,venv,.venv,env
skips = B101,B601

[bandit.plugins]
# B101: Skip assert_used test
# B601: Skip paramiko_calls test (allow for SFTP operations)
EOF

# Create safety policy for dependency scanning
cat > /workspace/.safety-policy.json << 'EOF'
{
  "security": {
    "ignore-vulns": [],
    "ignore-unpinned-requirements": false,
    "continue-on-vulnerability-error": false
  },
  "alert": {
    "ignore-severities": [],
    "ignore-cvss-severity-below": 7.0,
    "ignore-cvss-unknown-severity": false
  }
}
EOF

log "📋 Creating BFSI compliance templates..."

# Create FastAPI application template with security
cat > /workspace/src/main.py << 'EOF'
"""
BFSI Microservice Template
Security-hardened FastAPI application for Indian Financial Institutions
Compliance: RBI IT Framework, SEBI IT Governance, IRDAI Guidelines
"""

import logging
import os
import time
from contextlib import asynccontextmanager
from typing import Dict, Any

import structlog
from fastapi import FastAPI, Request, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from prometheus_client import Counter, Histogram, generate_latest
from starlette.responses import Response
from starlette.status import HTTP_200_OK

# Configure structured logging for audit compliance
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.processors.JSONRenderer()
    ],
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    wrapper_class=structlog.stdlib.BoundLogger,
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Prometheus metrics for monitoring
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_DURATION = Histogram('http_request_duration_seconds', 'HTTP request duration')

# Security configuration
security = HTTPBearer()

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan management with audit logging."""
    logger.info("🏛️  Starting BFSI microservice", service="bfsi-api", environment=os.getenv("ENVIRONMENT", "development"))
    yield
    logger.info("🔒 Shutting down BFSI microservice", service="bfsi-api")

# Create FastAPI application with security headers
app = FastAPI(
    title="BFSI Microservice API",
    description="Secure API for Indian Financial Institutions",
    version="1.0.0",
    docs_url="/docs" if os.getenv("ENVIRONMENT") == "development" else None,
    redoc_url="/redoc" if os.getenv("ENVIRONMENT") == "development" else None,
    lifespan=lifespan
)

# Security middleware
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["localhost", "127.0.0.1", "*.bfsi-org.com"]
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://*.bfsi-org.com"],
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["*"],
)

@app.middleware("http")
async def audit_middleware(request: Request, call_next):
    """Audit middleware for compliance logging."""
    start_time = time.time()
    
    # Log incoming request
    logger.info(
        "Incoming request",
        method=request.method,
        url=str(request.url),
        client_ip=request.client.host,
        user_agent=request.headers.get("user-agent")
    )
    
    response = await call_next(request)
    
    # Calculate request duration
    duration = time.time() - start_time
    
    # Update Prometheus metrics
    REQUEST_COUNT.labels(
        method=request.method,
        endpoint=request.url.path,
        status=response.status_code
    ).inc()
    REQUEST_DURATION.observe(duration)
    
    # Log response
    logger.info(
        "Request completed",
        method=request.method,
        url=str(request.url),
        status_code=response.status_code,
        duration=duration
    )
    
    return response

async def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    """Verify JWT token for API authentication."""
    # TODO: Implement proper JWT verification
    # This is a placeholder - implement according to your auth provider
    if not credentials.credentials:
        raise HTTPException(status_code=401, detail="Invalid authentication token")
    return credentials.credentials

@app.get("/health", status_code=HTTP_200_OK)
async def health_check() -> Dict[str, Any]:
    """Health check endpoint for service monitoring."""
    return {
        "status": "healthy",
        "service": "bfsi-api",
        "version": "1.0.0",
        "timestamp": time.time(),
        "environment": os.getenv("ENVIRONMENT", "development")
    }

@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint."""
    return Response(generate_latest(), media_type="text/plain")

@app.get("/api/v1/secure", dependencies=[Depends(verify_token)])
async def secure_endpoint(token: str = Depends(verify_token)) -> Dict[str, str]:
    """Secured endpoint requiring authentication."""
    logger.info("Secure endpoint accessed", token_present=bool(token))
    return {"message": "This is a secured BFSI endpoint", "authenticated": True}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
EOF

# Create environment configuration template
cat > /workspace/.env.example << 'EOF'
# BFSI Development Environment Configuration
# DO NOT commit actual secrets to version control

# Application Settings
ENVIRONMENT=development
DEBUG=true
APP_NAME=bfsi-microservice
APP_VERSION=1.0.0

# Database Configuration (Development)
DATABASE_URL=postgresql://postgres:password@localhost:5432/bfsi_dev
DB_ECHO=false
DB_POOL_SIZE=10
DB_MAX_OVERFLOW=20

# Redis Configuration
REDIS_URL=redis://localhost:6379/0
REDIS_PASSWORD=

# Security Settings
SECRET_KEY=your-secret-key-here
JWT_ALGORITHM=HS256
JWT_EXPIRATION_HOURS=24
BCRYPT_ROUNDS=12

# Audit and Compliance
AUDIT_ENABLED=true
AUDIT_LOG_LEVEL=INFO
COMPLIANCE_MODE=BFSI
DATA_RESIDENCY=INDIA

# Monitoring and Observability
PROMETHEUS_ENABLED=true
METRICS_PORT=8001
LOG_LEVEL=INFO
STRUCTURED_LOGGING=true

# External Services (Development)
PAYMENT_GATEWAY_URL=https://sandbox.payment-gateway.com
PAYMENT_GATEWAY_API_KEY=sandbox-key
CREDIT_BUREAU_URL=https://dev.credit-bureau.com
CREDIT_BUREAU_API_KEY=dev-key

# Network and Security
ALLOWED_HOSTS=localhost,127.0.0.1,*.bfsi-org.com
CORS_ORIGINS=https://*.bfsi-org.com
TRUSTED_PROXIES=10.0.0.0/8,172.16.0.0/12,192.168.0.0/16

# File Upload Limits
MAX_FILE_SIZE_MB=10
ALLOWED_FILE_TYPES=pdf,xlsx,csv,txt

# Rate Limiting
RATE_LIMIT_PER_MINUTE=100
RATE_LIMIT_BURST=200
EOF

log "🧪 Setting up testing framework..."

# Create pytest configuration
cat > /workspace/pytest.ini << 'EOF'
[tool:pytest]
testpaths = tests
python_files = test_*.py *_test.py
python_classes = Test*
python_functions = test_*
addopts = 
    --strict-markers
    --strict-config
    --cov=src
    --cov-report=term-missing
    --cov-report=html:htmlcov
    --cov-report=xml
    --cov-fail-under=80
markers =
    unit: Unit tests
    integration: Integration tests
    security: Security tests
    performance: Performance tests
    slow: Slow running tests
EOF

# Create sample unit test
mkdir -p /workspace/tests/unit
cat > /workspace/tests/unit/test_main.py << 'EOF'
"""Unit tests for BFSI microservice."""

import pytest
from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_health_check():
    """Test health check endpoint."""
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "healthy"
    assert "service" in data
    assert "version" in data

def test_metrics_endpoint():
    """Test metrics endpoint."""
    response = client.get("/metrics")
    assert response.status_code == 200
    assert "text/plain" in response.headers["content-type"]

def test_secure_endpoint_without_auth():
    """Test secure endpoint without authentication."""
    response = client.get("/api/v1/secure")
    assert response.status_code == 403  # Forbidden without auth
EOF

log "📊 Setting up development scripts..."

# Create development helper scripts
mkdir -p /workspace/scripts
cat > /workspace/scripts/dev-server.sh << 'EOF'
#!/bin/bash
# Start development server with auto-reload

echo "🚀 Starting BFSI development server..."
export ENVIRONMENT=development
export DEBUG=true

cd /workspace
source .venv/bin/activate
uvicorn src.main:app --host 0.0.0.0 --port 8000 --reload --log-level info
EOF

cat > /workspace/scripts/run-tests.sh << 'EOF'
#!/bin/bash
# Run comprehensive test suite with security checks

echo "🧪 Running BFSI test suite..."

cd /workspace
source .venv/bin/activate

echo "Running unit and integration tests..."
pytest -v --cov=src tests/

echo "Running security scan with Bandit..."
bandit -r src/ -f json -o logs/security/bandit-report.json

echo "Checking dependencies for vulnerabilities..."
safety check --json --output logs/security/safety-report.json

echo "Running code quality checks..."
flake8 src/ tests/
black --check src/ tests/
mypy src/

echo "✅ Test suite completed!"
EOF

chmod +x /workspace/scripts/*.sh

log "📚 Creating documentation structure..."
cat > /workspace/README.md << 'EOF'
# BFSI Microservice

Secure microservice template for Indian Financial Institutions, compliant with RBI IT Framework, SEBI IT Governance, and IRDAI Cybersecurity Guidelines.

## Features

- 🔒 Security-hardened FastAPI application
- 🏛️ BFSI compliance controls
- 📊 Prometheus metrics and monitoring
- 🧪 Comprehensive testing framework
- 📋 Audit logging and compliance reporting
- 🛡️ Pre-commit security hooks

## Quick Start

1. **Environment Setup**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

2. **Install Dependencies**
   ```bash
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Run Development Server**
   ```bash
   ./scripts/dev-server.sh
   ```

4. **Run Tests**
   ```bash
   ./scripts/run-tests.sh
   ```

## API Documentation

- Health Check: `GET /health`
- Metrics: `GET /metrics`
- API Docs: `GET /docs` (development only)

## Security

- JWT authentication required for protected endpoints
- CORS configured for trusted domains
- Request/response audit logging
- Dependency vulnerability scanning
- Code security analysis with Bandit

## Compliance

This service is designed to meet:
- RBI IT Framework 2021
- SEBI IT Governance Guidelines 2023
- IRDAI Cybersecurity Guidelines 2020
EOF

log "✅ BFSI development environment setup completed!"
log "🔍 Summary of configured components:"
log "   - Python virtual environment with BFSI dependencies"
log "   - FastAPI application template with security"
log "   - Comprehensive testing framework"
log "   - Security scanning and code quality tools"
log "   - Audit logging and compliance controls"
log "   - Development scripts and documentation"

warn "Remember to:"
warn "   1. Copy .env.example to .env and configure your settings"
warn "   2. Set up your database and Redis connections"
warn "   3. Configure proper JWT authentication"
warn "   4. Review and customize security settings for your environment"

log "🏛️ Ready for secure BFSI development!"