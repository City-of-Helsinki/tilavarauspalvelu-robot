#!/bin/bash

# Docker Robot Framework Test Runner

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Source shared configuration
source ./docker-config.sh

# Test suite path definitions
SUITE_USER_DESKTOP="Tests_user_desktop_FI.robot"
SUITE_ADMIN_DESKTOP="Tests_admin_desktop_FI.robot"
SUITE_ADMIN_NOTIFICATIONS="Tests_admin_notifications_serial.robot"
SUITE_USERS_WITH_ADMIN="Tests_users_with_admin_desktop.robot"
SUITE_MOBILE_ANDROID="Tests_user_mobile_android_FI.robot"
SUITE_MOBILE_IPHONE="Tests_user_mobile_iphone_FI.robot"

# Function to clean output
clean_output() {
    echo -e "${YELLOW}🧹 Cleaning output directories...${NC}"
    [ -d output ] && rm -rf output/* || true
    [ -d pabot_results ] && rm -rf pabot_results/* || true
    [ -f log.html ] && rm -f log.html || true
    [ -f output.xml ] && rm -f output.xml || true
    [ -f report.html ] && rm -f report.html || true
    [ -f playwright-log.txt ] && rm -f playwright-log.txt || true
    echo -e "${GREEN}✅ Output cleaned${NC}"
}

# Function to clean latest Docker images
clean_docker() {
    echo -e "${YELLOW}🗑️  Cleaning Docker images for $IMAGE_NAME...${NC}"
    
    # Check if the specific image exists and remove it
    if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$IMAGE_NAME:latest$"; then
        if docker image rm $IMAGE_NAME:latest -f 2>/dev/null; then
            echo -e "${GREEN}✅ Removed $IMAGE_NAME:latest${NC}"
        else
            echo -e "${RED}❌ Failed to remove $IMAGE_NAME:latest${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Image $IMAGE_NAME:latest not found${NC}"
    fi
    
    # Clean up dangling images for this specific image
    local dangling_images=$(docker images -f "dangling=true" -f "reference=$IMAGE_NAME" -q)
    if [ -n "$dangling_images" ]; then
        if echo "$dangling_images" | xargs docker image rm -f 2>/dev/null; then
            echo -e "${GREEN}✅ Removed dangling $IMAGE_NAME images${NC}"
        else
            echo -e "${YELLOW}⚠️  No dangling $IMAGE_NAME images to remove${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  No dangling $IMAGE_NAME images found${NC}"
    fi
    
    echo -e "${GREEN}✅ Docker cleanup completed safely${NC}"
}

# Function to build Docker image
build_docker() {
    echo -e "${YELLOW}🔨 Building Docker image...${NC}"
    docker build -t $IMAGE_NAME .
    echo -e "${GREEN}✅ Docker image built${NC}"
}

# Function to run pabot tests
run_pabot() {
    local processes=$1
    local test_file=$2
    local task_name=$3
    
    echo -e "${YELLOW}🚀 Running $task_name with $processes processes...${NC}"
    
    docker run --rm \
        --env-file "$DOCKER_ENV_FILE" \
        -v "$TEST_DIR:/opt/robotframework/tests" \
        -v "$OUTPUT_DIR:/opt/robotframework/reports" \
        -v "$OUTPUT_DIR:/opt/robotframework/output" \
        $IMAGE_NAME:latest pabot \
        --testlevelsplit \
        --processes $processes \
        --pabotlib \
        --exclude serialonly \
        --resourcefile /opt/robotframework/tests/Resources/test_value_sets.dat \
        --outputdir /opt/robotframework/reports \
        /opt/robotframework/tests/$test_file
    
    echo -e "${GREEN}✅ $task_name completed${NC}"
}

# Function to run robot tests (sequential)
run_robot() {
    local test_file=$1
    local task_name=$2
    
    echo -e "${YELLOW}🚀 Running $task_name (sequential)...${NC}"
    
    docker run --rm \
        --env-file "$DOCKER_ENV_FILE" \
        -v "$TEST_DIR:/opt/robotframework/tests" \
        -v "$OUTPUT_DIR:/opt/robotframework/reports" \
        -v "$OUTPUT_DIR:/opt/robotframework/output" \
        $IMAGE_NAME:latest robot \
        --variable FORCE_SINGLE_USER:True \
        --outputdir /opt/robotframework/reports \
        /opt/robotframework/tests/$test_file
    
    echo -e "${GREEN}✅ $task_name completed${NC}"
}

# Function to run all suites in parallel
run_all_suites() {
    echo -e "${YELLOW}🚀 Running all test suites in parallel...${NC}"
    
    docker run --rm \
        --env-file "$DOCKER_ENV_FILE" \
        -v "$TEST_DIR:/opt/robotframework/tests" \
        -v "$OUTPUT_DIR:/opt/robotframework/reports" \
        -v "$OUTPUT_DIR:/opt/robotframework/output" \
        $IMAGE_NAME:latest pabot \
        --processes $ALL_SUITES_PROCESSES \
        --pabotlib \
        --exclude serialonly \
        --resourcefile /opt/robotframework/tests/Resources/test_value_sets.dat \
        --outputdir /opt/robotframework/reports \
        /opt/robotframework/tests/$SUITE_USER_DESKTOP \
        /opt/robotframework/tests/$SUITE_ADMIN_DESKTOP \
        /opt/robotframework/tests/$SUITE_ADMIN_NOTIFICATIONS \
        /opt/robotframework/tests/$SUITE_USERS_WITH_ADMIN \
        /opt/robotframework/tests/$SUITE_MOBILE_ANDROID \
        /opt/robotframework/tests/$SUITE_MOBILE_IPHONE
    
    echo -e "${GREEN}✅ All suites completed${NC}"
}

# Function to run all suites sequentially
run_all_suites_sequential() {
    echo -e "${YELLOW}🚀 Running all test suites sequentially...${NC}"
    
    docker run --rm \
        --env-file "$DOCKER_ENV_FILE" \
        -v "$TEST_DIR:/opt/robotframework/tests" \
        -v "$OUTPUT_DIR:/opt/robotframework/reports" \
        -v "$OUTPUT_DIR:/opt/robotframework/output" \
        $IMAGE_NAME:latest robot \
        --variable FORCE_SINGLE_USER:True \
        --outputdir /opt/robotframework/reports \
        /opt/robotframework/tests/$SUITE_USER_DESKTOP \
        /opt/robotframework/tests/$SUITE_ADMIN_DESKTOP \
        /opt/robotframework/tests/$SUITE_ADMIN_NOTIFICATIONS \
        /opt/robotframework/tests/$SUITE_USERS_WITH_ADMIN \
        /opt/robotframework/tests/$SUITE_MOBILE_ANDROID \
        /opt/robotframework/tests/$SUITE_MOBILE_IPHONE
    
    echo -e "${GREEN}✅ All suites completed sequentially${NC}"
}

# Function to execute option by number
execute_option() {
    local choice=$1
    case $choice in
        1) clean_output ;;
        2) clean_docker ;;
        3) build_docker ;;
        4) run_pabot $DESKTOP_PROCESSES "$SUITE_USER_DESKTOP" "User Desktop Parallel" ;;
        5) run_pabot $ADMIN_PROCESSES "$SUITE_ADMIN_DESKTOP" "Admin Desktop Parallel" ;;
        6) run_robot "$SUITE_ADMIN_NOTIFICATIONS" "Admin Notifications Serial" ;;
        7) run_pabot $MOBILE_PROCESSES "$SUITE_MOBILE_ANDROID" "Mobile Android Parallel" ;;
        8) run_pabot $MOBILE_PROCESSES "$SUITE_MOBILE_IPHONE" "Mobile iPhone Parallel" ;;
        9) run_pabot $ADMIN_PROCESSES "$SUITE_USERS_WITH_ADMIN" "Users with Admin Parallel" ;;
        10) run_all_suites ;;
        11) run_robot "$SUITE_USER_DESKTOP" "User Desktop Single" ;;
        12) run_robot "$SUITE_ADMIN_DESKTOP" "Admin Desktop Single" ;;
        13) run_robot "$SUITE_MOBILE_ANDROID" "Mobile Android Single" ;;
        14) run_robot "$SUITE_MOBILE_IPHONE" "Mobile iPhone Single" ;;
        15) run_robot "$SUITE_USERS_WITH_ADMIN" "Users with Admin Single" ;;
        16) run_all_suites_sequential ;;
        0) echo -e "${GREEN}👋 Goodbye!${NC}" && exit 0 ;;
        *) echo -e "${RED}❌ Invalid option: $choice${NC}" && exit 1 ;;
    esac
}

# Main menu
show_menu() {
    echo -e "${GREEN}🤖 Docker Robot Framework Test Runner${NC}"
    echo "=================================================="
    echo "1. Clean Output"
    echo "2. Erase Docker Image"
    echo "3. Build Docker Image"
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}🚀 PARALLEL EXECUTION (pabot) - Multiple processes${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo "4. Tests_user_desktop_FI ($DESKTOP_PROCESSES processes)"
    echo "5. Tests_admin_desktop_FI ($ADMIN_PROCESSES processes)"
    echo "7. Tests_user_mobile_android_FI ($MOBILE_PROCESSES processes)"
    echo "8. Tests_user_mobile_iphone_FI ($MOBILE_PROCESSES processes)"
    echo "9. Tests_users_with_admin_desktop ($ADMIN_PROCESSES processes)"
    echo "10. All Suites Parallel ($ALL_SUITES_PROCESSES processes)"
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}🐌 SINGLE/SEQUENTIAL EXECUTION (robot) - One process${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════════${NC}"
    echo "6. Tests_admin_notifications_serial (sequential)"
    echo "11. Tests_user_desktop_FI (sequential)"
    echo "12. Tests_admin_desktop_FI (sequential)"
    echo "13. Tests_user_mobile_android_FI (sequential)"
    echo "14. Tests_user_mobile_iphone_FI (sequential)"
    echo "15. Tests_users_with_admin_desktop (sequential)"
    echo "16. All Suites Sequential"
    echo ""
    echo "0. Exit"
    echo "=================================================="
}

# Main execution
if [ $# -eq 0 ]; then
    # No arguments - show interactive menu
    show_menu
    read -p "Select option: " choice
    execute_option $choice
else
    # Argument provided - execute directly
    execute_option $1
fi
