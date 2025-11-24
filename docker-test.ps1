# PowerShell Docker Robot Framework Test Runner
# Reads configuration from docker-config.json

param(
    [Parameter(Position=0)]
    [string]$Choice
)

# Color functions for better output
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }
function Write-Info { Write-Host $args -ForegroundColor Cyan }

# Function to find .env file in multiple locations
function Find-EnvFile {
    $searchPaths = @(
        "./TestSuites/Resources/.env",
        "./.env",
        "../.env",
        "$env:USERPROFILE/.varaamo/.env"
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            return (Resolve-Path $path).Path
        }
    }
    
    # Check if user specified a custom path
    if ($env:ENV_FILE -and (Test-Path $env:ENV_FILE)) {
        return (Resolve-Path $env:ENV_FILE).Path
    }
    
    return $null
}

# Function to validate environment variables from .env file
function Validate-EnvSecrets {
    param(
        [string]$EnvFile
    )
    
    if (-not $EnvFile -or -not (Test-Path $EnvFile)) {
        Write-Warning "[WARNING] Cannot validate secrets: .env file not found"
        return $false
    }
    
    Write-Info "Validating secrets in .env file..."
    
    $requiredVars = @("WAF_BYPASS_SECRET", "ACCESS_TOKEN", "REFRESH_TOKEN", "CLIENT_ID", "CLIENT_SECRET", "ROBOT_API_TOKEN", "DJANGO_ADMIN_PASSWORD")
    $missing = @()
    $found = @()
    
    # Read .env file with parsing
    $envContent = Get-Content $EnvFile -ErrorAction SilentlyContinue | Where-Object { 
        $_ -and $_ -notmatch '^\s*#' -and $_ -match '^\s*[^=\s]+\s*=' 
    }
    
    $envVars = @{}
    foreach ($line in $envContent) {
        if ($line -match '^\s*([^=\s]+)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            # Remove surrounding quotes if present
            if (($value.StartsWith('"') -and $value.EndsWith('"')) -or 
                ($value.StartsWith("'") -and $value.EndsWith("'"))) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            $envVars[$key] = $value
        }
    }
    
    foreach ($var in $requiredVars) {
        if ($envVars.ContainsKey($var) -and $envVars[$var]) {
            $value = $envVars[$var]
            $length = $value.Length
            if ($length -gt 8) {
                $masked = "$($value.Substring(0,3))...$($value.Substring($length-3))"
            } else {
                $masked = "***"
            }
            $found += "[OK] $var ($length chars)"
        } else {
            $missing += $var
        }
    }
    
    if ($found.Count -gt 0) {
        Write-Success "Found secrets:"
        $found | ForEach-Object { Write-Success "  $_" }
    }
    
    if ($missing.Count -gt 0) {
        Write-Warning "`nMissing secrets:"
        $missing | ForEach-Object { Write-Error "  [MISSING] $_" }
        Write-Warning "`n[WARNING] Tests requiring these secrets may fail"
        return $false
    } else {
        Write-Success "[SUCCESS] All required secrets are present"
        return $true
    }
}

