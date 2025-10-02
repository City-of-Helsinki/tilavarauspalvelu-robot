#!/bin/bash

# Docker Robot Framework Test Runner for macOS/Linux

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Configuration Loading (from docker-config.json)
# =============================================================================

# Check if jq is available for JSON parsing
if ! command -v jq &> /dev/null; then
    echo "Warning: jq not found. Installing jq is recommended for JSON parsing."
    echo "  Mac: brew install jq"
    echo "  Linux: sudo apt-get install jq"
    echo "Falling back to Python for JSON parsing..."
    
    # Use Python as fallback if jq is not available
    read_json() {
        local path="$1"
        # Convert jq path format to Python dict access
        local python_path=$(echo "$path" | sed 's/\.processes\.desktop/["processes"]["desktop"]/g' | \
                                          sed 's/\.processes\.admin/["processes"]["admin"]/g' | \
                                          sed 's/\.processes\.mobile/["processes"]["mobile"]/g' | \
                                          sed 's/\.processes\.all_suites/["processes"]["all_suites"]/g' | \
                                          sed 's/\.docker\.image_name/["docker"]["image_name"]/g' | \
                                          sed 's/\.docker\.env_file/["docker"]["env_file"]/g' | \
                                          sed 's/\.robot_variables\.enable_har_recording/["robot_variables"]["enable_har_recording"]/g' | \
                                          sed 's/\.suites\.user_desktop/["suites"]["user_desktop"]/g' | \
                                          sed 's/\.suites\.admin_desktop/["suites"]["admin_desktop"]/g' | \
                                          sed 's/\.suites\.admin_notifications/["suites"]["admin_notifications"]/g' | \
                                          sed 's/\.suites\.users_with_admin/["suites"]["users_with_admin"]/g' | \
                                          sed 's/\.suites\.mobile_android/["suites"]["mobile_android"]/g' | \
                                          sed 's/\.suites\.mobile_iphone/["suites"]["mobile_iphone"]/g')
        python3 -c "import json; cfg=json.load(open('docker-config.json')); print(cfg$python_path)"
    }
else
    # Use jq for JSON parsing
    read_json() {
        jq -r "$1" docker-config.json
    }
fi

# Read configuration from JSON file
if [ -f "docker-config.json" ]; then
    echo "Loading configuration from docker-config.json..."
    
    # Process counts
    export DESKTOP_PROCESSES=$(read_json '.processes.desktop')
    export ADMIN_PROCESSES=$(read_json '.processes.admin')
    export MOBILE_PROCESSES=$(read_json '.processes.mobile')
    export ALL_SUITES_PROCESSES=$(read_json '.processes.all_suites')
    
    # Docker configuration
    export IMAGE_NAME=$(read_json '.docker.image_name')
    export DOCKER_ENV_FILE=$(read_json '.docker.env_file')
    
    # Robot Framework variables
    ENABLE_HAR_RECORDING_JSON=$(read_json '.robot_variables.enable_har_recording')
    # Convert JSON boolean to Robot Framework boolean format
    if [ "$ENABLE_HAR_RECORDING_JSON" = "true" ]; then
        export ENABLE_HAR_RECORDING="True"
    else
        export ENABLE_HAR_RECORDING="False"
    fi
else
    echo "Warning: docker-config.json not found, using default values"
    # Fallback to default values
    export DESKTOP_PROCESSES=8
    export ADMIN_PROCESSES=2
    export MOBILE_PROCESSES=3
    export ALL_SUITES_PROCESSES=5
    export IMAGE_NAME="robotframework-tests"
    export DOCKER_ENV_FILE="TestSuites/Resources/.env"
    export ENABLE_HAR_RECORDING="False"
fi

# Set paths for Unix-like systems (macOS and Linux)
export DOCKER_PWD=$(pwd)
export TEST_DIR="$DOCKER_PWD/TestSuites"
export OUTPUT_DIR="$DOCKER_PWD/output"

