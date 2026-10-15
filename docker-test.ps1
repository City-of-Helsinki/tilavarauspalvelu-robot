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
    
    $requiredVars = @("WAF_BYPASS_SECRET", "ROBOT_API_TOKEN", "DJANGO_ADMIN_PASSWORD")
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
        Write-Error "[FAILED] docker-config.json not found"
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
            RERUN_FAILED_TESTS = $true
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
        # Rerun failed tests at the end of a run (enabled unless explicitly set to false)
        RERUN_FAILED_TESTS = ($json.execution.rerun_failed_tests -ne $false)
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
$RERUN_FAILED_TESTS = $config["RERUN_FAILED_TESTS"]

# Function to ensure output directory exists
function Ensure-OutputDirectory {
    if (-not (Test-Path "output")) {
        Write-Info "Creating output directory..."
        New-Item -ItemType Directory -Path "output" -Force | Out-Null
    }
}

# Function to validate Docker image exists
function Test-DockerImage {
    $imageExists = docker images --format "{{.Repository}}:{{.Tag}}" | Select-String "^${IMAGE_NAME}:latest$"
    if (-not $imageExists) {
        Write-Error "[FAILED] Docker image '$IMAGE_NAME:latest' not found"
        Write-Warning "Please build the image first"
        return $false
    }
    return $true
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
Write-Info "  Rerun failed tests: $RERUN_FAILED_TESTS"

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
            Write-Success "[SUCCESS] Removed $IMAGE_NAME:latest"
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

# Function to remove results of a previous run, so that a run that fails before writing its output
# is not mistaken for the previous run (or its failed tests rerun)
function Clear-PreviousResults {
    @("output\rerun", "output\first-run-*", "output\*merged-output.xml",
        "output\output.xml", "output\parallel-output.xml", "output\notifications-output.xml") | ForEach-Object {
        Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Skipped tests are handled like failed tests: they are rerun and they fail the run.
# A test is skipped when a test it needs has failed, e.g. "Check emails from reservations"
# is skipped when "User can make paid single booking" fails.

# Function to count failed and skipped tests in an output file (path relative to the output directory)
# Returns -1 if the file could not be read
function Get-FailedOrSkippedTestCount {
    param([string]$OutputFile)
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
        "${IMAGE_NAME}:latest",
        "python3", "-c",
        "import sys; from robot.api import ExecutionResult; s = ExecutionResult(sys.argv[1]).statistics.total; print(s.failed + s.skipped)",
        "/opt/robotframework/reports/$OutputFile"
    )
    
    $count = & docker @dockerArgs
    $failedCount = 0
    if ($LASTEXITCODE -ne 0 -or -not [int]::TryParse("$count".Trim(), [ref]$failedCount)) {
        return -1
    }
    return $failedCount
}

# Function to build --test options for the failed and skipped tests in an output file (path relative to the output directory)
function Get-RerunTestOptions {
    param([string]$OutputFile)
    
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
        "${IMAGE_NAME}:latest",
        "python3", "-c",
        "import re, sys; from robot.api import ExecutionResult; print('\n'.join(re.sub(r'([\[*?])', r'[\1]', t.full_name) for t in ExecutionResult(sys.argv[1]).suite.all_tests if not t.passed))",
        "/opt/robotframework/reports/$OutputFile"
    )
    
    $testOptions = @()
    foreach ($name in @(& docker @dockerArgs)) {
        if ("$name".Trim()) {
            $testOptions += @("--test", "$name".Trim())
        }
    }
    return ,$testOptions
}

# Function to rerun failed and skipped tests once and merge the results with the first run
# The first run is kept as is (single runs: first-run-*.xml/html), rerun results go to rerun/
# and the merged result is written to output.xml/log.html/report.html (single runs) or <Prefix>merged-output.xml
# Returns $true when all rerun tests passed
function Invoke-FailedTestRerun {
    param(
        [string]$Tool,
        [array]$RunOptions,
        [array]$TestFiles,
        [string]$Prefix = ""
    )
    
    $reports = "/opt/robotframework/reports"
    $original = "${Prefix}output.xml"
    
    if (-not (Test-Path "output\$original")) {
        Write-Warning "[WARNING] $original not found, skipping rerun"
        return $false
    }
    
    $failedCount = Get-FailedOrSkippedTestCount -OutputFile $original
    if ($failedCount -le 0) {
        Write-Warning "[WARNING] No failed or skipped tests found in $original, skipping rerun"
        return $false
    }
    
    $testOptions = Get-RerunTestOptions -OutputFile $original
    if ($testOptions.Count -eq 0) {
        Write-Warning "[WARNING] Could not read the failed and skipped tests from $original, skipping rerun"
        return $false
    }
    
    $mergedOutput = "${Prefix}merged-output.xml"
    $mergedLog = "NONE"
    $mergedReport = "NONE"
    if (-not $Prefix) {
        # Keep the first run as first-run-* files, the merged result replaces output.xml/log.html/report.html
        $dockerArgs = @(
            "run", "--rm",
            "-v", "${OUTPUT_DIR}:$reports",
            "${IMAGE_NAME}:latest",
            "rebot",
            "--nostatusrc",
            "--outputdir", $reports,
            "--output", "first-run-output.xml",
            "--log", "first-run-log.html",
            "--report", "first-run-report.html",
            "$reports/$original"
        )
        
        & docker @dockerArgs | Out-Host
        if ($LASTEXITCODE -ne 0) {
            Write-Error "[FAILED] Saving the first run results failed, skipping rerun"
            return $false
        }
        $original = "first-run-output.xml"
        $mergedOutput = "output.xml"
        $mergedLog = "log.html"
        $mergedReport = "report.html"
    }
    
    Write-Info "Rerunning $failedCount failed or skipped test(s) from $original..."
    $dockerArgs = @(
        "run", "--rm",
        "--env-file", $DOCKER_ENV_FILE,
        "-v", "${TEST_DIR}:/opt/robotframework/tests",
        "-v", "${OUTPUT_DIR}:$reports",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/output",
        "${IMAGE_NAME}:latest",
        $Tool
    ) + $RunOptions + $testOptions + @(
        "--settag", "rerun",
        "--outputdir", "$reports/rerun",
        "--output", "${Prefix}rerun-output.xml",
        "--log", "${Prefix}rerun-log.html",
        "--report", "${Prefix}rerun-report.html"
    ) + $TestFiles
    
    & docker @dockerArgs | Out-Host
    
    Write-Info "Merging rerun results..."
    $dockerArgs = @(
        "run", "--rm",
        "-v", "${OUTPUT_DIR}:$reports",
        "${IMAGE_NAME}:latest",
        "rebot",
        "--nostatusrc",
        "--merge",
        "--outputdir", $reports,
        "--output", $mergedOutput,
        "--log", $mergedLog,
        "--report", $mergedReport,
        "$reports/$original",
        "$reports/rerun/${Prefix}rerun-output.xml"
    )
    
    & docker @dockerArgs | Out-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Error "[FAILED] Merging rerun results failed"
        return $false
    }
    
    # A test that skips again keeps its skipped status in the merged result, so check the merged result
    if ((Get-FailedOrSkippedTestCount -OutputFile $mergedOutput) -eq 0) {
        Write-Success "[SUCCESS] All $failedCount failed or skipped test(s) passed on rerun"
        return $true
    }
    Write-Error "[FAILED] Some tests failed or were skipped again on rerun"
    return $false
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
    
    # Validate Docker image exists
    if (-not (Test-DockerImage)) {
        return $false
    }
    
    # Validate .env file exists before running
    if (-not (Test-Path $DOCKER_ENV_FILE)) {
        Write-Error "[FAILED] .env file not found: $DOCKER_ENV_FILE"
        Write-Warning "Tests may fail without proper environment configuration"
        return $false
    }
    
    # Ensure output directory exists
    Ensure-OutputDirectory
    Clear-PreviousResults
    
    # Build Docker arguments
    $dockerArgs = @(
        "run", "--rm",
        "--env-file", $DOCKER_ENV_FILE,
        "-v", "${TEST_DIR}:/opt/robotframework/tests",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
        "-v", "${OUTPUT_DIR}:/opt/robotframework/output",
        "${IMAGE_NAME}:latest"
    )
    
    # Options and test files are shared by the first run and the rerun of failed tests
    if ($Parallel -and $Processes -gt 0) {
        # Pabot parallel execution
        $tool = "pabot"
        $runOptions = @(
            "--testlevelsplit",
            "--processes", $Processes,
            "--pabotlib",
            "--exclude", "serialonly",
            "--resourcefile", "/opt/robotframework/tests/Resources/pabot_users.dat",
            "--variable", "ENABLE_HAR_RECORDING:$($config["ENABLE_HAR_RECORDING"])"
        )
    } else {
        # Robot sequential execution
        $tool = "robot"
        $runOptions = @(
            "--variable", "FORCE_SINGLE_USER:True",
            "--variable", "ENABLE_HAR_RECORDING:$($config["ENABLE_HAR_RECORDING"])"
        )
    }
    $testFiles = @("/opt/robotframework/tests/$TestFile")
    $dockerArgs += @($tool) + $runOptions + @("--outputdir", "/opt/robotframework/reports") + $testFiles
    
    & docker @dockerArgs
    $exitCode = $LASTEXITCODE
    # Robot's exit code counts only failed tests, so also check for skipped tests
    if ($exitCode -eq 0 -and (Get-FailedOrSkippedTestCount -OutputFile "output.xml") -eq 0) {
        Write-Success "[SUCCESS] $TaskName completed successfully"
    } elseif ($RERUN_FAILED_TESTS -and (Invoke-FailedTestRerun -Tool $tool -RunOptions $runOptions -TestFiles $testFiles)) {
        Write-Success "[SUCCESS] $TaskName completed successfully after rerunning failed tests"
    } else {
        Write-Error "[FAILED] $TaskName failed or had skipped tests (exit code: $exitCode)"
        Write-Warning "Check the output above for detailed error information"
        return $false
    }
    return $true
}