# Function to load configuration from JSON
function Get-DockerConfig {
    $configFile = "docker-config.json"
    
    if (-not (Test-Path $configFile)) {
        Write-Error "Error: docker-config.json not found"
        Write-Warning "Using default values..."
        
        # Return default configuration
        return @{
            DESKTOP_PROCESSES = 8
            ADMIN_PROCESSES = 2
            MOBILE_PROCESSES = 3
            ALL_SUITES_PROCESSES = 5
            IMAGE_NAME = "robotframework-tests"
            DOCKER_ENV_FILE = "TestSuites/Resources/.env"
            ENABLE_HAR_RECORDING = "`${FALSE}"
            SUITE_USER_DESKTOP = "Tests_user_desktop_FI.robot"
            SUITE_ADMIN_DESKTOP = "Tests_admin_desktop_FI.robot"
            SUITE_ADMIN_NOTIFICATIONS = "Tests_admin_notifications_serial.robot"
            SUITE_USERS_WITH_ADMIN = "Tests_users_with_admin_desktop.robot"
            SUITE_MOBILE_ANDROID = "Tests_user_mobile_android_FI.robot"
            SUITE_MOBILE_IPHONE = "Tests_user_mobile_iphone_FI.robot"
        }
    }
    
    # Load and parse JSON
    $json = Get-Content $configFile | ConvertFrom-Json
    
    # Build configuration hashtable
    $config = @{
        DESKTOP_PROCESSES = $json.processes.desktop
        ADMIN_PROCESSES = $json.processes.admin
        MOBILE_PROCESSES = $json.processes.mobile
        ALL_SUITES_PROCESSES = $json.processes.all_suites
        IMAGE_NAME = $json.docker.image_name
        DOCKER_ENV_FILE = $json.docker.env_file
        ENABLE_HAR_RECORDING = if($json.robot_variables.enable_har_recording) { "`${TRUE}" } else { "`${FALSE}" }
        SUITE_USER_DESKTOP = $json.suites.user_desktop
        SUITE_ADMIN_DESKTOP = $json.suites.admin_desktop
        SUITE_ADMIN_NOTIFICATIONS = $json.suites.admin_notifications
        SUITE_USERS_WITH_ADMIN = $json.suites.users_with_admin
        SUITE_MOBILE_ANDROID = $json.suites.mobile_android
        SUITE_MOBILE_IPHONE = $json.suites.mobile_iphone
    }
    
    # Add path configurations with improved Windows path handling
    try {
        $TEST_DIR = (Get-Item ./TestSuites).FullName -replace '\\', '/'
        if ($TEST_DIR -match '^([A-Z]):') {
            $TEST_DIR = "/$($Matches[1].ToLower())$($TEST_DIR.Substring(2))"
        }
        
        $currentDir = (Get-Item .).FullName
        $OUTPUT_DIR = "$currentDir\output" -replace '\\', '/'
        if ($OUTPUT_DIR -match '^([A-Z]):') {
            $OUTPUT_DIR = "/$($Matches[1].ToLower())$($OUTPUT_DIR.Substring(2))"
        }
        
        $config["TEST_DIR"] = $TEST_DIR
        $config["OUTPUT_DIR"] = $OUTPUT_DIR
        
        Write-Success "Paths configured successfully:"
        Write-Info "  TEST_DIR: $TEST_DIR"
        Write-Info "  OUTPUT_DIR: $OUTPUT_DIR"
        
    } catch {
        Write-Warning "Path configuration warning: $($_.Exception.Message)"
        Write-Warning "Falling back to relative paths..."
        $config["TEST_DIR"] = "/opt/robotframework/tests"
        $config["OUTPUT_DIR"] = "/opt/robotframework/reports"
    }
    
    return $config
}

# Load configuration from JSON
Write-Success "Loading configuration from docker-config.json..."
$config = Get-DockerConfig

# Validate and set process counts with sensible defaults
function Validate-ProcessCount {
    param($value, $name, $default)
    if ($null -eq $value -or $value -lt 1 -or $value -gt 50) {
        Write-Warning "Warning: $name should be between 1-50, using default: $default"
        return $default
    }
    return $value
}

# Extract and validate configuration values
$DESKTOP_PROCESSES = Validate-ProcessCount $config["DESKTOP_PROCESSES"] "DESKTOP_PROCESSES" 8
$ADMIN_PROCESSES = Validate-ProcessCount $config["ADMIN_PROCESSES"] "ADMIN_PROCESSES" 2
$MOBILE_PROCESSES = Validate-ProcessCount $config["MOBILE_PROCESSES"] "MOBILE_PROCESSES" 3
$ALL_SUITES_PROCESSES = Validate-ProcessCount $config["ALL_SUITES_PROCESSES"] "ALL_SUITES_PROCESSES" 5

# Validate other configuration
$IMAGE_NAME = if ([string]::IsNullOrWhiteSpace($config["IMAGE_NAME"])) { 
    Write-Warning "Warning: IMAGE_NAME not set, using default: robotframework-tests"
    "robotframework-tests" 
} else { 
    $config["IMAGE_NAME"] 
}

$TEST_DIR = $config["TEST_DIR"]
$OUTPUT_DIR = $config["OUTPUT_DIR"]
$DOCKER_ENV_FILE = if ([string]::IsNullOrWhiteSpace($config["DOCKER_ENV_FILE"])) { 
    "TestSuites/Resources/.env" 
} else { 
    $config["DOCKER_ENV_FILE"] 
}