# Load environment variables from .env file if it exists
if [ -f "$DOCKER_ENV_FILE" ]; then
    echo "Loading environment variables from $DOCKER_ENV_FILE..."
    while IFS= read -r line; do
        if [[ $line =~ ^(ACCESS_TOKEN|REFRESH_TOKEN|CLIENT_ID|CLIENT_SECRET|WAF_BYPASS_SECRET|ROBOT_API_TOKEN|ROBOT_API_ENDPOINT)= ]]; then
            export "$line"
        fi
    done < <(grep -v '^#' "$DOCKER_ENV_FILE")
elif [ -f .env ]; then
    echo "Loading environment variables from .env file..."
    while IFS= read -r line; do
        if [[ $line =~ ^(ACCESS_TOKEN|REFRESH_TOKEN|CLIENT_ID|CLIENT_SECRET|WAF_BYPASS_SECRET|ROBOT_API_TOKEN|ROBOT_API_ENDPOINT)= ]]; then
            export "$line"
        fi
    done < <(grep -v '^#' .env)
    export DOCKER_ENV_FILE=".env"
fi

echo "Docker configuration loaded:"
echo "  Desktop processes: $DESKTOP_PROCESSES"
echo "  Admin processes: $ADMIN_PROCESSES"
echo "  Mobile processes: $MOBILE_PROCESSES"
echo "  All suites processes: $ALL_SUITES_PROCESSES"

# Function to validate required environment variables
validate_required_vars() {
    local missing_vars=()
    local required_vars=("WAF_BYPASS_SECRET" "ROBOT_API_TOKEN")
    
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
        echo "✔ All required environment variables are set"
        return 0
    fi
}

