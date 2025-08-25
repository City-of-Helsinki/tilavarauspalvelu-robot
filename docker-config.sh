#!/bin/bash

# Shared Docker configuration for Robot Framework tests
# This file is sourced by both docker-test.sh and can be referenced in docker-tasks.yaml

# Detect OS and set paths accordingly for cross-platform compatibility
case "$OSTYPE" in
    msys*|cygwin*|mingw*)
        # Windows (Git Bash, MSYS2, Cygwin)
        ENV_FILE="TestSuites\\Resources\\.env"
        ENV_FILE_UNIX="TestSuites/Resources/.env"  # For file existence check
        DOCKER_ENV_FILE="TestSuites/Resources/.env"  # Docker always uses Unix paths
        # Convert Windows path to Docker-compatible format
        DOCKER_PWD=$(pwd -W 2>/dev/null || pwd | sed 's|^/c|/c|')
        ;;
    *)
        # Linux, macOS, and other Unix-like systems
        ENV_FILE="TestSuites/Resources/.env"
        ENV_FILE_UNIX="TestSuites/Resources/.env"
        DOCKER_ENV_FILE="TestSuites/Resources/.env"
        DOCKER_PWD=$(pwd)
        ;;
esac

# Export Docker variables for use in docker commands
export DOCKER_ENV_FILE
export DOCKER_PWD

# Load environment variables from .env file if it exists
if [ -f "$ENV_FILE_UNIX" ]; then
    echo "Loading environment variables from $ENV_FILE_UNIX file..."
    while IFS= read -r line; do
        if [[ $line =~ ^(ACCESS_TOKEN|REFRESH_TOKEN|CLIENT_ID|CLIENT_SECRET|WAF_BYPASS_SECRET)= ]]; then
            export "$line"
        fi
    done < <(grep -v '^#' "$ENV_FILE_UNIX")
elif [ -f .env ]; then
    echo "Loading environment variables from .env file..."
    while IFS= read -r line; do
        if [[ $line =~ ^(ACCESS_TOKEN|REFRESH_TOKEN|CLIENT_ID|CLIENT_SECRET|WAF_BYPASS_SECRET)= ]]; then
            export "$line"
        fi
    done < <(grep -v '^#' .env)
    export DOCKER_ENV_FILE=".env"
fi

# Process count configuration - Change these values to update all references
export DESKTOP_PROCESSES=8
export ADMIN_PROCESSES=2
export MOBILE_PROCESSES=3
export ALL_SUITES_PROCESSES=5

# Docker configuration
export IMAGE_NAME="robotframework-tests"
export TEST_DIR="$DOCKER_PWD/TestSuites"
export OUTPUT_DIR="$DOCKER_PWD/output"

echo "Docker configuration loaded:"
echo "  Desktop processes: $DESKTOP_PROCESSES"
echo "  Admin processes: $ADMIN_PROCESSES"
echo "  Mobile processes: $MOBILE_PROCESSES"
echo "  All suites processes: $ALL_SUITES_PROCESSES"

# Function to validate required environment variables
validate_required_vars() {
    local missing_vars=()
    local required_vars=("WAF_BYPASS_SECRET")
    
    for var in "${required_vars[@]}"; do
        if [ -z "${!var}" ]; then
            missing_vars+=("$var")
        fi
    done
    
    if [ ${#missing_vars[@]} -gt 0 ]; then
        echo "⚠️  WARNING: Missing required environment variables:"
        for var in "${missing_vars[@]}"; do
            echo "    - $var"
        done
        echo "  Tests may fail without these variables set in $DOCKER_ENV_FILE"
        return 1
    else
        echo "✓ All required environment variables are set"
        return 0
    fi
}

# Check if secrets are available
echo "Environment variables status:"
if [ -n "$WAF_BYPASS_SECRET" ]; then
    echo "  WAF_BYPASS_SECRET: ✓ loaded"
else
    echo "  WAF_BYPASS_SECRET: ⚠️  not set (tests may fail)"
fi

# Validate all required variables
validate_required_vars
