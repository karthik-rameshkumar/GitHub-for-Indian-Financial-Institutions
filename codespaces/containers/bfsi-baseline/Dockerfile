# BFSI Security Baseline Container
# Maximum security hardening for Indian Financial Institutions
# Compliance: RBI IT Framework, SEBI IT Governance, IRDAI Guidelines

FROM debian:bullseye-slim

# Build arguments for security tracking
ARG BUILD_DATE
ARG BUILD_VERSION="1.0.0"
ARG SECURITY_BASELINE="BFSI-Maximum"

# Security-focused metadata
LABEL maintainer="BFSI Security Team"
LABEL org.opencontainers.image.title="BFSI Security Baseline Container"
LABEL org.opencontainers.image.description="Maximum security baseline for BFSI development"
LABEL org.opencontainers.image.version="${BUILD_VERSION}"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL security.baseline="${SECURITY_BASELINE}"
LABEL compliance.rbi="IT-Framework-2021"
LABEL compliance.sebi="IT-Governance-2023"
LABEL compliance.irdai="Cybersecurity-Guidelines-2020"
LABEL security.hardening="maximum"
LABEL security.scan-required="true"

# Security-focused environment
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Kolkata
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PATH=/usr/local/bin:/usr/bin:/bin
ENV SHELL=/bin/bash

# Update system and install minimal security packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Essential system tools
    ca-certificates \
    curl \
    wget \
    gnupg \
    # Security and audit tools
    openssl \
    apt-transport-https \
    software-properties-common \
    # Basic development tools
    git \
    vim \
    nano \
    # Network security tools
    netcat-openbsd \
    # Timezone support
    tzdata \
    # Process management
    procps \
    # File utilities
    file \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* \
    && rm -rf /var/tmp/* \
    && rm -rf /var/cache/apt/*

# Configure timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create security-focused user
RUN groupadd --gid 1001 bfsi \
    && useradd --uid 1001 --gid bfsi --shell /bin/bash --create-home bfsi \
    && echo 'bfsi ALL=(ALL) NOPASSWD: /usr/bin/apt-get, /usr/bin/curl, /usr/bin/wget, /bin/chown, /bin/chmod' >> /etc/sudoers.d/bfsi \
    && chmod 0440 /etc/sudoers.d/bfsi

# Create secure workspace structure
RUN mkdir -p /workspace /workspace/logs /workspace/config /workspace/scripts \
    && chown -R bfsi:bfsi /workspace \
    && chmod 755 /workspace \
    && chmod 750 /workspace/logs /workspace/config /workspace/scripts

# Install Docker CLI for container operations (minimal)
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian bullseye stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null \
    && apt-get update \
    && apt-get install -y --no-install-recommends docker-ce-cli \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Security hardening - remove unnecessary files and set permissions
RUN find /usr/bin -type f -perm /u+s -exec chmod u-s {} \; \
    && find /usr/bin -type f -perm /g+s -exec chmod g-s {} \; \
    && rm -rf /tmp/* /var/tmp/* \
    && chmod 755 /home/bfsi \
    && chmod 700 /home/bfsi/.bashrc /home/bfsi/.profile

# Copy security configuration scripts
COPY security-config/ /tmp/security-config/
COPY security-setup.sh /tmp/security-setup.sh
COPY post-start-security.sh /tmp/post-start-security.sh
RUN chmod +x /tmp/security-setup.sh /tmp/post-start-security.sh \
    && chown bfsi:bfsi /tmp/security-setup.sh /tmp/post-start-security.sh

# Configure secure shell environment
RUN echo 'export PS1="\[\033[01;31m\]BFSI-SECURE\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /home/bfsi/.bashrc \
    && echo 'umask 027' >> /home/bfsi/.bashrc \
    && echo 'export HISTCONTROL=ignoreboth' >> /home/bfsi/.bashrc \
    && echo 'export HISTSIZE=1000' >> /home/bfsi/.bashrc \
    && echo 'export HISTFILESIZE=2000' >> /home/bfsi/.bashrc

# Security policies and restrictions
RUN echo 'Defaults env_reset' >> /etc/sudoers \
    && echo 'Defaults secure_path="/usr/local/bin:/usr/bin:/bin"' >> /etc/sudoers \
    && echo 'Defaults timestamp_timeout=5' >> /etc/sudoers

# Switch to non-root user
USER bfsi

# Set secure working directory
WORKDIR /workspace

# Health check for security baseline
HEALTHCHECK --interval=60s --timeout=10s --start-period=30s --retries=3 \
    CMD /bin/bash -c 'test -f /workspace/.security-baseline || exit 1'

# Default secure command
CMD ["/bin/bash", "-l"]

# Security runtime labels
LABEL security.user="bfsi:1001"
LABEL security.workdir="/workspace"
LABEL security.readonly="true"
LABEL security.capabilities="none"
LABEL security.apparmor="docker-default"