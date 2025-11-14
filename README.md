# Varaamo Robot Framework Tests

> **⚠️ WIP (Work In Progress):** This README is currently being updated and may contain incomplete or outdated information.  
> Email authentication system is being refactored. Setup requirements may change in future versions. 

This repository contains automated test suites for the Varaamo booking system using Robot Framework with the Browser Library (Playwright). The project supports both Docker-based execution and local development with parallel testing capabilities.

## 🚀 Features

- **Multi-platform Testing**: Desktop, mobile (Android/iOS), and admin interface testing.
Chrome, Firefox, Safari via Playwright.
- **Parallel Execution**: Support for concurrent test execution using pabot
- **Docker Integration**: Containerized test environment for consistent execution
- **CI/CD Pipeline**: GitHub Actions workflow with configurable test suites
- **User Isolation**: Deterministic user assignment to prevent conflicts in parallel testing

## 📦 Version Compatibility
| Component | Version | Notes |
|-----------|---------|-------|
| Robot Framework | 7.3.2 | Required for Browser Library |
| Playwright | Latest | Auto-installed in Docker |
| Python | 3.12.3 | Minimum 3.10 required |
| Docker | 20.10+ | For buildkit features |

## 🔐 Required Secrets

Before running tests, you need to acquire these secrets:

- **Google OAuth Credentials** (for email verification tests)
- **WAF Bypass Secret** for web application firewall
- **Robot API Token** for test data creation endpoint

📖 **See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup instructions**

## 🚀 Quick Start (5 minutes)
1. Clone repo: `git clone [repo-url]`
2. Set up secrets: `cp .env.example TestSuites/Resources/.env` and fill values
3. Build: `docker build -t robotframework-tests .`
OR
4. Run: `./docker-test.sh` (Mac/Linux) or `.\docker-test.ps1` (Windows)
5. View results: Open `output/report.html`

## 🐳 Docker Setup

### Docker Configuration

Docker-related files:

- **`Dockerfile`**: With Playwright browsers and Robot Framework
- **`docker-test.sh`**: Interactive test runner with menu options (macOS/Linux)
- **`docker-test.ps1`**: Interactive test runner with menu options (Windows PowerShell)
- **`docker-config.json`**: Shared configuration for process counts and test suites

### Docker Environment

The Docker container is based on Microsoft's Playwright image and includes:
- **Ubuntu 24.04** with Finnish locale support
- **Python 3.12.3** with virtual environment
- **Node.js 22** with Playwright browsers
- **Robot Framework 7.3.2** with Browser library
- **Parallel execution support** via pabot

### Building the Docker Image

```bash
docker build --no-cache -t robotframework-tests .
```

## Interactive Docker Runner

# 🏃‍♂️ Running Tests

This provides a menu with options for:
- **Parallel execution** (pabot) with configurable process counts
- **Sequential execution** for single-user scenarios
- **Individual test suites** or **all suites**
- **Docker image management** (build, clean)
- **HAR analyzer** for network traffic analysis

## 📋 Available Test Suites

- **`Tests_user_desktop_FI.robot`** - Desktop browser tests (includes recurring reservations)
- **`Tests_admin_desktop_FI.robot`** - Admin user tests
- **`Tests_admin_notifications_serial.robot`** - Admin notification management (cannot be run in parallel)
- **`Tests_users_with_admin_desktop.robot`** - Combined user and admin tests
- **`Tests_user_mobile_android_FI.robot`** - Mobile Android tests
- **`Tests_user_mobile_iphone_FI.robot`** - Mobile iPhone tests

### Process Configuration (Parallel Testing)

Default process counts for parallel execution (configurable in `docker-config.json`):
- **Desktop processes**: 8
- **Admin processes**: 2
- **Mobile processes**: 3
- **All suites processes**: 5

📖 **For details on how parallel execution works and data set assignment, see [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md)**

### How Parallel Testing Works

The test framework uses a **tag-based system** to automatically initialize test data and assign users for parallel execution:

```
Test Case with Tags (e.g., desktop-test-data-set-0, desktop-suite)
    ↓
Complete Test Setup From Tags
    ↓
    ├─→ Initialize suite units from tags
    │   └─→ Reads ${TEST TAGS} → Finds suite type tag → Loads units
    │
    └─→ Initialize Test Data From Tags
        └─→ Reads ${TEST TAGS} → Finds data set tag (e.g., desktop-test-data-set-0)
            ↓
            ├─→ **PARALLEL MODE**: Tag matches + Pabot available → Acquires value set from pabot_users.dat
            │   Result: UNIQUE user per test (parallel execution)
            │
            └─→ **SEQUENTIAL MODE**: Tag matches + Pabot NOT available → Falls back to serial_users.robot
                Result: SHARED users (sequential execution with robot command)
```

Each test case is tagged (e.g., `[Tags] desktop-test-data-set-0 desktop-suite`), and the setup automatically:
1. **Loads appropriate test units** based on suite type tag
2. **Assigns isolated user data** to prevent conflicts in parallel execution
3. **Switches between parallel/single mode** based on execution context

### Execution Modes

| Execution Mode | Command | User Assignment | When to Use |
|---------------|---------|-----------------|-------------|
| **Parallel** 🚀 | `pabot --pabotlib --resourcefile pabot_users.dat` | Unique users per test from `pabot_users.dat` | CI/CD, fast execution|
| **Sequential** 🌐 | `robot` (or `robot --variable FORCE_SINGLE_USER:True`) | Shared users from `serial_users.robot` | VS Code debugging, single test runs, local development |

**Automatic Fallback:** The system automatically uses sequential mode when running with `robot` command, when `FORCE_SINGLE_USER=True` is set, when value set acquisition fails, or when PabotLib is unavailable.

📖 **For detailed information on tags, data sets, flow diagrams, and adding new tests, see [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md)**

### Key Logic Files

The parallel testing system relies on three core files:

- **`parallel_test_data.robot`** - Decides which user data file to use based on execution context (parallel vs sequential)
- **`suite_unit_selector.robot`** - Unit initialization logic (determines which test units/spaces to use)
- **`common_setups_teardowns.robot`** - Universal setup keyword that orchestrates the initialization flow

**macOS/Linux:**
```bash
./docker-test.sh
```

**Windows:**
```powershell
# Option 1: Set Execution Policy Once (Recommended)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\docker-test.ps1

# Option 2: Bypass for Single Execution
powershell -ExecutionPolicy Bypass -File docker-test.ps1
```
## 📈 Test Reports

After running tests, reports are generated in the `output` directory:

- `report.html` - HTML report with test results summary (open in browser)
- `log.html` - Detailed log of test execution
- `output.xml` - XML output containing all test data
- `screenshots/` - Captured screenshots from test failures

To view the reports, open the `report.html` HTML file in your browser after test execution completes.

## Manual Docker Commands

> **⚠️ WIP (Work In Progress)**: Email authentication system is being refactored. The current `.env` file structure and email-related environment variables may change in future versions.

**📧 Note**: All secrets (`ACCESS_TOKEN`, `REFRESH_TOKEN`, `CLIENT_ID`, `CLIENT_SECRET`, `WAF_BYPASS_SECRET`, `ROBOT_API_TOKEN`) are loaded from your `.env` file using Docker's `--env-file` parameter.

## 🔑 Environment File (.env) Location

**⚠️ Important**: The `.env` file **must** be located at `TestSuites/Resources/.env` for proper functionality.

**📍 Why this location?**
- Python scripts (`generate_tokens.py`, `token_manager.py`) write and read from this fixed location
- Ensures consistency between token generation and usage
- Prevents path-related issues when running from different directories

📖 **For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

**Building the Docker image:**
```bash
docker build --no-cache -t robotframework-tests .
```

# Manual Docker Commands (Mac/Linux)

**Sequential Robot Framework execution:**
```bash
docker run --rm \
  --env-file TestSuites/Resources/.env \
  -v "$(pwd)/TestSuites:/opt/robotframework/tests" \
  -v "$(pwd)/output:/opt/robotframework/reports" \
  robotframework-tests \
  robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```