# Test suite definitions from JSON
$SUITE_USER_DESKTOP = $config["SUITE_USER_DESKTOP"]
$SUITE_ADMIN_DESKTOP = $config["SUITE_ADMIN_DESKTOP"]
$SUITE_ADMIN_NOTIFICATIONS = $config["SUITE_ADMIN_NOTIFICATIONS"]
$SUITE_USERS_WITH_ADMIN = $config["SUITE_USERS_WITH_ADMIN"]
$SUITE_MOBILE_ANDROID = $config["SUITE_MOBILE_ANDROID"]
$SUITE_MOBILE_IPHONE = $config["SUITE_MOBILE_IPHONE"]

# Function to ensure output directory exists
function Ensure-OutputDirectory {
    if (-not (Test-Path "output")) {
        Write-Info "Creating output directory..."
        New-Item -ItemType Directory -Path "output" -Force | Out-Null
    }
}

# Check Docker availability
try {
    docker --version | Out-Null
    Write-Success "Docker found"
} catch {
    Write-Error "Docker not found - please install Docker Desktop"
    exit 1
}

# env file discovery and validation
$foundEnvFile = Find-EnvFile
if ($foundEnvFile) {
    $DOCKER_ENV_FILE = $foundEnvFile
    Write-Success "Environment file found: $DOCKER_ENV_FILE"
    # Validate secrets in the .env file
    $secretValidation = Validate-EnvSecrets -EnvFile $DOCKER_ENV_FILE
} else {
    Write-Warning "[WARNING] No .env file found - tests may fail"
    Write-Info "Searched locations:"
    Write-Info "  - ./TestSuites/Resources/.env"
    Write-Info "  - ./.env"
    Write-Info "  - ../.env"
    Write-Info "  - $env:USERPROFILE/.varaamo/.env"
    if ($env:ENV_FILE) {
        Write-Info "  - $env:ENV_FILE (from ENV_FILE environment variable)"
    }
}

Write-Success "Configuration loaded successfully"
Write-Info "  Image name: $IMAGE_NAME"
Write-Info "  Desktop processes: $DESKTOP_PROCESSES"
Write-Info "  Admin processes: $ADMIN_PROCESSES"
Write-Info "  Mobile processes: $MOBILE_PROCESSES"
Write-Info "  All suites processes: $ALL_SUITES_PROCESSES"

# Function to clean output
function Clear-Output {
    Write-Warning "Cleaning output directories..."
    
    @("output", "pabot_results") | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Path "$_\*" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    
    @("log.html", "output.xml", "report.html", "playwright-log.txt") | ForEach-Object {
        if (Test-Path $_) {
            Remove-Item -Path $_ -Force -ErrorAction SilentlyContinue
        }
    }
    
    Write-Success "Output cleaned"
}

# Function to clean Docker images
function Clear-DockerImages {
    Write-Warning "Cleaning Docker images for $IMAGE_NAME..."
    
    $imageExists = docker images --format "{{.Repository}}:{{.Tag}}" | Select-String "^${IMAGE_NAME}:latest$"
    if ($imageExists) {
        Write-Info "Removing $IMAGE_NAME:latest..."
        docker image rm "${IMAGE_NAME}:latest" -f
        if ($LASTEXITCODE -eq 0) {
            Write-Success "[SUCCESS] Successfully removed $IMAGE_NAME:latest"
        } else {
            Write-Error "[FAILED] Failed to remove $IMAGE_NAME:latest (exit code: $LASTEXITCODE)"
        }
    } else {
        Write-Warning "Image $IMAGE_NAME:latest not found"
    }
    
    # Clean dangling images
    $danglingImages = docker images -f "dangling=true" -f "reference=$IMAGE_NAME" -q
    if ($danglingImages) {
        Write-Info "Removing dangling images..."
        $danglingImages | ForEach-Object { 
            docker image rm $_ -f
            if ($LASTEXITCODE -ne 0) {
                Write-Warning "[WARNING] Failed to remove dangling image: $_"
            }
        }
    }
    
    Write-Success "Docker cleanup completed"
}

# Function to build Docker image
function Build-DockerImage {
    Write-Warning "Building Docker image..."
    docker build -t "$IMAGE_NAME" .
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] Docker image built successfully"
    } else {
        Write-Error "[FAILED] Docker image build failed with exit code: $LASTEXITCODE"
        return $false
    }
    return $true
}

