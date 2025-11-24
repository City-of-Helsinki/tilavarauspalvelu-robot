# =============================================================================
# Robot Framework Test Environment with Playwright
# =============================================================================
# Based on Microsoft's Playwright image (mcr.microsoft.com/playwright:v1.53.2-noble)
# This base image includes:
# - Ubuntu 24.04 Noble Numbat as the OS base
# - Node.js 22.x with npm and yarn pre-installed
# - Python 3.12.3 pre-installed (but without venv module)
# - Pre-installed Playwright browsers in /ms-playwright directory
# - Playwright core package and dependencies pre-configured
# - Multi-architecture support (amd64/arm64)
# 
# Note: Base image timezone is America/Los_Angeles (we override to UTC)
# FROM mcr.microsoft.com/playwright:v1.50.0-noble
FROM mcr.microsoft.com/playwright:v1.53.2-noble

# =============================================================================
# Environment Configuration
# =============================================================================
# Configure system locale, timezone, and Robot Framework specific paths
# Finnish locale is set for using Varaamo
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Helsinki \
    LANG=fi_FI.UTF-8 \
    LC_ALL=fi_FI.UTF-8 \
    ROBOT_REPORTS_DIR=/opt/robotframework/reports \
    ROBOT_WORK_DIR=/opt/robotframework/temp \
    CLEANED_EMAILS_PATH=/opt/robotframework/tests/Resources/downloads/cleaned_emails.json \
    PATH="/home/pwuser/.venv/bin:$PATH"

# =============================================================================
# System Dependencies Installation
# =============================================================================
# Temporarily switch to root for system package installation
USER root

# Install required system packages for Robot Framework and GUI testing
# The base image has Python 3.12.3 but lacks the python3-venv package with ensurepip
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-venv \
    locales \
    shellcheck \
    shfmt \
    && echo "Configure Finnish locale for Varaamo" \
    && echo "fi_FI.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && echo "Clean up package cache and temporary files to reduce image size" \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

# =============================================================================
# Directory Structure and Permissions Setup
# =============================================================================
# Create Robot Framework directory structure with secure permissions
RUN mkdir -p ${ROBOT_REPORTS_DIR} \
    ${ROBOT_WORK_DIR} \
    /opt/robotframework/output \
    /opt/robotframework/tests/Resources/downloads \
    && echo "Create placeholder file for email cleaning functionality" \
    && touch /opt/robotframework/tests/Resources/downloads/cleaned_emails.json \
    && echo "Set proper ownership to pwuser (pre-existing user from Playwright base image)" \
    && chown -R pwuser:pwuser \
        ${ROBOT_REPORTS_DIR} \
        ${ROBOT_WORK_DIR} \
        /opt/robotframework/output \
        /opt/robotframework/tests/Resources/downloads \
        /var/log \
    && echo "Apply secure permissions" \
    && chmod -R 755 ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR} \
    && chmod -R 775 /opt/robotframework/output \
    && chmod -R 775 /opt/robotframework/tests/Resources/downloads \
    && chmod 664 /opt/robotframework/tests/Resources/downloads/cleaned_emails.json \
    && chmod 755 /var/log

# =============================================================================
# Python Environment Setup
# =============================================================================
# Switch to non-root user
USER pwuser

# Copy dependencies
COPY --chown=pwuser:pwuser requirements.txt /tmp/requirements.txt

# Create isolated Python virtual environment and install dependencies
# --no-cache-dir prevents pip from caching packages, reducing image size
# Browser.entry init prepares Playwright without downloading browser binaries (--skip-browsers)
RUN python3 -m venv /home/pwuser/.venv \
    && echo "Upgrade pip and wheel for latest features and security fixes" \
    && /home/pwuser/.venv/bin/pip install --no-cache-dir --upgrade pip wheel \
    && echo "Install Robot Framework and testing dependencies" \
    && /home/pwuser/.venv/bin/pip install --no-cache-dir -r /tmp/requirements.txt \
    && rm /tmp/requirements.txt \
    && echo "Initialize Robot Framework Browser library (Playwright integration)" \
    && python3 -m Browser.entry init --skip-browsers

# =============================================================================
# Container Health and Monitoring
# =============================================================================
# Health check to verify Robot Framework installation and readiness
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 -c "import robot; print('Robot Framework is ready')" || exit 1

# =============================================================================
# Volume and Working Directory Configuration
# =============================================================================
# Declare volume for test reports to persist data outside container lifecycle
VOLUME ${ROBOT_REPORTS_DIR}

# Set working directory where Robot Framework will execute tests
# This is the default directory for test execution and temporary files
WORKDIR ${ROBOT_WORK_DIR}

# =============================================================================
# Container Metadata
# =============================================================================
# Add metadata labels
LABEL description="Robot Framework test environment with Playwright" \
      base-image="mcr.microsoft.com/playwright:v1.53.2-noble"

# =============================================================================
# Default Execution Command
# =============================================================================
# Default command to execute Robot Framework tests
# Parameters explained:
# - --outputdir: Directory where test reports will be generated
# - --nostatusrc: Return exit code 0 regardless of test results
# - Final argument: Path to directory containing Robot Framework test files
CMD ["robot", "--outputdir", "/opt/robotframework/reports", "--nostatusrc", "/opt/robotframework/tests"]