# Function to validate and report on secrets found in .env file
validate_env_secrets() {
    if [ ! -f "$DOCKER_ENV_FILE" ]; then
        echo "⚠️  Cannot validate secrets: .env file not found at $DOCKER_ENV_FILE"
        return 1
    fi
    
    echo "Validating secrets in .env file..."
    
    local required_vars=("WAF_BYPASS_SECRET" "ACCESS_TOKEN" "REFRESH_TOKEN" "CLIENT_ID" "CLIENT_SECRET" "ROBOT_API_TOKEN")
    local missing=()
    local found=()
    
    # Read and parse .env file
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ $line =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]]; then
            continue
        fi
        
        # Parse KEY=VALUE pairs
        if [[ $line =~ ^[[:space:]]*([^=]+)=(.*)$ ]]; then
            local key="${BASH_REMATCH[1]// /}"
            local value="${BASH_REMATCH[2]}"
            
            # Remove surrounding quotes if present
            if [[ $value =~ ^[\"\'](.*)[\"\']$ ]]; then
                value="${BASH_REMATCH[1]}"
            fi
            
            # Check if this is a required variable
            for var in "${required_vars[@]}"; do
                if [[ "$key" == "$var" ]] && [[ -n "$value" ]]; then
                    local length=${#value}
                    if [[ $length -gt 8 ]]; then
                        local masked="${value:0:3}...${value: -3}"
                    else
                        local masked="***"
                    fi
                    found+=("✓ $var ($length chars)")
                    break
                fi
            done
        fi
    done < "$DOCKER_ENV_FILE"
    
    # Check for missing variables
    for var in "${required_vars[@]}"; do
        local var_found=false
        for found_var in "${found[@]}"; do
            if [[ $found_var =~ $var ]]; then
                var_found=true
                break
            fi
        done
        if [[ $var_found == false ]]; then
            missing+=("$var")
        fi
    done
    
    if [[ ${#found[@]} -gt 0 ]]; then
        echo "Found secrets:"
        for item in "${found[@]}"; do
            echo "  $item"
        done
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing secrets:"
        for var in "${missing[@]}"; do
            echo "  ✗ $var"
        done
        echo ""
        echo "⚠️  Tests requiring these secrets may fail"
        return 1
    else
        echo "✅ All required secrets are present"
        return 0
    fi
}

# Function to build Docker run arguments
get_docker_run_args() {
    local args="--env-file \"$DOCKER_ENV_FILE\""
    args="$args -v \"$TEST_DIR:/opt/robotframework/tests\""
    args="$args -v \"$OUTPUT_DIR:/opt/robotframework/reports\""
    args="$args -v \"$OUTPUT_DIR:/opt/robotframework/output\""
    echo "$args"
}

# Check if WAF_BYPASS is available
echo "Environment variables status:"
if [ -n "$WAF_BYPASS_SECRET" ]; then
    echo "  WAF_BYPASS_SECRET: ✔ loaded"
else
    echo "  WAF_BYPASS_SECRET: ⚠️  not set (tests may fail)"
fi

# Validate all required variables
validate_required_vars

# =============================================================================
# Test Functions
# =============================================================================

# Function to ensure output directory exists
ensure_output_directory() {
    if [ ! -d "output" ]; then
        echo -e "${BLUE}Creating output directory...${NC}"
        mkdir -p output
    fi
}

# Test suite path definitions (from JSON if available)
if [ -f "docker-config.json" ]; then
    SUITE_USER_DESKTOP=$(read_json '.suites.user_desktop')
    SUITE_ADMIN_DESKTOP=$(read_json '.suites.admin_desktop')
    SUITE_ADMIN_NOTIFICATIONS=$(read_json '.suites.admin_notifications')
    SUITE_USERS_WITH_ADMIN=$(read_json '.suites.users_with_admin')
    SUITE_MOBILE_ANDROID=$(read_json '.suites.mobile_android')
    SUITE_MOBILE_IPHONE=$(read_json '.suites.mobile_iphone')
else
    # Fallback values
    SUITE_USER_DESKTOP="Tests_user_desktop_FI.robot"
    SUITE_ADMIN_DESKTOP="Tests_admin_desktop_FI.robot"
    SUITE_ADMIN_NOTIFICATIONS="Tests_admin_notifications_serial.robot"
    SUITE_USERS_WITH_ADMIN="Tests_users_with_admin_desktop.robot"
    SUITE_MOBILE_ANDROID="Tests_user_mobile_android_FI.robot"
    SUITE_MOBILE_IPHONE="Tests_user_mobile_iphone_FI.robot"
fi

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
    
    # Validate environment before building
    if ! validate_env_secrets; then
        echo -e "${YELLOW}⚠️  Building without all secrets - some tests may fail${NC}"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${RED}Build cancelled${NC}"
            return 1
        fi
    fi
    
    docker build -t $IMAGE_NAME .
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Docker image built successfully${NC}"
    else
        echo -e "${RED}❌ Docker build failed${NC}"
        return 1
    fi
}

# Function to run pabot tests
run_pabot() {
    local processes=$1
    local test_file=$2
    local task_name=$3
    
    echo -e "${YELLOW}🚀 Running $task_name with $processes processes...${NC}"
    
    # Ensure output directory exists
    ensure_output_directory
    
    # Get Docker run arguments with proper .env handling
    local docker_args=$(get_docker_run_args)
    
    # Build the complete Docker command
    local docker_cmd="docker run --rm $docker_args $IMAGE_NAME:latest"
    
    # Add pabot command
    docker_cmd="$docker_cmd pabot \
        --testlevelsplit \
        --processes $processes \
        --pabotlib \
        --exclude serialonly \
        --resourcefile /opt/robotframework/tests/Resources/test_value_sets.dat \
        --variable ENABLE_HAR_RECORDING:$ENABLE_HAR_RECORDING \
        --outputdir /opt/robotframework/reports \
        /opt/robotframework/tests/$test_file"
    
    # Show the command being executed (for debugging)
    echo -e "${BLUE}Executing Docker command:${NC}"
    echo "$docker_cmd" | sed 's/ -/\n  -/g'
    echo ""
    
    eval $docker_cmd
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $task_name completed successfully${NC}"
    else
        echo -e "${RED}❌ $task_name failed${NC}"
        return 1
    fi
}

# Function to run robot tests (sequential)
run_robot() {
    local test_file=$1
    local task_name=$2
    
    echo -e "${YELLOW}🚀 Running $task_name (sequential)...${NC}"
    
    # Ensure output directory exists
    ensure_output_directory
    
    # Get Docker run arguments with proper .env handling
    local docker_args=$(get_docker_run_args)
    
    # Build the complete Docker command
    local docker_cmd="docker run --rm $docker_args $IMAGE_NAME:latest"
    
    # Add robot command
    docker_cmd="$docker_cmd robot \
        --variable FORCE_SINGLE_USER:True \
        --variable ENABLE_HAR_RECORDING:$ENABLE_HAR_RECORDING \
        --outputdir /opt/robotframework/reports \
        /opt/robotframework/tests/$test_file"
    
    # Show the command being executed (for debugging)
    echo -e "${BLUE}Executing Docker command:${NC}"
    echo "$docker_cmd" | sed 's/ -/\n  -/g'
    echo ""
    
    eval $docker_cmd
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ $task_name completed successfully${NC}"
    else
        echo -e "${RED}❌ $task_name failed${NC}"
        return 1
    fi
}

# Function to run all suites in parallel with proper .env handling
run_all_suites() {
    echo -e "${YELLOW}🚀 Running all test suites in parallel...${NC}"
    
    ensure_output_directory
    
    # Get Docker run arguments
    local docker_args=$(get_docker_run_args)
    
    # Build the complete Docker command
    local docker_cmd="docker run --rm $docker_args $IMAGE_NAME:latest"
    
    docker_cmd="$docker_cmd pabot \
        --processes $ALL_SUITES_PROCESSES \
        --pabotlib \
        --exclude serialonly \
        --resourcefile /opt/robotframework/tests/Resources/test_value_sets.dat \
        --variable ENABLE_HAR_RECORDING:$ENABLE_HAR_RECORDING \
        --outputdir /opt/robotframework/reports \
        /opt/robotframework/tests/$SUITE_USER_DESKTOP \
        /opt/robotframework/tests/$SUITE_ADMIN_DESKTOP \
        /opt/robotframework/tests/$SUITE_ADMIN_NOTIFICATIONS \
        /opt/robotframework/tests/$SUITE_USERS_WITH_ADMIN \
        /opt/robotframework/tests/$SUITE_MOBILE_ANDROID \
        /opt/robotframework/tests/$SUITE_MOBILE_IPHONE"
    
    echo -e "${BLUE}Executing Docker command:${NC}"
    echo "$docker_cmd" | sed 's/ -/\n  -/g'
    echo ""
    
    eval $docker_cmd
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ All suites completed successfully${NC}"
    else
        echo -e "${RED}❌ Some suites failed${NC}"
        return 1
    fi
}

# Function to run all suites sequentially
run_all_suites_sequential() {
    echo -e "${YELLOW}🚀 Running all test suites sequentially...${NC}"
    
    ensure_output_directory
    
    # Get Docker run arguments
    local docker_args=$(get_docker_run_args)
    
    # Build the complete Docker command
    local docker_cmd="docker run --rm $docker_args $IMAGE_NAME:latest"
    
    docker_cmd="$docker_cmd robot \
        --variable FORCE_SINGLE_USER:True \
        --variable ENABLE_HAR_RECORDING:$ENABLE_HAR_RECORDING \
        --outputdir /opt/robotframework/reports \
        /opt/robotframework/tests/$SUITE_USER_DESKTOP \
        /opt/robotframework/tests/$SUITE_ADMIN_DESKTOP \
        /opt/robotframework/tests/$SUITE_ADMIN_NOTIFICATIONS \
        /opt/robotframework/tests/$SUITE_USERS_WITH_ADMIN \
        /opt/robotframework/tests/$SUITE_MOBILE_ANDROID \
        /opt/robotframework/tests/$SUITE_MOBILE_IPHONE"
    
    echo -e "${BLUE}Executing Docker command:${NC}"
    echo "$docker_cmd" | sed 's/ -/\n  -/g'
    echo ""
    
    eval $docker_cmd
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ All suites completed sequentially${NC}"
    else
        echo -e "${RED}❌ Some suites failed${NC}"
        return 1
    fi
}

# Function to toggle HAR recording setting
toggle_har_recording() {
    local config_file="docker-config.json"
    
    if [ ! -f "$config_file" ]; then
        echo -e "${RED}❌ docker-config.json not found${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}🔄 Toggling HAR recording setting...${NC}"
    
    # Read current state
    local current_state
    if command -v jq &> /dev/null; then
        current_state=$(jq -r '.robot_variables.enable_har_recording' "$config_file")
    else
        current_state=$(python3 -c "import json; cfg=json.load(open('$config_file')); print(str(cfg['robot_variables']['enable_har_recording']).lower())")
    fi
    
    # Toggle the state
    local new_state
    if [ "$current_state" = "true" ]; then
        new_state="false"
    else
        new_state="true"
    fi
    
    # Update the JSON file
    if command -v jq &> /dev/null; then
        # Use jq for clean JSON formatting
        jq ".robot_variables.enable_har_recording = $new_state" "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
    else
        # Use Python as fallback
        python3 -c "
import json
with open('$config_file', 'r') as f:
    cfg = json.load(f)
cfg['robot_variables']['enable_har_recording'] = $new_state
with open('$config_file', 'w') as f:
    json.dump(cfg, f, indent=2)
"
    fi
    
    if [ $? -eq 0 ]; then
        local state_text
        if [ "$new_state" = "true" ]; then
            state_text="ENABLED"
            export ENABLE_HAR_RECORDING="True"
        else
            state_text="DISABLED"
            export ENABLE_HAR_RECORDING="False"
        fi
        echo -e "${GREEN}✅ HAR recording is now $state_text${NC}"
        echo -e "${BLUE}Setting saved to docker-config.json and updated in memory${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to toggle HAR recording${NC}"
        return 1
    fi
}

# Function to run HAR analyzer in Docker
run_har_analyzer() {
    echo -e "${YELLOW}📊 Running HAR file analyzer...${NC}"
    
    # Check if har_analyzer.py exists
    if [ ! -f "har_analyzer.py" ]; then
        echo -e "${RED}❌ har_analyzer.py not found in current directory${NC}"
        return 1
    fi
    
    # Check if output directory exists
    if [ ! -d "output" ]; then
        echo -e "${RED}❌ Output directory not found. Run tests first to generate HAR files.${NC}"
        return 1
    fi
    
    # Get Docker run arguments
    local docker_args=$(get_docker_run_args)
    
    # Build the complete Docker command for HAR analysis
    # Mount both the project root (for har_analyzer.py) and output directory
    local docker_cmd="docker run --rm $docker_args \
        -v \"$DOCKER_PWD:/opt/project\" \
        -w /opt/project \
        $IMAGE_NAME:latest \
        python3 har_analyzer.py"
    
    echo -e "${BLUE}Executing HAR analysis:${NC}"
    echo "$docker_cmd"
    echo ""
    
    eval $docker_cmd
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ HAR analysis completed${NC}"
    else
        echo -e "${RED}❌ HAR analysis failed${NC}"
        return 1
    fi
}

# Function to execute menu option
execute_option() {
    local choice=$1
    case $choice in
        1) clean_output ;;
        2) clean_docker ;;
        3) build_docker ;;
        4) run_pabot $DESKTOP_PROCESSES "$SUITE_USER_DESKTOP" "User Desktop Parallel" ;;
        5) run_pabot $ADMIN_PROCESSES "$SUITE_ADMIN_DESKTOP" "Admin Desktop Parallel" ;;
        6) run_pabot $MOBILE_PROCESSES "$SUITE_MOBILE_ANDROID" "Mobile Android Parallel" ;;
        7) run_pabot $MOBILE_PROCESSES "$SUITE_MOBILE_IPHONE" "Mobile iPhone Parallel" ;;
        8) run_pabot $ADMIN_PROCESSES "$SUITE_USERS_WITH_ADMIN" "Users with Admin Parallel" ;;
        9) run_all_suites ;;
        10) run_robot "$SUITE_ADMIN_NOTIFICATIONS" "Admin Notifications Serial" ;;
        11) run_robot "$SUITE_USER_DESKTOP" "User Desktop Single" ;;
        12) run_robot "$SUITE_ADMIN_DESKTOP" "Admin Desktop Single" ;;
        13) run_robot "$SUITE_MOBILE_ANDROID" "Mobile Android Single" ;;
        14) run_robot "$SUITE_MOBILE_IPHONE" "Mobile iPhone Single" ;;
        15) run_robot "$SUITE_USERS_WITH_ADMIN" "Users with Admin Single" ;;
        16) run_all_suites_sequential ;;
        17) run_har_analyzer ;;
        18) toggle_har_recording ;;
        0) echo -e "${GREEN}👋 Goodbye!${NC}" && exit 0 ;;
        *) echo -e "${RED}❌ Invalid option: $choice${NC}" && exit 1 ;;
    esac
}