# Function to run tests (unified for both pabot and robot)
function Start-Test {
    param(
        [string]$TestFile,
        [string]$TaskName,
        [int]$Processes = 0,
        [bool]$Parallel = $true
    )
    
    $mode = if ($Parallel -and $Processes -gt 0) { "parallel with $Processes processes" } else { "sequential" }
    Write-Warning "Running $TaskName ($mode)..."
    
    # Validate .env file exists before running
    if (-not (Test-Path $DOCKER_ENV_FILE)) {
        Write-Error "[FAILED] .env file not found: $DOCKER_ENV_FILE"
        Write-Warning "Tests may fail without proper environment configuration"
        return $false
    }
    
    # Ensure output directory exists
    Ensure-OutputDirectory
    
    # Build Docker arguments
    $dockerArgs = @(
        "run", "--rm",
        "--env-file", $DOCKER_ENV_FILE,
        "-v", "${TEST_DIR}:/opt/robotframework/tests",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/output",
        "${IMAGE_NAME}:latest"
    )
    
    if ($Parallel -and $Processes -gt 0) {
        # Pabot parallel execution
        $dockerArgs += @(
            "pabot",
            "--testlevelsplit",
            "--processes", $Processes,
            "--pabotlib",
            "--exclude", "serialonly",
            "--resourcefile", "/opt/robotframework/tests/Resources/pabot_users.dat",
            "--variable", "ENABLE_HAR_RECORDING:$($config.ENABLE_HAR_RECORDING)",
            "--outputdir", "/opt/robotframework/reports",
            "/opt/robotframework/tests/$TestFile"
        )
    } else {
        # Robot sequential execution
        $dockerArgs += @(
            "robot",
            "--variable", "FORCE_SINGLE_USER:True",
            "--variable", "ENABLE_HAR_RECORDING:$($config.ENABLE_HAR_RECORDING)",
            "--outputdir", "/opt/robotframework/reports",
            "/opt/robotframework/tests/$TestFile"
        )
    }
    
    & docker @dockerArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] $TaskName completed successfully"
    } else {
        Write-Error "[FAILED] $TaskName failed with exit code: $LASTEXITCODE"
        Write-Warning "Check the output above for detailed error information"
        return $false
    }
    return $true
}

# Function to run all suites
function Start-AllSuites {
    param([bool]$Parallel = $true)
    
    $mode = if ($Parallel) { "parallel" } else { "sequential" }
    Write-Warning "Running all test suites in $mode..."
    
    # Validate .env file exists before running
    if (-not (Test-Path $DOCKER_ENV_FILE)) {
        Write-Error "[FAILED] .env file not found: $DOCKER_ENV_FILE"
        Write-Warning "Tests may fail without proper environment configuration"
        return $false
    }
    
    Ensure-OutputDirectory
    
    $dockerArgs = @(
        "run", "--rm",
        "--env-file", $DOCKER_ENV_FILE,
        "-v", "${TEST_DIR}:/opt/robotframework/tests",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/output",
        "${IMAGE_NAME}:latest"
    )
    
    $suites = @(
        "/opt/robotframework/tests/$SUITE_USER_DESKTOP",
        "/opt/robotframework/tests/$SUITE_ADMIN_DESKTOP",
        "/opt/robotframework/tests/$SUITE_ADMIN_NOTIFICATIONS",
        "/opt/robotframework/tests/$SUITE_USERS_WITH_ADMIN",
        "/opt/robotframework/tests/$SUITE_MOBILE_ANDROID",
        "/opt/robotframework/tests/$SUITE_MOBILE_IPHONE"
    )
    
    if ($Parallel) {
        $dockerArgs += @(
            "pabot",
            "--processes", $ALL_SUITES_PROCESSES,
            "--pabotlib",
            "--exclude", "serialonly",
            "--resourcefile", "/opt/robotframework/tests/Resources/pabot_users.dat",
            "--variable", "ENABLE_HAR_RECORDING:$($config.ENABLE_HAR_RECORDING)",
            "--outputdir", "/opt/robotframework/reports"
        ) + $suites
    } else {
        $dockerArgs += @(
            "robot",
            "--variable", "FORCE_SINGLE_USER:True",
            "--variable", "ENABLE_HAR_RECORDING:$($config.ENABLE_HAR_RECORDING)",
            "--outputdir", "/opt/robotframework/reports"
        ) + $suites
    }
    
    & docker @dockerArgs
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] All suites completed successfully"
    } else {
        Write-Error "[FAILED] All suites execution failed with exit code: $LASTEXITCODE"
        Write-Warning "Check the output above for detailed error information"
        return $false
    }
    return $true
}

