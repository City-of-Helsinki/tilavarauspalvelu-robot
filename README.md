# Varaamo Robot Framework Tests

## About Varaamo

**Varaamo** is the space and resource reservation platform for City of Helsinki, where citizens can make reservations for spaces and resources owned by the City of Helsinki.

🔗 **Main Application Repository**: [tilavarauspalvelu-core](https://github.com/City-of-Helsinki/tilavarauspalvelu-core)

This repository contains automated test suites for the Varaamo booking system using Robot Framework with the Browser Library (Playwright). The project supports Docker-based execution, local development, and GitHub Actions CI/CD with parallel testing capabilities.

## 🚀 Features

- **Multi-platform Testing**: Desktop, mobile (Android/iOS), and admin interface testing. Chrome, Firefox, Safari via Playwright.
- **Parallel Execution**: Support for concurrent test execution using pabot
- **Docker Integration**: Containerized test environment for consistent execution
- **CI/CD Pipeline**: GitHub Actions workflow with configurable test suites
- **User Isolation**: Deterministic user assignment to prevent conflicts in parallel testing
- **Email Verification**: Support for verifying booking confirmation emails using email cache API provided by the Varaamo test environment
- **HAR File Recording**: Optional capturing of network traffic for debugging and analysis
- **GraphQL Cleanup**: Automated cleanup of phantom notifications from failed test runs

## 🛠️ Tech Stack

| Component | Purpose |
|-----------|---------|
| Robot Framework | Test automation framework |
| Robot Framework Browser Library | Chromium, Firefox, WebKit (Playwright-based) |
| Pabot | Parallel test execution |
| Python | Custom keywords used for email and ICS file testing|
| Python-dotenv | Environment variable management from `.env` files |
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
4. Run: `./docker-test.sh` (Mac/Linux) or `.\docker-test.ps1` (Windows)
5. View results: Open `output/report.html`

## ⚠️ Troubleshooting

If tests fail, check the [Troubleshooting Guide](SETUP_GUIDE.md#-troubleshooting) for common issues and solutions.

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
- **Node.js 24.11.1** with Playwright browsers
- **Robot Framework 7.3.2** with Browser library
- **Parallel execution support** via pabot

### Building the Docker Image

```bash
docker build --no-cache -t robotframework-tests .
```

## 🚀 Running Tests

### Quick Start

Use the interactive test runner to select and execute tests:

**macOS/Linux:**
```bash
./docker-test.sh
```

**Windows:**
```powershell
# PowerShell blocks script execution by default for security
# Choose one option to allow the script to run:

# Option 1: Set Execution Policy Once (Recommended)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
.\docker-test.ps1

# Option 2: Bypass for Single Execution
powershell -ExecutionPolicy Bypass -File docker-test.ps1
```

The interactive menu provides options for:
- **Parallel execution** (pabot) with configurable process counts
- **Sequential execution** for single-user scenarios
- **Individual test suites** or **all suites**
- **Docker image management** (build, clean)
- **HAR analyzer** for network traffic analysis

### Available Test Suites

- **`Tests_user_desktop_FI.robot`** - Desktop browser tests (includes recurring reservations)
- **`Tests_admin_desktop_FI.robot`** - Admin user tests
- **`Tests_admin_notifications_serial.robot`** - Admin notification management (cannot be run in parallel)
- **`Tests_users_with_admin_desktop.robot`** - Combined user and admin tests
- **`Tests_user_mobile_android_FI.robot`** - Mobile Android tests
- **`Tests_user_mobile_iphone_FI.robot`** - Mobile iPhone tests

### Execution Modes

| Execution Mode | Command | User Assignment | When to Use |
|---------------|---------|-----------------|-------------|
| **Parallel** 🚀 | `pabot --pabotlib --resourcefile pabot_users.dat` | Unique users per test from `pabot_users.dat` | CI/CD, fast execution |
| **Sequential** 🌐 | `robot` (or `robot --variable FORCE_SINGLE_USER:True`) | Shared users from `serial_users.robot` | Single test runs, local development |

**Automatic Fallback:** The system automatically uses sequential mode when running with `robot` command, when `FORCE_SINGLE_USER=True` is set, when value set acquisition fails, or when PabotLib is unavailable.

**Process Configuration:** Default parallel process counts (configurable in `docker-config.json`):
- Desktop: 8 | Admin: 2 | Mobile: 3 | All suites: 5

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

📖 **For detailed information on tags, data sets, flow diagrams, and adding new tests, see [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md)**

### 🔁 Rerunning Failed Tests

At the end of a run, failed and skipped tests are rerun once with the same options, and the results are merged into the final report, which shows both the first and the rerun result (rerun tests get the `rerun` tag). Skipped tests also fail the run, because a test is skipped when a test it needs has failed (e.g. `Check emails from reservations` is skipped when `User can make paid single booking` fails). Rerun is enabled by default in `docker-test.sh`, `docker-test.ps1` and GitHub Actions (the `rerun_failed_tests` input).

To disable rerun locally, set `rerun_failed_tests` to `false` in `docker-config.json`:
```json
{
  "execution": {
    "rerun_failed_tests": false
  }
}
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

### 🔧 Troubleshooting

If you see failures, follow the troubleshooting guide: **[Troubleshooting](SETUP_GUIDE.md#troubleshooting)**

## 🔑 Environment File (.env) Location

**⚠️ Important**: The `.env` file **must** be located at `TestSuites/Resources/.env` for proper functionality.

**📍 Why this location?**
- The `env_loader.py` script automatically loads environment variables from this location

📖 **For detailed setup instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## Manual Docker Commands

**📧 Note**: All secrets (`WAF_BYPASS_SECRET`, `ROBOT_API_TOKEN`, `DJANGO_ADMIN_PASSWORD`) are loaded from your `.env` file using Docker's `--env-file` parameter.

### Manual Docker Commands (Mac/Linux)

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

### Manual Docker Commands (Windows PowerShell)

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

### Running Individual Test Cases

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

**macOS/Linux:**
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

HAR files can be recorded during test execution for network traffic analysis. These options can be configured through the interactive test runners (`docker-test.sh` / `docker-test.ps1`) or manually:

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

📖 **For detailed test flow and architecture information, see [TEST_ARCHITECTURE.md](TEST_ARCHITECTURE.md)**

## 🐛 Debugging

### Code Editor With Visible Browser (Recommended for Debugging)

For debugging with a visible browser, use a code editor (Cursor or VS Code) with the Robocorp Code extension. Set `headless=false` to see the browser during test execution. This setup is simplest for debugging as it allows you to watch tests run in real-time.

1. Follow the **[EDITOR_SETUP_GUIDE.md](EDITOR_SETUP_GUIDE.md)** for simple setup with Cursor / VS Code
2. No Docker needed - extension handles everything automatically
3. Perfect for debugging with visible browser

## 🚀 GitHub Actions

This project includes a GitHub Actions workflow that runs tests when manually triggered via the GitHub Actions UI.

📖 **For detailed test execution instructions, see [SETUP_GUIDE.md](SETUP_GUIDE.md)**

## 📁 Project Structure

<pre>
.
├── .github/
│   └── workflows/
│       └── testing.yaml
│           # CI/CD workflow with test suite selection options
│
├── TestSuites/
│   # Test suite directory
│   │
│   ├── PO/
│   │   # Page Objects (PO) for separation of test logic and UI elements
│   │   │
│   │   ├── Admin/
│   │   │   # Admin interface page objects
│   │   │   ├── admin_landingpage.robot
│   │   │   ├── admin_my_units.robot
│   │   │   ├── admin_navigation_menu.robot
│   │   │   ├── admin_notifications.robot
│   │   │   ├── admin_notifications_create_page.robot
│   │   │   ├── admin_reservations.robot
│   │   │   └── django_admin.robot
│   │   │
│   │   ├── App/
│   │   │   # Application-specific page objects
│   │   │   ├── app_admin.robot
│   │   │   │   # Admin actions and workflows
│   │   │   ├── app_common.robot
│   │   │   │   # Shared functionality across user types
│   │   │   ├── app_user.robot
│   │   │   │   # User-specific actions
│   │   │   └── mail.robot
│   │   │       # Email verification functionality
│   │   │
│   │   ├── Common/
│   │   │   # Shared UI components and patterns
│   │   │   ├── checkout.robot
│   │   │   │   # Payment and checkout flows
│   │   │   ├── login.robot
│   │   │   │   # Authentication handling
│   │   │   ├── popups.robot
│   │   │   │   # Popup handling (cookies, confirmations)
│   │   │   └── topnav.robot
│   │   │       # Top navigation elements
│   │   │
│   │   └── User/
│   │       # User interface page objects
│   │       ├── mybookings.robot
│   │       │   # My Bookings page actions
│   │       ├── quick_reservation.robot
│   │       │   # Quick booking slot selection
│   │       ├── recurring.robot
│   │       │   # Recurring booking round and unit selection
│   │       ├── recurring_applications.robot
│   │       │   # Recurring app form (name, people, age, purpose, times)
│   │       ├── recurring_applications_page2.robot
│   │       │   # Recurring app time preferences and availability
│   │       ├── recurring_applications_page3.robot
│   │       │   # Recurring app contact and billing information
│   │       ├── recurring_applications_page_preview.robot
│   │       │   # Terms acceptance before submission
│   │       ├── recurring_applications_page_sent.robot
│   │       │   # Application submission confirmation
│   │       ├── reservation_calendar.robot
│   │       │   # Calendar duration and time slot selection
│   │       ├── reservation_lownav.robot
│   │       │   # Continue/submit button actions
│   │       ├── reservation_unit_booking_details.robot
│   │       │   # Booking form (name, purpose, etc)
│   │       ├── reservation_unit_reservation_receipt.robot
│   │       │   # Reservation confirmation validation
│   │       ├── reservation_unit_reserver_info.robot
│   │       │   # Contact information form fields
│   │       ├── reservation_unit_reserver_types.robot
│   │       │   # Individual/company reserver selection
│   │       ├── singlebooking.robot
│   │       │   # Unit search and advanced search toggle
│   │       └── user_landingpage.robot
│   │           # Landing page checks and payment notifications
│   │
│   ├── Resources/
│   │   # Shared resources and configuration
│   │   ├── variables.robot
│   │   │   # Global variables (URLs, test data)
│   │   ├── env_loader.py
│   │   │   # Environment variable loader from .env file
│   │   ├── texts_FI.robot
│   │   │   # Finnish language texts for verification
│   │   ├── texts_ENG.robot
│   │   │   # English language texts for verification
│   │   ├── common_setups_teardowns.robot
│   │   │   # Test setup and teardown procedures
│   │   ├── custom_keywords.robot
│   │   │   # Custom Robot Framework keywords
│   │   ├── data_modification.robot
│   │   │   # Data manipulation utilities
│   │   ├── devices.robot
│   │   │   # Device-specific configurations
│   │   ├── har_recording.robot
│   │   │   # HAR file recording utilities
│   │   ├── parallel_test_data.robot
│   │   │   # Test data initialization and user assignment logic
│   │   ├── python_keywords.py
│   │   │   # Python-based custom keywords
│   │   ├── suite_specific_units.robot
│   │   │   # Suite-specific unit configurations for parallel isolation
│   │   ├── suite_unit_selector.robot
│   │   │   # Dynamic unit assignment logic for different test suites
│   │   ├── pabot_users.dat
│   │   │   # PabotLib value sets with user data for parallel execution
│   │   ├── robot_email_test_tool.py
│   │   │   # Email testing library (backend cache API)
│   │   ├── serial_users.robot
│   │   │   # User management for serial (non-pabot) execution
│   │   ├── create_data.robot
│   │   │   # Test data creation via API endpoint
│   │   ├── graphql_commands.robot
│   │   │   # GraphQL API commands for backend operations
│   │   └── downloads/
│   │       # Downloaded ICS calendar files
│   │
│   ├── Tests_user_desktop_FI.robot
│   ├── Tests_admin_desktop_FI.robot
│   ├── Tests_user_mobile_android_FI.robot
│   ├── Tests_user_mobile_iphone_FI.robot
│   ├── Tests_users_with_admin_desktop.robot
│   └── Tests_admin_notifications_serial.robot
│
├── output/
│   # Test reports (created at runtime)
│   ├── log.html
│   │   # Detailed execution logs
│   ├── report.html
│   │   # Test result summary
│   ├── output.xml
│   │   # XML output file
│   └── screenshots/
│       # Captured screenshots from test failures
│
├── Dockerfile
│   # Docker image definition
├── docker-config.json
│   # Test configuration (process counts, test suites)
├── docker-test.sh
│   # Interactive test runner for Linux/macOS
├── docker-test.ps1
│   # Interactive test runner for Windows
├── requirements.txt
│   # Python dependencies
├── conda.yaml
│   # Robocorp RCC environment packages (Python, Node.js, Robot Framework dependencies)
├── robot.yaml
│   # Robocorp RCC project config (tasks, environment setup for local execution)
├── har_analyzer.py
│   # HAR file analysis utilities
├── create_robot_test_data_new.py
│   # Test data creation script
├── LINTING.md
│   # Code quality and linting guide
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
- [PabotLib Documentation](https://pabot.org/) - Parallel execution library
- [Robocorp Documentation](https://sema4.ai/docs/automation/quickstart-guide) - IDE extension and local development setup

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