**Parallel execution with pabot:**
```bash
docker run --rm \
  --env-file TestSuites/Resources/.env \
  -v "$(pwd)/TestSuites:/opt/robotframework/tests" \
  -v "$(pwd)/output:/opt/robotframework/reports" \
  robotframework-tests \
  pabot --testlevelsplit --processes 6 --pabotlib --exclude serialonly --resourcefile /opt/robotframework/tests/Resources/pabot_users.dat --outputdir /opt/robotframework/reports /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

**Note:** 
- To run a different test suite, replace `Tests_user_desktop_FI.robot` with your desired suite name (e.g., `Tests_admin_desktop_FI.robot`, `Tests_user_mobile_android_FI.robot`).
- `--processes 6` is the number of tests run simultaneously

## Manual Docker Commands (Windows PowerShell)

**Sequential Robot Framework execution:**
```powershell
docker run --rm `
  --env-file TestSuites\Resources\.env `
  -v "${PWD}\TestSuites:/opt/robotframework/tests" `
  -v "${PWD}\output:/opt/robotframework/reports" `
  robotframework-tests `
  robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```

**Note:** To run a specific test suite, add the suite name after the command: `robot --outputdir /opt/robotframework/reports /opt/robotframework/tests/Tests_user_desktop_FI.robot`

**Example - Run specific test suite:**
```powershell
docker run --rm `
  --env-file TestSuites\Resources\.env `
  -v "${PWD}\TestSuites:/opt/robotframework/tests" `
  -v "${PWD}\output:/opt/robotframework/reports" `
  robotframework-tests `
  robot --outputdir /opt/robotframework/reports /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

**Parallel execution with pabot:**
```powershell
docker run --rm `
  --env-file TestSuites\Resources\.env `
  -v "${PWD}\TestSuites:/opt/robotframework/tests" `
  -v "${PWD}\output:/opt/robotframework/reports" `
  robotframework-tests `
  pabot --testlevelsplit --processes 6 --pabotlib --exclude serialonly --resourcefile /opt/robotframework/tests/Resources/pabot_users.dat --outputdir /opt/robotframework/reports /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

**Note:** 
- To run a different test suite, replace `Tests_user_desktop_FI.robot` with your desired suite name (e.g., `Tests_admin_desktop_FI.robot`, `Tests_user_mobile_android_FI.robot`).
- `--processes 6` is the number of tests run simultaneously


#### Running Individual Test Cases

To run a specific test case from a suite, add the test case name with the `-t` flag:

**Windows:**
```powershell
docker run --rm `
  --env-file TestSuites\Resources\.env `
  -v "${PWD}\TestSuites:/opt/robotframework/tests" `
  -v "${PWD}\output:/opt/robotframework/reports" `
  robotframework-tests `
  robot --outputdir /opt/robotframework/reports `
  -t "User logs in and out with suomi_fi" `
  /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

**macOS/Linux**
```bash
docker run --rm \
  --env-file TestSuites/Resources/.env \
  -v "$(pwd)/TestSuites:/opt/robotframework/tests" \
  -v "$(pwd)/output:/opt/robotframework/reports" \
  robotframework-tests \
  robot --outputdir /opt/robotframework/reports \
  -t "User logs in and out with suomi_fi" \
  /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

### HAR Recording Control

HAR files can be recorded during test execution for network traffic analysis:

**Enable/Disable HAR Recording:**

Via `docker-config.json` (recommended):
```json
{
  "robot_variables": {
    "enable_har_recording": true
  }
}
```

Or directly in Robot Framework variables:
```robot
# In TestSuites/Resources/variables.robot
${ENABLE_HAR_RECORDING}    ${TRUE}  # Set to ${FALSE} to disable
```

**HAR File Location:**
- HAR files are saved to `output/har_files/` directory
- Files can be very large (10-100MB+ per test)
- Only enable when you need to analyze network traffic

**Analyze HAR Files:**

Via Docker (recommended):

**Linux/Mac:**
```bash
# Using the test runner menu - option 17
./docker-test.sh
```

**Windows:**
```powershell
# Using the test runner menu - option 17
.\docker-test.ps1
```

**Direct Docker command:**
```bash
# Linux/Mac
docker run --rm \
  -v "$(pwd):/opt/project" \
  -w /opt/project \
  robotframework-tests:latest \
  python har_analyzer.py

# Windows (PowerShell)
docker run --rm `
  -v "${PWD}:/opt/project" `
  -w /opt/project `
  robotframework-tests:latest `
  python har_analyzer.py