# Function to toggle HAR recording setting
function Toggle-HarRecording {
    $configFile = "docker-config.json"
    
    if (-not (Test-Path $configFile)) {
        Write-Error "[FAILED] docker-config.json not found"
        return $false
    }
    
    try {
        # Read current configuration
        $json = Get-Content $configFile | ConvertFrom-Json
        
        # Toggle the HAR recording setting
        $currentState = $json.robot_variables.enable_har_recording
        $newState = -not $currentState
        $json.robot_variables.enable_har_recording = $newState
        
        # Write back to file with proper formatting
        $json | ConvertTo-Json -Depth 10 | Set-Content $configFile
        
        # Update the global config variable to reflect the change immediately
        $script:config["ENABLE_HAR_RECORDING"] = if($newState) { "`${TRUE}" } else { "`${FALSE}" }
        
        $stateText = if ($newState) { "ENABLED" } else { "DISABLED" }
        Write-Success "[SUCCESS] HAR recording is now $stateText"
        Write-Info "Setting saved to docker-config.json and updated in memory"
        
        return $true
    } catch {
        Write-Error "[FAILED] Could not toggle HAR recording: $($_.Exception.Message)"
        return $false
    }
}

# Function to run HAR analyzer in Docker
function Start-HarAnalyzer {
    Write-Warning "Running HAR file analyzer..."
    
    # Check if har_analyzer.py exists
    if (-not (Test-Path "har_analyzer.py")) {
        Write-Error "[FAILED] har_analyzer.py not found in current directory"
        return $false
    }
    
    # Check if output directory exists
    if (-not (Test-Path "output")) {
        Write-Error "[FAILED] Output directory not found. Run tests first to generate HAR files."
        return $false
    }
    
    # Get current directory for mounting the project root
    $currentDir = (Get-Item .).FullName -replace '\\', '/'
    if ($currentDir -match '^([A-Z]):') {
        $currentDir = "/$($Matches[1].ToLower())$($currentDir.Substring(2))"
    }
    
    # Build Docker arguments for HAR analysis
    $dockerArgs = @(
        "run", "--rm",
        "--env-file", $DOCKER_ENV_FILE,
        "-v", "${currentDir}:/opt/project",
        "-w", "/opt/project",
        "${IMAGE_NAME}:latest",
        "python3", "har_analyzer.py"
    )
    
    Write-Info "Executing HAR analysis..."
    & docker @dockerArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] HAR analysis completed"
    } else {
        Write-Error "[FAILED] HAR analysis failed with exit code: $LASTEXITCODE"
        return $false
    }
    return $true
}

# Function to run Python linting with Ruff
function Start-PythonLint {
    Write-Warning "Running Python linting with Ruff..."
    
    $currentDir = (Get-Item .).FullName -replace '\\', '/'
    if ($currentDir -match '^([A-Z]):') {
        $currentDir = "/$($Matches[1].ToLower())$($currentDir.Substring(2))"
    }
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${currentDir}:/opt/project",
        "-w", "/opt/project",
        "${IMAGE_NAME}:latest",
        "ruff", "check", "TestSuites/", "*.py"
    )
    
    & docker @dockerArgs | Tee-Object -FilePath "linting-ruff-report.txt"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] Python linting completed"
    } else {
        Write-Warning "[WARNING] Python linting found issues (see linting-ruff-report.txt)"
    }
    return $true
}

# Function to format Python code with Ruff
function Start-PythonFormat {
    Write-Warning "Formatting Python code with Ruff..."
    Write-Warning "This will modify your .py files"
    $confirm = Read-Host "Continue? (y/n)"
    
    if ($confirm -notmatch "^[Yy]$") {
        Write-Warning "Cancelled"
        return $false
    }
    
    $currentDir = (Get-Item .).FullName -replace '\\', '/'
    if ($currentDir -match '^([A-Z]):') {
        $currentDir = "/$($Matches[1].ToLower())$($currentDir.Substring(2))"
    }
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${currentDir}:/opt/project",
        "-w", "/opt/project",
        "${IMAGE_NAME}:latest",
        "ruff", "format", "TestSuites/", "*.py"
    )
    
    & docker @dockerArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] Python code formatted"
        Write-Info "Review changes with: git diff"
    } else {
        Write-Error "[FAILED] Formatting failed"
        return $false
    }
    return $true
}