# Function to run all suites
function Start-AllSuites {
    param([bool]$Parallel = $true)
    
    $mode = if ($Parallel) { "parallel + sequential" } else { "sequential" }
    Write-Warning "Running all test suites in $mode..."
    
    # Validate Docker image exists
    if (-not (Test-DockerImage)) {
        return $false
    }
    
    # Validate .env file exists before running
    if (-not (Test-Path $DOCKER_ENV_FILE)) {
        Write-Error "[FAILED] .env file not found: $DOCKER_ENV_FILE"
        Write-Warning "Tests may fail without proper environment configuration"
        return $false
    }
    
    Ensure-OutputDirectory
    Clear-PreviousResults
    
    # Define suites that can run in parallel
    $parallelSuites = @(
        "/opt/robotframework/tests/$SUITE_USER_DESKTOP",
        "/opt/robotframework/tests/$SUITE_ADMIN_DESKTOP",
        "/opt/robotframework/tests/$SUITE_USERS_WITH_ADMIN",
        "/opt/robotframework/tests/$SUITE_MOBILE_ANDROID",
        "/opt/robotframework/tests/$SUITE_MOBILE_IPHONE"
    )
    
    # All suites including notifications
    $allSuites = $parallelSuites + @("/opt/robotframework/tests/$SUITE_ADMIN_NOTIFICATIONS")
    
    # Options are shared by the first run and the rerun of failed tests
    $parallelOptions = @(
        "--testlevelsplit",
        "--processes", $ALL_SUITES_PROCESSES,
        "--pabotlib",
        "--exclude", "serialonly",
        "--resourcefile", "/opt/robotframework/tests/Resources/pabot_users.dat",
        "--variable", "ENABLE_HAR_RECORDING:$($config["ENABLE_HAR_RECORDING"])"
    )
    $sequentialOptions = @(
        "--variable", "FORCE_SINGLE_USER:True",
        "--variable", "ENABLE_HAR_RECORDING:$($config["ENABLE_HAR_RECORDING"])"
    )
    $notificationsSuites = @("/opt/robotframework/tests/$SUITE_ADMIN_NOTIFICATIONS")
    
    if ($Parallel) {
        # First, run parallel suites with pabot
        Write-Info "Phase 1: Running parallel test suites..."
        
        $dockerArgs = @(
            "run", "--rm",
            "--env-file", $DOCKER_ENV_FILE,
            "-v", "${TEST_DIR}:/opt/robotframework/tests",
            "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
            "-v", "${OUTPUT_DIR}:/opt/robotframework/output",
            "${IMAGE_NAME}:latest",
            "pabot"
        ) + $parallelOptions + @(
            "--outputdir", "/opt/robotframework/reports",
            "--output", "parallel-output.xml",
            "--log", "parallel-log.html",
            "--report", "parallel-report.html"
        ) + $parallelSuites
        
        & docker @dockerArgs
        $parallelExitCode = $LASTEXITCODE
        
        # Robot's exit code counts only failed tests, so also check for skipped tests
        if ($parallelExitCode -eq 0 -and (Get-FailedOrSkippedTestCount -OutputFile "parallel-output.xml") -eq 0) {
            Write-Success "[SUCCESS] Parallel suites completed successfully"
        } else {
            Write-Error "[FAILED] Parallel suites failed or had skipped tests (exit code: $parallelExitCode)"
            $parallelExitCode = 1
        }
        
        # Second, run notifications test sequentially
        Write-Info "Phase 2: Running sequential notification tests..."
        
        $dockerArgs = @(
            "run", "--rm",
            "--env-file", $DOCKER_ENV_FILE,
            "-v", "${TEST_DIR}:/opt/robotframework/tests",
            "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
            "-v", "${OUTPUT_DIR}:/opt/robotframework/output",
            "${IMAGE_NAME}:latest",
            "robot"
        ) + $sequentialOptions + @(
            "--outputdir", "/opt/robotframework/reports",
            "--output", "notifications-output.xml",
            "--log", "notifications-log.html",
            "--report", "notifications-report.html"
        ) + $notificationsSuites
        
        & docker @dockerArgs
        $notificationsExitCode = $LASTEXITCODE
        
        # Robot's exit code counts only failed tests, so also check for skipped tests
        if ($notificationsExitCode -eq 0 -and (Get-FailedOrSkippedTestCount -OutputFile "notifications-output.xml") -eq 0) {
            Write-Success "[SUCCESS] Notifications suite completed successfully"
        } else {
            Write-Error "[FAILED] Notifications suite failed or had skipped tests (exit code: $notificationsExitCode)"
            $notificationsExitCode = 1
        }
        
        # Rerun failed tests once and merge the results with the first run
        if ($RERUN_FAILED_TESTS -and ($parallelExitCode -ne 0 -or $notificationsExitCode -ne 0)) {
            Write-Info "Phase 3: Rerunning failed and skipped tests..."
            if ($parallelExitCode -ne 0 -and (Invoke-FailedTestRerun -Tool "pabot" -RunOptions $parallelOptions -TestFiles $parallelSuites -Prefix "parallel-")) {
                $parallelExitCode = 0
            }
            if ($notificationsExitCode -ne 0 -and (Invoke-FailedTestRerun -Tool "robot" -RunOptions $sequentialOptions -TestFiles $notificationsSuites -Prefix "notifications-")) {
                $notificationsExitCode = 0
            }
        }
        
        # Use the merged results where failed tests were rerun
        $parallelResult = if (Test-Path "output\parallel-merged-output.xml") { "parallel-merged-output.xml" } else { "parallel-output.xml" }
        $notificationsResult = if (Test-Path "output\notifications-merged-output.xml") { "notifications-merged-output.xml" } else { "notifications-output.xml" }
        
        # Combine the results using rebot
        Write-Info "Phase 4: Combining test results..."
        
        # Check if output files exist before combining (use relative path for PowerShell)
        $parallelOutputExists = Test-Path "output\parallel-output.xml"
        $notificationsOutputExists = Test-Path "output\notifications-output.xml"
        
        if (-not $parallelOutputExists) {
            Write-Warning "[WARNING] Parallel output file not found, skipping result combination"
        } elseif (-not $notificationsOutputExists) {
            Write-Warning "[WARNING] Notifications output file not found, skipping result combination"
        } else {
            $dockerArgs = @(
                "run", "--rm",
                "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
                "${IMAGE_NAME}:latest",
                "rebot",
                "--outputdir", "/opt/robotframework/reports",
                "--output", "output.xml",
                "--log", "log.html",
                "--report", "report.html",
                "--name", "All Suites",
                "/opt/robotframework/reports/$parallelResult",
                "/opt/robotframework/reports/$notificationsResult"
            )
            
            & docker @dockerArgs
            $rebotExitCode = $LASTEXITCODE
            
            # Rebot returns exit codes 0-250 where the code indicates number of failed tests
            # Exit codes > 250 indicate actual rebot errors
            if ($rebotExitCode -le 250) {
                if ($rebotExitCode -eq 0) {
                    Write-Success "[SUCCESS] Results combined successfully (no failed tests)"
                } else {
                    Write-Success "[SUCCESS] Results combined successfully ($rebotExitCode test(s) failed - see combined report)"
                }
            } else {
                Write-Error "[FAILED] Result combination failed with exit code: $rebotExitCode"
            }
        }
        
        # Overall success if both test runs succeeded
        if ($parallelExitCode -eq 0 -and $notificationsExitCode -eq 0) {
            Write-Success "[SUCCESS] All suites completed successfully"
            return $true
        } else {
            Write-Error "[FAILED] One or more test suites failed"
            Write-Warning "Check the output above for detailed error information"
            return $false
        }
        
    } else {
        # Run all suites sequentially with robot
        $dockerArgs = @(
            "run", "--rm",
            "--env-file", $DOCKER_ENV_FILE,
            "-v", "${TEST_DIR}:/opt/robotframework/tests",
            "-v", "${OUTPUT_DIR}:/opt/robotframework/reports",
            "-v", "${OUTPUT_DIR}:/opt/robotframework/output",
            "${IMAGE_NAME}:latest",
            "robot"
        ) + $sequentialOptions + @(
            "--outputdir", "/opt/robotframework/reports"
        ) + $allSuites
        
        & docker @dockerArgs
        $exitCode = $LASTEXITCODE
        # Robot's exit code counts only failed tests, so also check for skipped tests
        if ($exitCode -eq 0 -and (Get-FailedOrSkippedTestCount -OutputFile "output.xml") -eq 0) {
            Write-Success "[SUCCESS] All suites completed successfully"
            return $true
        } elseif ($RERUN_FAILED_TESTS -and (Invoke-FailedTestRerun -Tool "robot" -RunOptions $sequentialOptions -TestFiles $allSuites)) {
            Write-Success "[SUCCESS] All suites completed successfully after rerunning failed tests"
            return $true
        } else {
            Write-Error "[FAILED] All suites failed or had skipped tests (exit code: $exitCode)"
            Write-Warning "Check the output above for detailed error information"
            return $false
        }
    }
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
        
        # Validate JSON structure
        if (-not $json.PSObject.Properties.Name.Contains('robot_variables')) {
            Write-Error "[FAILED] Invalid JSON structure: 'robot_variables' section missing"
            return $false
        }
        
        if (-not $json.robot_variables.PSObject.Properties.Name.Contains('enable_har_recording')) {
            Write-Error "[FAILED] Invalid JSON structure: 'enable_har_recording' property missing"
            return $false
        }
        
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
        "ruff", "check", "."
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
    param([bool]$SkipConfirmation = $false)
    
    Write-Warning "Formatting Python code with Ruff..."
    
    if (-not $SkipConfirmation) {
        Write-Warning "This will modify your .py files"
        $confirm = Read-Host "Continue? (y/n)"
        
        if ($confirm -notmatch "^[Yy]$") {
            Write-Warning "Cancelled"
            return $false
        }
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
        "ruff", "format", "."
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
        "ruff", "format", "--check", "."
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
    Write-Warning "[NOTE] Shell script linting is designed for Mac/Linux. For best results, use the docker-test.sh runner on Mac/Linux systems."
    Write-Host ""
    
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
    param([bool]$SkipConfirmation = $false)
    
    Write-Warning "Formatting Shell scripts with shfmt..."
    Write-Info "This will format shell scripts to standard style"
    Write-Host ""
    
    if (-not $SkipConfirmation) {
        Write-Warning "This will modify your shell script files"
        $confirm = Read-Host "Continue? (y/n)"
        
        if ($confirm -notmatch "^[Yy]$") {
            Write-Warning "Cancelled"
            return $false
        }
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
# Use an editor with PowerShell formatting support instead.
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
    Start-PythonFormat -SkipConfirmation $true
    Write-Host ""
    Write-Warning "Formatting Robot Framework files..."
    Start-FormatRobotFiles -SkipConfirmation $true
    Write-Host ""
    Write-Warning "Formatting Shell scripts..."
    Start-ShellFormat -SkipConfirmation $true
    Write-Host ""
    Write-Success "[SUCCESS] All formatters completed"
    Write-Info "Review changes with: git diff"
    return $true
}

# Function to format Robot Framework files with Robocop
function Start-FormatRobotFiles {
    param([bool]$SkipConfirmation = $false)
    
    Write-Warning "Formatting Robot Framework files with Robocop..."
    Write-Info "This will comprehensively format your .robot files:"
    Write-Info "  - Reorder sections"
    Write-Info "  - Fix indentation and spacing"
    Write-Info "  - Sort imports/settings/variables"
    Write-Info "  - Break long lines"
    Write-Info "  - Normalize formatting"
    Write-Info "  - Normalize keyword names (library/resource names preserved)"
    Write-Host ""
    
    if (-not $SkipConfirmation) {
        Write-Warning "This will modify your .robot files"
        $confirm = Read-Host "Continue? (y/n)"
        
        if ($confirm -notmatch "^[Yy]$") {
            Write-Warning "Cancelled"
            return $false
        }
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
        "21" { Start-PythonFormatCheck }
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
        $harStatus = if ($config["ENABLE_HAR_RECORDING"] -eq "`${TRUE}") { "[ENABLED]" } else { "[DISABLED]" }
        $harColor = if ($config["ENABLE_HAR_RECORDING"] -eq "`${TRUE}") { "Green" } else { "Yellow" }
        Write-Host "HAR Recording: " -NoNewline
        Write-Host $harStatus -ForegroundColor $harColor
        
        # Show rerun failed tests status
        $rerunStatus = if ($RERUN_FAILED_TESTS) { "[ENABLED]" } else { "[DISABLED]" }
        $rerunColor = if ($RERUN_FAILED_TESTS) { "Green" } else { "Yellow" }
        Write-Host "Rerun Failed Tests: " -NoNewline
        Write-Host $rerunStatus -ForegroundColor $rerunColor -NoNewline
        Write-Host " (docker-config.json)"
        
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
        Write-Host "9. All Suites (Parallel + Notifications Sequential)"
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
        Write-Host "21. Check Python Formatting (Ruff)"
        Write-Host "22. Lint Robot Framework Files (Robocop)"
        Write-Host "23. Lint Shell Scripts (ShellCheck) (mac/linux)"
        Write-Host "24. Format Shell Scripts (shfmt) (mac/linux)"
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
        
        & "$PSCommandPath" -Choice $choice
        
        # If HAR recording toggle was used, reload configuration
        if ($choice -eq "18") {
            Write-Info "Reloading configuration..."
            $script:config = Get-DockerConfig
        }
        
    } while ($true)
}