```

Or locally if Python is installed:
```bash
python har_analyzer.py
```

**Note:** HAR recording is disabled by default to improve performance. Only enable when debugging network issues.

## 🔧 Browser Settings

Browser configurations and device settings are managed in `TestSuites/Resources/devices.robot`:

- **Browser Types**: Chromium (desktop), WebKit (iPhone), Chromium (Android)
- **WAF Bypass**: Configured via and `WAF_BYPASS_SECRET` environment variable
- **Parallel Execution**: Staggered startup strategy to prevent resource conflicts

📖 **For detailed test coverage and architecture information, see [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md)**


## 🚀 GitHub Actions

This project includes GitHub Actions workflow that automatically runs tests when:

- Manually triggered via the GitHub Actions UI

### Test Execution

To manually run tests via GitHub Actions:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Varaamo Robot Framework Tests" workflow
3. Click "Run workflow"
4. Select which test suite you want to run from the dropdown menu
5. Choose execution mode (parallel or sequential)
6. **Optional**: Enable "Enable HAR recording" for network traffic analysis
7. Click "Run workflow"

### Workflow Features

- **Configurable test suites**: Choose from individual suites or run all
- **Execution modes**: Parallel (pabot) or sequential (robot)
- **HAR recording**: Optional network traffic recording for analysis
- **Smoke test validation**: For "All" option, runs smoke tests first
- **Docker caching**: Optimized builds with GitHub Actions cache
- **Artifact uploads**: Test reports available as downloadable artifacts
- **Comprehensive reporting**: Detailed test results and failure analysis
- **Automated HAR analysis**: Network traffic analysis when HAR recording is enabled

### HAR Analysis in GitHub Actions

When HAR recording is enabled in the workflow:

1. **Automatic Recording**: All network traffic during test execution is captured
2. **Post-Test Analysis**: HAR analyzer runs automatically after tests complete
3. **Results Integration**: Analysis summary appears in the workflow summary page


### GitHub Actions Setup

For GitHub Actions, add the following secrets to your repository:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add these repository secrets:
   - `ACCESS_TOKEN`
   - `REFRESH_TOKEN` 
   - `CLIENT_ID`
   - `CLIENT_SECRET`
   - `WAF_BYPASS_SECRET`
   - `ROBOT_API_TOKEN`

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/                      # GitHub Actions workflows
│       └── testing.yaml                # CI/CD workflow with test suite selection options
├── TestSuites/                         # Test suite directory
│   ├── PO/                             # Page Objects (PO) for separation of test logic and UI elements
│   │   ├── Admin/                      # Admin interface page objects
│   │   │   ├── admin_landingpage.robot # Admin landing page elements
│   │   │   ├── admin_my_units.robot    # Admin unit management interface
│   │   │   ├── admin_navigation_menu.robot    # Navigation elements for admin interface
│   │   │   ├── admin_notifications.robot      # Admin notification management UI
│   │   │   ├── admin_notifications_create_page.robot # Admin notification creation/editing page
│   │   │   └── admin_reservations.robot # Admin reservation management UI
│   │   ├── App/                        # Application-specific page objects
│   │   │   ├── app_admin.robot         # Admin actions and workflows
│   │   │   ├── app_common.robot        # Shared functionality across user types
│   │   │   ├── app_user.robot          # User-specific actions
│   │   │   └── mail.robot              # Email verification functionality
│   │   ├── Common/                     # Shared UI components and patterns
│   │   │   ├── checkout.robot          # Payment and checkout flows
│   │   │   ├── login.robot             # Authentication handling
│   │   │   ├── popups.robot            # Popup handling (cookies, confirmations)
│   │   │   └── topNav.robot            # Top navigation elements
│   │   └── User/                       # User interface page objects
│   │       ├── mybookings.robot        # My Bookings page actions (cancel, modify, status checks)
│   │       ├── quick_reservation.robot # Quick booking slot selection and time validation
│   │       ├── recurring.robot         # Recurring booking round and unit selection
│   │       ├── recurring_applications.robot # Recurring app form (name, people, age, purpose, times)
│   │       ├── recurring_applications_page2.robot # Recurring app time preferences and availability
│   │       ├── recurring_applications_page3.robot # Recurring app contact and billing information
│   │       ├── recurring_applications_page_preview.robot # Terms acceptance before submission
│   │       ├── recurring_applications_page_sent.robot # Application submission confirmation
│   │       ├── reservation_calendar.robot # Calendar duration and time slot selection
│   │       ├── reservation_lownav.robot # Continue/submit button actions
│   │       ├── reservation_unit_booking_details.robot # Booking form (name, purpose. etc)
│   │       ├── reservation_unit_reservation_receipt.robot # Reservation confirmation validation
│   │       ├── reservation_unit_reserver_info.robot # Contact information form fields
│   │       ├── reservation_unit_reserver_types.robot # Individual/company reserver selection
│   │       ├── singlebooking.robot     # Unit search and advanced search toggle
│   │       └── user_landingpage.robot  # Landing page checks and payment notifications
│   ├── Resources/                      # Shared resources and configuration
│   │   ├── variables.robot             # Global variables (URLs, test data)
│   │   ├── texts_FI.robot              # Finnish language texts for verification
│   │   ├── texts_ENG.robot             # English language texts for verification
│   │   ├── common_setups_teardowns.robot # Test setup and teardown procedures
│   │   ├── custom_keywords.robot       # Custom Robot Framework keywords
│   │   ├── data_modification.robot     # Data manipulation utilities
│   │   ├── devices.robot               # Device-specific configurations
│   │   ├── har_recording.robot         # HAR file recording utilities
│   │   ├── parallel_test_data.robot    # Test data initialization and user assignment logic
│   │   ├── python_keywords.py          # Python-based custom keywords
│   │   ├── README_TEST_DATA_SYSTEM.md  # Comprehensive test data system documentation
│   │   ├── suite_specific_units.robot  # Suite-specific unit configurations for parallel isolation
│   │   ├── suite_unit_selector.robot   # Dynamic unit assignment logic for different test suites
│   │   ├── pabot_users.dat             # PabotLib value sets with user data for parallel execution
│   │   ├── token_manager.py            # Token management utilities
│   │   ├── serial_users.robot          # User management for serial (non-pabot) execution
│   │   └── downloads/                  # Downloaded files (emails, ICS files)
│   ├── Tests_user_desktop_FI.robot     # Desktop browser tests (includes recurring reservations)
│   ├── Tests_admin_desktop_FI.robot    # Admin UI tests
│   ├── Tests_user_mobile_android_FI.robot # Mobile Chrome tests for Android
│   ├── Tests_user_mobile_iphone_FI.robot # Mobile Safari tests for iPhone
│   ├── Tests_users_with_admin_desktop.robot # Combined user/admin workflow tests
│   └── Tests_admin_notifications_serial.robot # Admin notification tests (sequential)
├── output/                             # Test reports (created at runtime)
│   ├── log.html                        # Detailed execution logs
│   ├── report.html                     # Test result summary
│   ├── output.xml                      # XML output file
│   └── screenshots/                    # Captured screenshots from test failures
├── Dockerfile                          # Docker image definition
├── docker-config.json                  # Test configuration (process counts, test suites)
├── docker-test.sh                      # Interactive test runner for Linux/macOS
├── docker-test.ps1                     # Interactive test runner for Windows
├── requirements.txt                    # Python dependencies
├── conda.yaml                          # Conda environment configuration
├── robot.yaml                          # RCC configuration
├── har_analyzer.py                     # HAR file analysis utilities
└── PARALLEL_DATA_SETUP_GUIDE.md        # Tag-based test data initialization and parallel execution flow
```

## 📚 Additional Resources

- [TestSuites/Resources/README_TEST_DATA_SYSTEM.md](TestSuites/Resources/README_TEST_DATA_SYSTEM.md) - Comprehensive test data system documentation
- [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md) - Tag-based test data initialization and parallel execution flow
- [Robot Framework Documentation](https://docs.robotframework.org/)
- [Robot Framework Browser Library](https://marketsquare.github.io/robotframework-browser/Browser.html)
- [Playwright Documentation](https://playwright.dev/)
- [PabotLib Documentation](https://pabot.org/) - Parallel execution library


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