# Function to check Python formatting with Ruff
function Start-PythonFormatCheck {
    Write-Warning "Checking Python code formatting with Ruff..."
    
    $currentDir = (Get-Item .).FullName -replace '\\', '/'
    if ($currentDir -match '^([A-Z]):') {
        $currentDir = "/$($Matches[1].ToLower())$($currentDir.Substring(2))"
    }
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${currentDir}:/opt/project",
        "-w", "/opt/project",
        "${IMAGE_NAME}:latest",
        "ruff", "format", "--check", "TestSuites/", "*.py"
    )
    
    & docker @dockerArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] Python formatting is correct"
    } else {
        Write-Warning "[WARNING] Python formatting issues found. Use the 'Format Python Code' option in the menu to auto-fix."
    }
    return $true
}

# Function to run Robot Framework linting with Robocop
function Start-RobotLint {
    Write-Warning "Running Robot Framework linting with Robocop..."
    
    $currentDir = (Get-Item .).FullName -replace '\\', '/'
    if ($currentDir -match '^([A-Z]):') {
        $currentDir = "/$($Matches[1].ToLower())$($currentDir.Substring(2))"
    }
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${currentDir}:/opt/project",
        "-w", "/opt/project",
        "${IMAGE_NAME}:latest",
        "robocop", "check", "TestSuites/", "--config", ".robocop.toml", "--reports", "rules_by_id"
    )
    
    & docker @dockerArgs | Tee-Object -FilePath "linting-robocop-report.txt"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] Robot Framework linting completed"
    } else {
        Write-Warning "[WARNING] Robot Framework linting found issues (see linting-robocop-report.txt)"
    }
    return $true
}

# Function to run Shell script linting with ShellCheck
function Start-ShellLint {
    Write-Warning "Running Shell script linting with ShellCheck..."
    
    $currentDir = (Get-Item .).FullName -replace '\\', '/'
    if ($currentDir -match '^([A-Z]):') {
        $currentDir = "/$($Matches[1].ToLower())$($currentDir.Substring(2))"
    }
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${currentDir}:/opt/project",
        "-w", "/opt/project",
        "${IMAGE_NAME}:latest",
        "shellcheck", "docker-test.sh"
    )
    
    & docker @dockerArgs | Tee-Object -FilePath "linting-shellcheck-report.txt"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] Shell script linting completed"
    } else {
        Write-Warning "[WARNING] Shell script linting found issues (see linting-shellcheck-report.txt)"
    }
    return $true
}

# Function to format Shell scripts with shfmt
function Start-ShellFormat {
    Write-Warning "Formatting Shell scripts with shfmt..."
    Write-Info "This will format shell scripts to standard style"
    Write-Host ""
    Write-Warning "This will modify your shell script files"
    $confirm = Read-Host "Continue? (y/n)"
    
    if ($confirm -notmatch "^[Yy]$") {
        Write-Warning "Cancelled"
        return $false
    }
    
    $currentDir = (Get-Item .).FullName -replace '\\', '/'
    if ($currentDir -match '^([A-Z]):') {
        $currentDir = "/$($Matches[1].ToLower())$($currentDir.Substring(2))"
    }
    
    Write-Warning "Formatting shell scripts..."
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${currentDir}:/opt/project",
        "-w", "/opt/project",
        "${IMAGE_NAME}:latest",
        "shfmt", "-w", "-i", "4", "-bn", "-sr", "docker-test.sh"
    )
    
    & docker @dockerArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] Shell scripts formatted"
        Write-Info "Review changes with: git diff"
    } else {
        Write-Error "[FAILED] Formatting failed"
        return $false
    }
    return $true
}

# Function to run all linters
function Start-AllLinters {
    Write-Warning "Running all linters..."
    Write-Host ""
    Start-PythonLint
    Write-Host ""
    Start-PythonFormatCheck
    Write-Host ""
    Start-RobotLint
    Write-Host ""
    Start-ShellLint
    Write-Host ""
    Write-Info "Linting reports saved to linting-*-report.txt"
    return $true
}

