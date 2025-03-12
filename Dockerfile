# Use Microsoft's Playwright image (already includes Python & Node.js)
FROM mcr.microsoft.com/playwright:v1.50.0-noble

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    LANG=fi_FI.UTF-8 \
    LC_ALL=fi_FI.UTF-8 \
    ROBOT_UID=1000 \
    ROBOT_GID=1000 \
    ROBOT_DEPENDENCY_DIR=/opt/robotframework/dependencies \
    ROBOT_REPORTS_DIR=/opt/robotframework/reports \
    ROBOT_TESTS_DIR=/opt/robotframework/tests \
    ROBOT_WORK_DIR=/opt/robotframework/temp \
    CLEANED_EMAILS_PATH=/opt/robotframework/tests/Resources/downloads/cleaned_emails.json \
    SCREEN_COLOUR_DEPTH=24 \
    SCREEN_HEIGHT=1080 \
    SCREEN_WIDTH=1920 \
    ROBOT_THREADS=1 \
    PATH="/home/pwuser/.venv/bin:$PATH"

# Switch to root for package installation
USER root

# Update apt and install system packages needed for Robot Framework
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    curl \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgtk-3-0t64 \
    libasound2t64 \
    python3-tk \
    locales && \
    echo "fi_FI.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p ${ROBOT_REPORTS_DIR} \
    ${ROBOT_WORK_DIR} \
    ${ROBOT_DEPENDENCY_DIR} \
    /opt/robotframework/tests/Resources/downloads && \
    touch /opt/robotframework/tests/Resources/downloads/cleaned_emails.json && \
    chown -R pwuser:pwuser ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR} ${ROBOT_DEPENDENCY_DIR} /opt/robotframework/tests/Resources/downloads && \
    chmod -R 777 ${ROBOT_REPORTS_DIR} ${ROBOT_WORK_DIR} ${ROBOT_DEPENDENCY_DIR} /opt/robotframework/tests/Resources/downloads && \
    chmod ugo+w /var/log && chown pwuser:pwuser /var/log

# Switch to non-root user
USER pwuser

# Set up Python environment and install dependencies
RUN python3 -m venv /home/pwuser/.venv && \
    /home/pwuser/.venv/bin/pip install --no-cache-dir --upgrade pip wheel && \
    /home/pwuser/.venv/bin/pip install --no-cache-dir --upgrade \
    robotframework==7.2 \
    robotframework-browser==19.3.0 \
    python-dotenv==1.0.1 \
    google-auth==2.38.0 \
    google-auth-oauthlib==1.2.1 \
    beautifulsoup4==4.13.3

# Initialize Browser library
RUN python3 -m Browser.entry init --skip-browsers

# Declare a volume for reports so that they persist
VOLUME ${ROBOT_REPORTS_DIR}

# Set working directory
WORKDIR ${ROBOT_WORK_DIR}

# Default command to run Robot Framework tests
CMD ["robot", "--outputdir", "/opt/robotframework/reports", "--nostatusrc", "/opt/robotframework/tests"]