# Main menu
show_menu() {
    echo -e "${GREEN}🤖 Docker Robot Framework Test Runner${NC}"
    echo "=================================================="
    
    # Show environment status
    if [ -n "$DOCKER_ENV_FILE" ]; then
        echo -e "Environment: ${GREEN}✅ .env loaded${NC}"
    else
        echo -e "Environment: ${RED}❌ .env not found${NC}"
    fi
    
    # Show HAR recording status
    local har_status
    local har_color
    if [ "$ENABLE_HAR_RECORDING" = "True" ]; then
        har_status="[ENABLED]"
        har_color="${GREEN}"
    else
        har_status="[DISABLED]"
        har_color="${YELLOW}"
    fi
    echo -e "HAR Recording: ${har_color}$har_status${NC}"
    
    echo "=================================================="
    echo "1. Clean Output"
    echo "2. Erase Docker Image"
    echo "3. Build Docker Image"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ 🚀 PARALLEL EXECUTION (pabot) - Multiple proc║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════╝${NC}"
    echo "4. $SUITE_USER_DESKTOP ($DESKTOP_PROCESSES processes)"
    echo "5. $SUITE_ADMIN_DESKTOP ($ADMIN_PROCESSES processes)"
    echo "6. $SUITE_MOBILE_ANDROID ($MOBILE_PROCESSES processes)"
    echo "7. $SUITE_MOBILE_IPHONE ($MOBILE_PROCESSES processes)"
    echo "8. $SUITE_USERS_WITH_ADMIN ($ADMIN_PROCESSES processes)"
    echo "9. All Suites Parallel ($ALL_SUITES_PROCESSES processes)"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ 🌐 SEQUENTIAL EXECUTION (robot) - One process║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════╝${NC}"
    echo "10. $SUITE_ADMIN_NOTIFICATIONS (sequential)"
    echo "11. $SUITE_USER_DESKTOP (sequential)"
    echo "12. $SUITE_ADMIN_DESKTOP (sequential)"
    echo "13. $SUITE_MOBILE_ANDROID (sequential)"
    echo "14. $SUITE_MOBILE_IPHONE (sequential)"
    echo "15. $SUITE_USERS_WITH_ADMIN (sequential)"
    echo "16. All Suites Sequential"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ 📊 HAR ANALYSIS - Network Traffic Analysis   ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════╝${NC}"
    echo "17. Analyze HAR Files"
    echo ""
    echo -e "${YELLOW}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${YELLOW}║ ⚙️  CONFIGURATION - Settings                  ║${NC}"
    echo -e "${YELLOW}╚══════════════════════════════════════════════╝${NC}"
    echo "18. Toggle HAR Recording (Currently: $har_status)"
    echo ""
    echo "0. Exit"
    echo "=================================================="
}

# Function to reload configuration from JSON
reload_config() {
    if [ -f "docker-config.json" ]; then
        # Reload HAR recording setting
        ENABLE_HAR_RECORDING_JSON=$(read_json '.robot_variables.enable_har_recording')
        if [ "$ENABLE_HAR_RECORDING_JSON" = "true" ]; then
            export ENABLE_HAR_RECORDING="True"
        else
            export ENABLE_HAR_RECORDING="False"
        fi
        echo -e "${BLUE}Configuration reloaded${NC}"
    fi
}

# Main execution
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Select option: " choice
        
        if [ "$choice" = "0" ]; then
            echo -e "${GREEN}👋 Goodbye!${NC}"
            exit 0
        fi
        
        execute_option $choice
        
        # If HAR recording toggle was used, reload configuration for menu display
        if [ "$choice" = "18" ]; then
            reload_config
        fi
    done
else
    # Argument provided - execute directly
    execute_option $1
fi
