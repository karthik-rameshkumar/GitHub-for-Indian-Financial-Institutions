# Multi-stage Dockerfile for BFSI Java Spring Boot Applications
# Compliant with RBI IT Framework and security requirements

# Stage 1: Build Stage with Security Scanning
FROM maven:3.9.0-eclipse-temurin-17 AS builder

# Set build-time labels for traceability
LABEL stage="builder"
LABEL compliance="rbi-it-framework"
LABEL security-level="high"

# Create non-root user for build process
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set working directory
WORKDIR /build

# Copy dependency files first for better caching
COPY pom.xml ./
COPY src ./src

# Install security tools for build-time scanning
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Run dependency vulnerability check during build
RUN mvn dependency-check:check -DfailBuildOnCVSS=7 -DskipTests=true || \
    (echo "❌ Dependency vulnerabilities found!" && exit 1)

# Build the application
RUN mvn clean package -DskipTests=true \
    -Dspring.profiles.active=docker \
    -Dmaven.repo.local=/tmp/.m2

# Verify JAR file integrity
RUN ls -la target/*.jar && \
    sha256sum target/*.jar > target/checksum.txt

# Stage 2: Security Scanning Stage
FROM builder AS security-scanner

# Install additional security tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    clamav \
    clamav-daemon \
    && rm -rf /var/lib/apt/lists/*

# Update virus definitions and scan
RUN freshclam --quiet && \
    clamscan -r /build/target --infected --remove=no || \
    (echo "❌ Malware detected in build artifacts!" && exit 1)

# Run additional security validations
RUN echo "✅ Security scanning completed successfully"

# Stage 3: Runtime Stage
FROM eclipse-temurin:17-jre-alpine AS runtime

# Security and compliance labels
LABEL org.opencontainers.image.title="NBFC Core Application"
LABEL org.opencontainers.image.description="Banking Core System for Indian NBFC"
LABEL org.opencontainers.image.vendor="BFSI Organization"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.created="${BUILD_DATE}"
LABEL compliance.rbi="IT-Framework-2021"
LABEL compliance.sebi="IT-Governance-2023"
LABEL security.scan-date="${BUILD_DATE}"
LABEL security.base-image="eclipse-temurin:17-jre-alpine"

# Install security packages and remove package manager cache
RUN apk add --no-cache \
    dumb-init \
    curl \
    tzdata \
    ca-certificates \
    && rm -rf /var/cache/apk/*

# Set timezone to Indian Standard Time
ENV TZ=Asia/Kolkata
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Create application user with specific UID for security
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup -h /app -s /bin/sh

# Create application directories with proper permissions
RUN mkdir -p /app/logs /app/config /app/temp /app/audit && \
    chown -R appuser:appgroup /app && \
    chmod 755 /app && \
    chmod 750 /app/logs /app/audit && \
    chmod 700 /app/temp

# Set working directory
WORKDIR /app

# Copy JAR file from builder stage
COPY --from=security-scanner --chown=appuser:appgroup /build/target/*.jar app.jar
COPY --from=security-scanner --chown=appuser:appgroup /build/target/checksum.txt ./

# Verify JAR integrity
RUN sha256sum -c checksum.txt && rm checksum.txt

# Create application configuration directory
COPY --chown=appuser:appgroup config/docker/ ./config/

# Set up logging configuration
RUN mkdir -p /app/logs && \
    chown appuser:appgroup /app/logs && \
    chmod 750 /app/logs

# Security hardening - remove unnecessary packages and files
RUN rm -rf /tmp/* /var/tmp/* && \
    find /app -type f -name "*.sh" -exec chmod +x {} \;

# Switch to non-root user
USER appuser:appgroup

# Environment variables for application
ENV JAVA_OPTS="-Xms512m -Xmx2048m \
    -XX:+UseG1GC \
    -XX:+UseStringDeduplication \
    -XX:+PrintGCDetails \
    -XX:+PrintGCTimeStamps \
    -Xloggc:/app/logs/gc.log \
    -XX:+UseGCLogFileRotation \
    -XX:NumberOfGCLogFiles=5 \
    -XX:GCLogFileSize=10M \
    -Djava.security.egd=file:/dev/./urandom \
    -Dspring.profiles.active=docker \
    -Dlogging.config=/app/config/logback-spring.xml \
    -Daudit.log.path=/app/audit"

ENV SERVER_PORT=8080
ENV MANAGEMENT_PORT=8081
ENV SPRING_PROFILES_ACTIVE=docker

# Health check configuration
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:${MANAGEMENT_PORT}/actuator/health || exit 1

# Expose application and management ports
EXPOSE $SERVER_PORT $MANAGEMENT_PORT

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Application startup with security considerations
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar \
    --server.port=$SERVER_PORT \
    --management.server.port=$MANAGEMENT_PORT \
    --logging.file.path=/app/logs \
    --audit.enabled=true \
    --security.require-ssl=false \
    --management.endpoints.web.exposure.include=health,info,metrics,prometheus"]

# Security annotations for runtime
LABEL security.user="appuser:1001"
LABEL security.ports="8080,8081"
LABEL security.volumes="/app/logs,/app/audit"
LABEL security.capabilities="none"