# Function to run all formatters
# Note: PowerShell formatting is intentionally excluded.
# Use editor with PowerShell formatting
function Start-AllFormatters {
    Write-Warning "Running all formatters..."
    Write-Info "This will format Python, Robot Framework, and Shell scripts"
    Write-Host ""
    Write-Warning "This will modify your files"
    $confirm = Read-Host "Continue? (y/n)"
    
    if ($confirm -notmatch "^[Yy]$") {
        Write-Warning "Cancelled"
        return $false
    }
    
    Write-Host ""
    Write-Warning "Formatting Python code..."
    Start-PythonFormat
    Write-Host ""
    Write-Warning "Formatting Robot Framework files..."
    Start-FormatRobotFiles
    Write-Host ""
    Write-Warning "Formatting Shell scripts..."
    Start-ShellFormat
    Write-Host ""
    Write-Success "[SUCCESS] All formatters completed"
    Write-Info "Review changes with: git diff"
    return $true
}

# Function to format Robot Framework files with Robocop
function Start-FormatRobotFiles {
    Write-Warning "Formatting Robot Framework files with Robocop..."
    Write-Info "This will comprehensively format your .robot files:"
    Write-Info "  • Reorder sections"
    Write-Info "  • Fix indentation and spacing"
    Write-Info "  • Sort imports/settings/variables"
    Write-Info "  • Break long lines"
    Write-Info "  • Normalize formatting"
    Write-Info "  • Normalize keyword names (library/resource names preserved)"
    Write-Host ""
    Write-Warning "This will modify your .robot files"
    $confirm = Read-Host "Continue? (y/n)"
    
    if ($confirm -notmatch "^[Yy]$") {
        Write-Warning "Cancelled"
        return $false
    }
    
    $currentDir = (Get-Item .).FullName -replace '\\', '/'
    if ($currentDir -match '^([A-Z]):') {
        $currentDir = "/$($Matches[1].ToLower())$($currentDir.Substring(2))"
    }
    
    Write-Warning "Formatting Robot Framework files..."
    
    # Use Robocop's integrated formatter (includes Robotidy functionality in 6.0+)
    # RenameKeywords is configured in .robocop.toml with ignore_library=True
    # This ensures only keyword names are normalized, not library/resource names
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${currentDir}:/opt/project",
        "-w", "/opt/project",
        "${IMAGE_NAME}:latest",
        "robocop", "format", "--overwrite", "--config", ".robocop.toml", "TestSuites/"
    )
    
    & docker @dockerArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "[SUCCESS] Robot Framework files formatted"
        Write-Info "Review changes with: git diff"
    } else {
        Write-Error "[FAILED] Formatting failed"
        return $false
    }
    return $true
}

