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
- **Email Verification**: Support for verifying booking confirmation emails using email cache API provided by the Varaamo test environment
- **HAR File Recording**: Optional capturing of network traffic for debugging and analysis

## 🛠️ Tech Stack

| Component | Purpose |
|-----------|---------|
| Robot Framework | Keyword-driven test automation framework |
| Robot Framework Browser Library | Cross-browser web automation (Playwright-based) |
| Pabot | Parallel test execution |
| Playwright | Browser automation (Chromium, Firefox, WebKit) |
| Python | Runtime environment (3.10+ required) |
| python-dotenv | Environment variable management from `.env` files |
| Requests & Robot Framework Requests | Data creation and email testing via API |
| Robocop | Robot Framework linting and formatting |
| Ruff | Python linting and formatting |
| ShellCheck & shfmt | Shell script linting and formatting |
| Docker | Consistent test execution environments (Playwright base image) |

## 🔐 Required Secrets

Before running tests, you need to acquire these secrets:

- **WAF Bypass Secret** for web application firewall
- **Robot API Token** for test data creation endpoint
- **Django Admin Password** for admin operations

📖 **See [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed setup instructions**

## 🚀 Quick Start (5 minutes)
1. Clone repo: `git clone [repo-url]`
2. Set up secrets: Create `TestSuites/Resources/.env` file with required secrets (see [SETUP_GUIDE.md](SETUP_GUIDE.md))
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

## 🏃‍♂️ Running Tests

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

### 📊 Viewing Test Reports

- **To view the reports, open the `report.html` HTML file in your browser after test execution completes.**
- **When the tests are run in GitHub Actions, the result is marked in the job summary.**


## Manual Docker Commands

**📧 Note**: All secrets (`WAF_BYPASS_SECRET`, `ROBOT_API_TOKEN`, `DJANGO_ADMIN_PASSWORD`) are loaded from your `.env` file using Docker's `--env-file` parameter.

## 🔑 Environment File (.env) Location

**⚠️ Important**: The `.env` file **must** be located at `TestSuites/Resources/.env` for proper functionality.

**📍 Why this location?**
- The `env_loader.py` script automatically loads environment variables from this location

📖 **For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## Manual Docker Commands (Mac/Linux)

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

## 🔍 Code Quality and Linting

This project includes automated linting and formatting for code quality using **Robocop** (Robot Framework linter and formatter - includes Robotidy in 6.0+), **Ruff** (Python linter and formatter), **ShellCheck** (shell script linter), and **shfmt** (shell script formatter).

**Quick access via Docker menu (works with any IDE):**

🤖 Linting runs automatically in GitHub Actions (permissive mode - warnings only, doesn't block builds).

📖 **Note:** Detailed linting documentation will be added to [LINTING.md](LINTING.md) later.

## 🔧 Browser Settings

Browser configurations and device settings are managed in `TestSuites/Resources/devices.robot`:

- **Browser Types**: Chromium (desktop), WebKit (iPhone), Chromium (Android)
- **WAF Bypass**: Configured via `WAF_BYPASS_SECRET` environment variable
- **Parallel Execution**: Staggered startup strategy to prevent resource conflicts

📖 **For detailed test coverage and architecture information, see [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md)**

## 🐛 Debugging

### Code Editor With Visible Browser (Recommended for Debugging)

For debugging with a visible browser, use a code editor (Cursor or VS Code) with the Robocorp Code extension. Set `headless=false` to see the browser during test execution. This setup is simplest for debugging as it allows you to watch tests run in real-time.

1. Follow the **[EDITOR_SETUP_GUIDE.md](EDITOR_SETUP_GUIDE.md)** for simple setup with Cursor / VS Code
2. No Docker needed - extension handles everything automatically
3. Perfect for debugging with visible browser

## 🚀 GitHub Actions

This project includes GitHub Actions workflow that automatically runs tests when:

- Manually triggered via the GitHub Actions UI

📖 **For detailed test execution instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md#-test-execution)**

## 📁 Project Structure

> **Color Reference**: Only key sections are colored for quick scanning
> - <span style="color: #22863a;">Green</span> - App/Common page objects
> - <span style="color: #005cc5;">Blue</span> - User interface files  
> - <span style="color: #e36209;">Orange</span> - Resources/utilities

<pre>
.
├── .github/
│   └── workflows/
│       └── testing.yaml
│           # CI/CD workflow with test suite selection options
│
├── TestSuites/
│   <span style="color: #6a737d;"># Test suite directory</span>
│   │
│   ├── PO/
│   │   <span style="color: #6a737d;"># Page Objects (PO) for separation of test logic and UI elements</span>
│   │   │
│   │   ├── Admin/
│   │   │   <span style="color: #6a737d;"># Admin interface page objects</span>
│   │   │   ├── admin_landingpage.robot
│   │   │   ├── admin_my_units.robot
│   │   │   ├── admin_navigation_menu.robot
│   │   │   ├── admin_notifications.robot
│   │   │   ├── admin_notifications_create_page.robot
│   │   │   ├── admin_reservations.robot
│   │   │   └── django_admin.robot
│   │   │
│   │   ├── App/
│   │   │   <span style="color: #6a737d;"># Application-specific page objects</span>
│   │   │   ├── app_admin.robot          <span style="color: #22863a;"># Admin actions and workflows</span>
│   │   │   ├── app_common.robot         <span style="color: #22863a;"># Shared functionality across user types</span>
│   │   │   ├── app_user.robot           <span style="color: #22863a;"># User-specific actions</span>
│   │   │   └── mail.robot                <span style="color: #22863a;"># Email verification functionality</span>
│   │   │
│   │   ├── Common/
│   │   │   <span style="color: #6a737d;"># Shared UI components and patterns</span>
│   │   │   ├── checkout.robot           <span style="color: #22863a;"># Payment and checkout flows</span>
│   │   │   ├── login.robot               <span style="color: #22863a;"># Authentication handling</span>
│   │   │   ├── popups.robot              <span style="color: #22863a;"># Popup handling (cookies, confirmations)</span>
│   │   │   └── topnav.robot              <span style="color: #22863a;"># Top navigation elements</span>
│   │   │
│   │   └── User/
│   │       <span style="color: #6a737d;"># User interface page objects</span>
│   │       ├── mybookings.robot
│   │       │   <span style="color: #005cc5;"># My Bookings page actions</span>
│   │       ├── quick_reservation.robot
│   │       │   <span style="color: #005cc5;"># Quick booking slot selection</span>
│   │       ├── recurring.robot
│   │       │   <span style="color: #005cc5;"># Recurring booking round and unit selection</span>
│   │       ├── recurring_applications.robot
│   │       │   <span style="color: #005cc5;"># Recurring app form (name, people, age, purpose, times)</span>
│   │       ├── recurring_applications_page2.robot
│   │       │   <span style="color: #005cc5;"># Recurring app time preferences and availability</span>
│   │       ├── recurring_applications_page3.robot
│   │       │   <span style="color: #005cc5;"># Recurring app contact and billing information</span>
│   │       ├── recurring_applications_page_preview.robot
│   │       │   <span style="color: #005cc5;"># Terms acceptance before submission</span>
│   │       ├── recurring_applications_page_sent.robot
│   │       │   <span style="color: #005cc5;"># Application submission confirmation</span>
│   │       ├── reservation_calendar.robot
│   │       │   <span style="color: #005cc5;"># Calendar duration and time slot selection</span>
│   │       ├── reservation_lownav.robot
│   │       │   <span style="color: #005cc5;"># Continue/submit button actions</span>
│   │       ├── reservation_unit_booking_details.robot
│   │       │   <span style="color: #005cc5;"># Booking form (name, purpose, etc)</span>
│   │       ├── reservation_unit_reservation_receipt.robot
│   │       │   <span style="color: #005cc5;"># Reservation confirmation validation</span>
│   │       ├── reservation_unit_reserver_info.robot
│   │       │   <span style="color: #005cc5;"># Contact information form fields</span>
│   │       ├── reservation_unit_reserver_types.robot
│   │       │   <span style="color: #005cc5;"># Individual/company reserver selection</span>
│   │       ├── singlebooking.robot
│   │       │   <span style="color: #005cc5;"># Unit search and advanced search toggle</span>
│   │       └── user_landingpage.robot
│   │           <span style="color: #005cc5;"># Landing page checks and payment notifications</span>
│   │
│   ├── Resources/
│   │   <span style="color: #e36209;"># Shared resources and configuration</span>
│   │   ├── variables.robot
│   │   │   <span style="color: #e36209;"># Global variables (URLs, test data)</span>
│   │   ├── env_loader.py
│   │   │   <span style="color: #e36209;"># Environment variable loader from .env file</span>
│   │   ├── texts_FI.robot
│   │   │   <span style="color: #e36209;"># Finnish language texts for verification</span>
│   │   ├── texts_ENG.robot
│   │   │   <span style="color: #e36209;"># English language texts for verification</span>
│   │   ├── common_setups_teardowns.robot
│   │   │   <span style="color: #e36209;"># Test setup and teardown procedures</span>
│   │   ├── custom_keywords.robot
│   │   │   <span style="color: #e36209;"># Custom Robot Framework keywords</span>
│   │   ├── data_modification.robot
│   │   │   <span style="color: #e36209;"># Data manipulation utilities</span>
│   │   ├── devices.robot
│   │   │   <span style="color: #e36209;"># Device-specific configurations</span>
│   │   ├── har_recording.robot
│   │   │   <span style="color: #e36209;"># HAR file recording utilities</span>
│   │   ├── parallel_test_data.robot
│   │   │   <span style="color: #e36209;"># Test data initialization and user assignment logic</span>
│   │   ├── python_keywords.py
│   │   │   <span style="color: #e36209;"># Python-based custom keywords</span>
│   │   ├── README_TEST_DATA_SYSTEM.md
│   │   │   <span style="color: #e36209;"># Comprehensive test data system documentation</span>
│   │   ├── suite_specific_units.robot
│   │   │   <span style="color: #e36209;"># Suite-specific unit configurations for parallel isolation</span>
│   │   ├── suite_unit_selector.robot
│   │   │   <span style="color: #e36209;"># Dynamic unit assignment logic for different test suites</span>
│   │   ├── pabot_users.dat
│   │   │   <span style="color: #e36209;"># PabotLib value sets with user data for parallel execution</span>
│   │   ├── robot_email_test_tool.py
│   │   │   <span style="color: #e36209;"># Email testing library (backend cache API)</span>
│   │   ├── email_verification.robot
│   │   │   <span style="color: #e36209;"># Email verification keywords for Robot Framework</span>
│   │   ├── serial_users.robot
│   │   │   <span style="color: #e36209;"># User management for serial (non-pabot) execution</span>
│   │   └── downloads/
│   │       <span style="color: #e36209;"># Downloaded ICS calendar files</span>
│   │
│   ├── Tests_user_desktop_FI.robot
│   ├── Tests_admin_desktop_FI.robot
│   ├── Tests_user_mobile_android_FI.robot
│   ├── Tests_user_mobile_iphone_FI.robot
│   ├── Tests_users_with_admin_desktop.robot
│   └── Tests_admin_notifications_serial.robot
│
├── output/
│   <span style="color: #6a737d;"># Test reports (created at runtime)</span>
│   ├── log.html                          # Detailed execution logs
│   ├── report.html                       # Test result summary
│   ├── output.xml                        # XML output file
│   └── screenshots/                       # Captured screenshots from test failures
│
├── Dockerfile                            # Docker image definition
├── docker-config.json                    # Test configuration (process counts, test suites)
├── docker-test.sh                        # Interactive test runner for Linux/macOS
├── docker-test.ps1                      # Interactive test runner for Windows
├── requirements.txt                      # Python dependencies
├── conda.yaml                            # Conda environment configuration
├── robot.yaml                            # RCC configuration
├── har_analyzer.py                        # HAR file analysis utilities
├── create_robot_test_data_new.py         # Test data creation script
├── LINTING.md                             # Code quality and linting guide
└── PARALLEL_DATA_SETUP_GUIDE.md
    # Tag-based test data initialization and parallel execution flow
</pre>

## 📚 Additional Resources

- [EDITOR_SETUP_GUIDE.md](EDITOR_SETUP_GUIDE.md) - Simple setup for debugging with visible browser
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup instructions for the test environment
- [LINTING.md](LINTING.md) - Code quality and linting guide
- [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md) - Test architecture and coverage information
- [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md) - Tag-based test data initialization and parallel execution flow
- [Robot Framework Documentation](https://docs.robotframework.org/)
- [Robot Framework Browser Library](https://marketsquare.github.io/robotframework-browser/Browser.html)
- [Playwright Documentation](https://playwright.dev/)
- [PabotLib Documentation](https://pabot.org/) - Parallel execution library


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
