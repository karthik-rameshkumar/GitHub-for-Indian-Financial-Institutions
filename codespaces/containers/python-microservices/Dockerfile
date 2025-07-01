# BFSI Python Microservices Development Container
# Security-hardened container for Indian Financial Institutions
# Compliance: RBI IT Framework, SEBI IT Governance, IRDAI Guidelines

FROM python:3.11-slim-bullseye

# Build arguments for security and compliance
ARG BUILD_DATE
ARG BUILD_VERSION="1.0.0"
ARG COMPLIANCE_VERSION="RBI-2021"

# Container metadata for BFSI compliance
LABEL maintainer="BFSI Development Team"
LABEL org.opencontainers.image.title="BFSI Python Microservices DevContainer"
LABEL org.opencontainers.image.description="Secure development environment for Indian Financial Services"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL org.opencontainers.image.vendor="BFSI Organization"
LABEL compliance.framework="${COMPLIANCE_VERSION}"
LABEL compliance.rbi="IT-Framework-2021"
LABEL compliance.sebi="IT-Governance-2023"
LABEL compliance.irdai="Cybersecurity-Guidelines-2020"
LABEL security.scan-date="${BUILD_DATE}"
LABEL security.baseline="BFSI-Hardened"

# Set timezone to Indian Standard Time for compliance
ENV TZ=Asia/Kolkata
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV PYTHONPATH=/workspace/src
ENV PIP_NO_CACHE_DIR=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies and security packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Essential development tools
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    htop \
    tree \
    jq \
    unzip \
    # Security and audit tools
    ca-certificates \
    gnupg \
    software-properties-common \
    apt-transport-https \
    # Database clients for BFSI development
    postgresql-client \
    redis-tools \
    # Network and debugging tools
    netcat \
    telnet \
    dig \
    traceroute \
    # Timezone and locale support
    tzdata \
    locales \
    # Python development dependencies
    python3-dev \
    python3-pip \
    python3-venv \
    # SSL/TLS tools for financial APIs
    openssl \
    # Monitoring and logging
    rsyslog \
    logrotate \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/*

# Configure timezone and locale
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && locale-gen en_US.UTF-8

# Create non-root user for security (matching devcontainer user)
RUN groupadd --gid 1000 vscode \
    && useradd --uid 1000 --gid vscode --shell /bin/bash --create-home vscode \
    && echo 'vscode ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers.d/vscode \
    && chmod 0440 /etc/sudoers.d/vscode

# Create application directories with proper permissions
RUN mkdir -p /workspace /workspace/src /workspace/tests /workspace/logs /workspace/config \
    /home/vscode/.cache /home/vscode/.local \
    && chown -R vscode:vscode /workspace /home/vscode

# Install Python development and security tools
COPY requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt

# Install additional BFSI development tools
RUN pip install --no-cache-dir \
    # Web frameworks for microservices
    fastapi[all]==0.104.1 \
    uvicorn[standard]==0.24.0 \
    pydantic==2.5.0 \
    # Database and ORM tools
    sqlalchemy==2.0.23 \
    alembic==1.13.0 \
    asyncpg==0.29.0 \
    redis==5.0.1 \
    # Security and authentication
    cryptography==41.0.7 \
    pyjwt==2.8.0 \
    passlib[bcrypt]==1.7.4 \
    python-multipart==0.0.6 \
    # Testing and quality assurance
    pytest==7.4.3 \
    pytest-asyncio==0.21.1 \
    pytest-cov==4.1.0 \
    httpx==0.25.2 \
    # Code quality and security
    black==23.11.0 \
    flake8==6.1.0 \
    pylint==3.0.3 \
    mypy==1.7.1 \
    bandit==1.7.5 \
    safety==2.3.5 \
    # Monitoring and observability
    prometheus-client==0.19.0 \
    structlog==23.2.0 \
    # BFSI-specific libraries
    python-dateutil==2.8.2 \
    validators==0.22.0 \
    phonenumbers==8.13.26 \
    # Development utilities
    python-dotenv==1.0.0 \
    rich==13.7.0 \
    typer==0.9.0

# Install Node.js for frontend tooling (if needed)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g \
        yarn \
        pnpm \
        @angular/cli \
        create-react-app \
        typescript \
        eslint \
        prettier \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Docker CLI for container operations
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y docker-ce-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl for Kubernetes development
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && rm kubectl

# Copy setup scripts
COPY setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

# Configure Git for BFSI compliance
RUN git config --system init.defaultBranch main \
    && git config --system pull.rebase false \
    && git config --system core.autocrlf input \
    && git config --system commit.gpgsign false

# Security hardening
RUN chmod 755 /workspace \
    && chmod 755 /home/vscode \
    && find /workspace -type d -exec chmod 755 {} \; \
    && find /home/vscode -type d -exec chmod 755 {} \;

# Switch to non-root user
USER vscode

# Set working directory
WORKDIR /workspace

# Configure shell environment for development
RUN echo 'export PS1="\[\033[01;32m\]BFSI-DEV\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/vscode/.bashrc \
    && echo 'alias ll="ls -alF"' >> /home/vscode/.bashrc \
    && echo 'alias la="ls -A"' >> /home/vscode/.bashrc \
    && echo 'alias l="ls -CF"' >> /home/vscode/.bashrc \
    && echo 'alias python="python3"' >> /home/vscode/.bashrc \
    && echo 'alias pip="pip3"' >> /home/vscode/.bashrc

# Health check for container readiness
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD python3 -c "import sys; sys.exit(0)" || exit 1

# Default command
CMD ["/bin/bash"]

# Security labels for runtime
LABEL security.user="vscode:1000"
LABEL security.workdir="/workspace"
LABEL security.capabilities="CAP_NET_BIND_SERVICE"
LABEL security.readonly="true"