# Main menu execution
if ($Choice) {
    switch ($Choice) {
        "1" { Clear-Output }
        "2" { Clear-DockerImages }
        "3" { Build-DockerImage }
        "4" { Start-Test -TestFile $SUITE_USER_DESKTOP -TaskName "User Desktop" -Processes $DESKTOP_PROCESSES }
        "5" { Start-Test -TestFile $SUITE_ADMIN_DESKTOP -TaskName "Admin Desktop" -Processes $ADMIN_PROCESSES }
        "6" { Start-Test -TestFile $SUITE_MOBILE_ANDROID -TaskName "Mobile Android" -Processes $MOBILE_PROCESSES }
        "7" { Start-Test -TestFile $SUITE_MOBILE_IPHONE -TaskName "Mobile iPhone" -Processes $MOBILE_PROCESSES }
        "8" { Start-Test -TestFile $SUITE_USERS_WITH_ADMIN -TaskName "Users with Admin" -Processes $ADMIN_PROCESSES }
        "9" { Start-AllSuites -Parallel $true }
        "10" { Start-Test -TestFile $SUITE_ADMIN_NOTIFICATIONS -TaskName "Admin Notifications" -Parallel $false }
        "11" { Start-Test -TestFile $SUITE_USER_DESKTOP -TaskName "User Desktop" -Parallel $false }
        "12" { Start-Test -TestFile $SUITE_ADMIN_DESKTOP -TaskName "Admin Desktop" -Parallel $false }
        "13" { Start-Test -TestFile $SUITE_MOBILE_ANDROID -TaskName "Mobile Android" -Parallel $false }
        "14" { Start-Test -TestFile $SUITE_MOBILE_IPHONE -TaskName "Mobile iPhone" -Parallel $false }
        "15" { Start-Test -TestFile $SUITE_USERS_WITH_ADMIN -TaskName "Users with Admin" -Parallel $false }
        "16" { Start-AllSuites -Parallel $false }
        "17" { Start-HarAnalyzer }
        "18" { Toggle-HarRecording }
        "19" { Start-PythonLint }
        "20" { Start-PythonFormat }
        "22" { Start-RobotLint }
        "23" { Start-ShellLint }
        "24" { Start-ShellFormat }
        "25" { Start-AllLinters }
        "26" { Start-AllFormatters }
        "27" { Start-FormatRobotFiles }
        "0" { Write-Success "Goodbye!"; exit 0 }
        default { Write-Error "Invalid choice: $Choice" }
    }
} else {
    # Interactive menu
    do {
        Write-Host ""
        Write-Host "Docker Robot Framework Test Runner" -ForegroundColor Green
        Write-Host "=================================================="
        
        # Show environment status
        if ($foundEnvFile) {
            Write-Success "Environment: [OK] .env loaded"
        } else {
            Write-Error "Environment: [MISSING] .env not found"
        }
        
        # Show HAR recording status
        $harStatus = if ($config.ENABLE_HAR_RECORDING -eq "`${TRUE}") { "[ENABLED]" } else { "[DISABLED]" }
        $harColor = if ($config.ENABLE_HAR_RECORDING -eq "`${TRUE}") { "Green" } else { "Yellow" }
        Write-Host "HAR Recording: " -NoNewline
        Write-Host $harStatus -ForegroundColor $harColor
        
        Write-Host "=================================================="
        Write-Host "1. Clean Output"
        Write-Host "2. Erase Docker Image"
        Write-Host "3. Build Docker Image"
        Write-Host ""
        Write-Host "PARALLEL (pabot) - Multiple processes" -ForegroundColor Yellow
        Write-Host "=================================================="
        Write-Host "4. $SUITE_USER_DESKTOP ($DESKTOP_PROCESSES processes)"
        Write-Host "5. $SUITE_ADMIN_DESKTOP ($ADMIN_PROCESSES processes)"
        Write-Host "6. $SUITE_MOBILE_ANDROID ($MOBILE_PROCESSES processes)"
        Write-Host "7. $SUITE_MOBILE_IPHONE ($MOBILE_PROCESSES processes)"
        Write-Host "8. $SUITE_USERS_WITH_ADMIN ($ADMIN_PROCESSES processes)"
        Write-Host "9. All Suites Parallel ($ALL_SUITES_PROCESSES processes)"
        Write-Host ""
        Write-Host "SEQUENTIAL (robot) - One process" -ForegroundColor Yellow
        Write-Host "=================================================="
        Write-Host "10. $SUITE_ADMIN_NOTIFICATIONS (sequential)"
        Write-Host "11. $SUITE_USER_DESKTOP (sequential)"
        Write-Host "12. $SUITE_ADMIN_DESKTOP (sequential)"
        Write-Host "13. $SUITE_MOBILE_ANDROID (sequential)"
        Write-Host "14. $SUITE_MOBILE_IPHONE (sequential)"
        Write-Host "15. $SUITE_USERS_WITH_ADMIN (sequential)"
        Write-Host "16. All Suites Sequential"
        Write-Host ""
        Write-Host "HAR ANALYSIS - Network Traffic Analysis" -ForegroundColor Yellow
        Write-Host "=================================================="
        Write-Host "17. Analyze HAR Files"
        Write-Host ""
        Write-Host "CONFIGURATION - Settings" -ForegroundColor Yellow
        Write-Host "=================================================="
        Write-Host "18. Toggle HAR Recording (Currently: $($harStatus))"
        Write-Host ""
        Write-Host "CODE QUALITY - Linting & Formatting" -ForegroundColor Yellow
        Write-Host "=================================================="
        Write-Host "19. Lint Python Code (Ruff)"
        Write-Host "20. Format Python Code (Ruff)"
        Write-Host "22. Lint Robot Framework Files (Robocop)"
        Write-Host "23. Lint Shell Scripts (ShellCheck)"
        Write-Host "24. Format Shell Scripts (shfmt)"
        Write-Host "25. Run All Linters"
        Write-Host "26. Run All Formatters"
        Write-Host "27. Format Robot Framework Files (Robocop - Comprehensive)"
        Write-Host ""
        Write-Host "0. Exit"
        Write-Host "=================================================="
        
        $choice = Read-Host "Select option"
        
        if ($choice -eq "0") {
            Write-Success "Goodbye!"
            break
        }
        
        & $PSCommandPath -Choice $choice
        
        # If HAR recording toggle was used, reload configuration
        if ($choice -eq "18") {
            Write-Info "Reloading configuration..."
            $script:config = Get-DockerConfig
        }
        
    } while ($true)
}