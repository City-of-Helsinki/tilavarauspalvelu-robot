# Varaamo Robot Framework Tests

> **⚠️ WIP (Work In Progress):** This README is currently being updated and may contain incomplete or outdated information.

This repository contains comprehensive automated test suites for the Varaamo booking system using Robot Framework with the Browser Library (Playwright). The project supports both Docker-based execution and local development with parallel testing capabilities.

## 🚀 Features

- **Multi-platform Testing**: Desktop, mobile (Android/iOS), and admin interface testing.
Chrome, Firefox, Safari via Playwright.
- **Parallel Execution**: Support for concurrent test execution using pabot
- **Docker Integration**: Containerized test environment for consistent execution
- **CI/CD Pipeline**: GitHub Actions workflow with configurable test suites
- **User Isolation**: Deterministic user assignment to prevent conflicts in parallel testing

## 📋 Prerequisites

- **Docker** (recommended for easy setup)
- **Python 3.9+** (for local development)
- **Node.js 22+** (for Playwright browsers)

> **Note:** This project uses Docker for easy setup and execution. If you prefer to install Robot Framework manually, please refer to the [official Robot Framework installation guide](https://docs.robotframework.org/docs/getting_started/testing#install-robot-framework).

## 🔧 Environment Configuration

### Local Development Setup

For local development, create a `.env` file in `TestSuites/Resources/` to store your secrets and configuration:

```bash
# Copy the sample file and fill in your values
cp TestSuites/Resources/.env.sample TestSuites/Resources/.env
```

**Note:** A sample file already exists at `TestSuites/Resources/.env.sample` with the correct template and placeholders ready to be filled in.

> **Important:** The `.env` file is already in `.gitignore` and will not be committed to the repository.

### GitHub Actions Setup

For GitHub Actions, add the following secrets to your repository:
1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add these repository secrets:
   - `ACCESS_TOKEN`
   - `REFRESH_TOKEN` 
   - `CLIENT_ID`
   - `CLIENT_SECRET`
   - `WAF_BYPASS_SECRET`

## 🐳 Docker Setup

### Quick Start with Docker

1. **Clone the repository and navigate to the project directory**

2. **Build the Docker image:**
   ```bash
   docker build --no-cache -t robotframework-tests .
   ```
   
   **Or use the interactive script which includes a build option:**
   ```bash
   ./docker-test.sh
   ```
   The interactive script provides a menu with options for building the Docker image and running tests.

### Docker Configuration

Docker-related files:

- **`Dockerfile`**: Multi-stage build with Playwright browsers and Robot Framework
- **`docker-config.sh`**: Shared configuration for cross-platform compatibility
- **`docker-test.sh`**: Interactive test runner with menu options
- **`docker-tasks.yaml`**: Task definitions for RCC (Robot Framework Control Center)

### Docker Environment

The Docker container is based on Microsoft's Playwright image and includes:
- **Ubuntu 24.04** with Finnish locale support
- **Python 3.12.3** with virtual environment
- **Node.js 22** with Playwright browsers
- **Robot Framework 7.3.2** with Browser library
- **Parallel execution support** via pabot

## 🏃‍♂️ Running Tests

### Interactive Docker Runner

Use the interactive script for easy test execution:

```bash
./docker-test.sh
```

This provides a menu with options for:
- **Parallel execution** (pabot) with configurable process counts
- **Sequential execution** (robot) for single-user scenarios
- **Individual test suites** or **all suites**
- **Docker image management** (build, clean)

### Manual Docker Commands

**⚠️ Important**: When running Docker commands manually, you must provide the required environment variables (especially `WAF_BYPASS_SECRET`) that are normally loaded by the `docker-config.sh` script.

**📧 Note**: Mail-related secrets (`ACCESS_TOKEN`, `REFRESH_TOKEN`, `CLIENT_ID`, `CLIENT_SECRET`) are automatically loaded from the mounted `.env` file and don't need to be passed as environment variables to Docker.

#### Option 1: Source docker-config.sh first (Recommended)

```bash
# Source the configuration script to load environment variables from .env file
source docker-config.sh

# Then run Docker with the loaded variables
docker run --rm \
  -e WAF_BYPASS_SECRET="$WAF_BYPASS_SECRET" \
  -v "$(pwd)/TestSuites:/opt/robotframework/tests" \
  -v "$(pwd)/output:/opt/robotframework/reports" \
  robotframework-tests \
  robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```



#### Running Complete Test Suites

**Windows (CMD):**
```cmd
# First source the config
source docker-config.sh

docker run --rm \
  -e WAF_BYPASS_SECRET="%WAF_BYPASS_SECRET%" \
  -v "%cd%\TestSuites:/opt/robotframework/tests" \
  -v "%cd%\output:/opt/robotframework/reports" \
  robotframework-tests \
  robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```

**Windows (PowerShell):**
```powershell
# First source the config
. docker-config.sh

docker run --rm `
  -e WAF_BYPASS_SECRET="$env:WAF_BYPASS_SECRET" `
  -v "${PWD}\TestSuites:/opt/robotframework/tests" `
  -v "${PWD}\output:/opt/robotframework/reports" `
  robotframework-tests `
  robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```

**Linux/Mac:**
```bash
# First source the config
source docker-config.sh

docker run --rm \
  -e WAF_BYPASS_SECRET="$WAF_BYPASS_SECRET" \
  -v "$(pwd)/TestSuites:/opt/robotframework/tests" \
  -v "$(pwd)/output:/opt/robotframework/reports" \
  robotframework-tests \
  robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```

#### Available Test Suites

- `Tests_user_desktop_FI.robot` - Desktop browser tests (includes recurring reservations)
- `Tests_user_mobile_iphone_FI.robot` - Mobile iPhone tests
- `Tests_user_mobile_android_FI.robot` - Mobile Android tests
- `Tests_users_with_admin_desktop.robot` - Combined user and admin tests
- `Tests_admin_desktop_FI.robot` - Admin user tests
- `Tests_admin_notifications_serial.robot` - Admin notification management (sequential only)

#### Parallel Execution

For faster execution, use pabot with multiple processes:

```bash
# First source the config
source docker-config.sh

docker run --rm \
  -e WAF_BYPASS_SECRET="$WAF_BYPASS_SECRET" \
  -v "$(pwd)/TestSuites:/opt/robotframework/tests" \
  -v "$(pwd)/output:/opt/robotframework/reports" \
  robotframework-tests \
  pabot --processes 4 --outputdir /opt/robotframework/reports /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

#### Running Individual Test Cases

To run a specific test case from a suite, add the test case name with the `-t` flag:

```bash
# First source the config
source docker-config.sh

docker run --rm \
  -e WAF_BYPASS_SECRET="$WAF_BYPASS_SECRET" \
  -v "$(pwd)/TestSuites:/opt/robotframework/tests" \
  -v "$(pwd)/output:/opt/robotframework/reports" \
  robotframework-tests \
  robot --outputdir /opt/robotframework/reports \
  -t "User logs in and out with suomi_fi" \
  /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

## 🔄 Parallel Testing

### User Isolation System

The project implements user isolation system for parallel testing using **PabotLib value sets**:

- **Deterministic user assignment** preventing conflicts in parallel execution
- **Two execution modes**: Parallel (unique users) and Single (shared user for debugging)
- **Value set-based isolation** with each test mapped to specific user data

### User Allocation by Test Suite

The user allocation is configured in `test_value_sets.dat` for parallel execution:

- **Desktop Suite**: 12 users (`desktop-test-data-set-0` to `desktop-test-data-set-11`)
- **Admin Suite**: 2 users (`admin-test-data-set-0` to `admin-test-data-set-1`)
- **Combined Suite**: 6 users (`combined-test-data-set-0` to `combined-test-data-set-5`)
- **Android Mobile**: 6 users (`mobile-android-data-set-0` to `mobile-android-data-set-5`)
- **iPhone Mobile**: 6 users (`mobile-iphone-data-set-0` to `mobile-iphone-data-set-5`)
- **Admin Notifications**: Sequential execution only (uses `FORCE_SINGLE_USER=True`)

### Process Configuration

Default process counts (configurable in `docker-config.sh`):
- **Desktop processes**: 8
- **Admin processes**: 2
- **Mobile processes**: 3
- **All suites processes**: 5

## 🎯 Test Data Management System

The project uses test data management system with **PabotLib value sets** to ensure test isolation:

### **Configuration Files**
- **`test_value_sets.dat`**: ConfigParser/INI format file containing user data for each test
- **`parallel_test_data.robot`**: Robot Framework keywords for test data initialization  
- **`suite_specific_units.robot`**: Suite-specific unit definitions for parallel isolation
- **`suite_unit_selector.robot`**: Dynamic unit assignment based on test suite type
- **`README_TEST_DATA_SYSTEM.md`**: Detailed documentation of the test data system

### **Key Features**
- **Deterministic Mapping**: Each test is mapped to a specific user (e.g., "User logs in" → desktop-test-data-set-0)
- **Conflict Prevention**: No two tests share the same user credentials in parallel execution
- **Debug-Friendly**: Single user mode available with `FORCE_SINGLE_USER=True`
- **Maintainable**: Easy to add new tests and users to the value sets

### **Usage Examples**

**Parallel Execution** (recommended):
```bash
pabot --processes 6 --pabotlib --resourcefile TestSuites/Resources/test_value_sets.dat TestSuites/Tests_user_desktop_FI.robot
```

**Single User Mode** (debugging):
```bash
robot --variable FORCE_SINGLE_USER:True TestSuites/Tests_user_desktop_FI.robot
```

## 📊 Test Coverage

The test suites cover various booking scenarios including:

- **Single bookings**: Free, paid, subvented, and non-cancelable reservations
- **Recurring reservations**: Multi-week booking applications with unit selection and application management
- **Payment flows**: Complete checkout processes with payment verification
- **Email verification**: Confirmation and cancellation email validation
- **Access codes**: Reservations requiring special access codes
- **Calendar integration**: ICS file download and validation
- **Mobile compatibility**: Touch-optimized interfaces for mobile devices
- **Admin functionality**: Notification management and reservation oversight
- **Smoke tests**: Critical functionality validation

### 📊 Test Execution Modes

#### **Parallel Mode**
Uses PabotLib value sets for isolated test execution:
- **Desktop Tests**: 12 parallel-enabled tests with dedicated users
- **Admin Tests**: 2 parallel-enabled tests with admin users  
- **Combined Tests**: 6 parallel-enabled user+admin workflow tests
- **Mobile Android**: 6 parallel-enabled mobile browser tests
- **Mobile iPhone**: 6 parallel-enabled iOS Safari tests
- **Total Parallel Tests**: **32 tests** with complete user isolation

#### **Sequential Mode**
For tests requiring serialized execution:
- **Admin Notifications**: All tests run sequentially with `FORCE_SINGLE_USER=True`
- **Single User**: All tests use the same user (Ande AutomaatioTesteri)



## 📈 Test Reports

After running tests, reports are generated in the `output` directory:

- `report.html` - HTML report with test results summary
- `log.html` - Detailed log of test execution
- `output.xml` - XML output containing all test data
- `screenshots/` - Captured screenshots from test failures

To view the reports, open the `report.html` HTML file in your browser after test execution completes.

## 🚀 GitHub Actions

This project includes GitHub Actions workflow that automatically runs tests when:

- Manually triggered via the GitHub Actions UI

### Manual Test Execution

To manually run tests via GitHub Actions:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Varaamo Robot Framework Tests" workflow
3. Click "Run workflow"
4. Select which test suite you want to run from the dropdown menu
5. Choose execution mode (parallel or sequential)
6. Click "Run workflow"

### Workflow Features

- **Configurable test suites**: Choose from individual suites or run all
- **Execution modes**: Parallel (pabot) or sequential (robot)
- **Smoke test validation**: For "All" option, runs smoke tests first
- **Docker caching**: Optimized builds with GitHub Actions cache
- **Artifact uploads**: Test reports available as downloadable artifacts
- **Comprehensive reporting**: Detailed test results and failure analysis

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
│   │   ├── test_value_sets.dat         # PabotLib value sets with user data for parallel execution
│   │   ├── token_manager.py            # Token management utilities
│   │   ├── users.robot                 # User management and assignment
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
├── Dockerfile                          # Docker configuration
├── docker-config.sh                    # Shared Docker configuration
├── docker-test.sh                      # Interactive Docker test runner
├── docker-tasks.yaml                   # RCC task definitions
├── requirements.txt                    # Python dependencies
├── conda.yaml                          # Conda environment configuration
├── robot.yaml                          # RCC configuration
├── har_analyzer.py                     # HAR file analysis utilities
└── PARALLEL_SETUP_GUIDE.md             # Detailed parallel testing setup guide
```

## WIP 🛠️ Local Development WIP

### Using RCC (Recommended)

This project is configured for RCC (Robocorp Control Center) with environment management via `conda.yaml`:

1. **Install RCC:**
   ```bash
   # macOS
   brew install robocorp/tools/rcc
   
   # Other platforms: Download from https://github.com/robocorp/rcc/releases
   ```

2. **Run tasks using RCC:**
   ```bash
   # List available tasks
   rcc task list
   
   # Run specific test suite
   rcc task run --task "Test Desktop Parallel"
   ```

**Note:** RCC automatically manages the Python environment based on `conda.yaml` and `robot.yaml` configurations.

### Manual Setup

For manual setup without RCC (requires more configuration):

1. **Create conda environment:**
   ```bash
   conda env create -f conda.yaml
   conda activate robotframework-tests
   ```

2. **Initialize Playwright browsers:**
   ```bash
   rfbrowser init
   ```

3. **Configure environment variables:**
   ```bash
   cp TestSuites/Resources/.env.sample TestSuites/Resources/.env
   # Edit .env with your values
   ```

4. **Run tests:**
   ```bash
   robot TestSuites/Tests_user_desktop_FI.robot
   ```

## WIP 🔧 Troubleshooting WIP
---

### HAR Recording Control

HAR files can be recorded during test execution for network traffic analysis:

**Enable/Disable HAR Recording:**
```robot
# In TestSuites/Resources/variables.robot
${ENABLE_HAR_RECORDING}    ${TRUE}  # Set to ${FALSE} to disable
```

**HAR File Location:**
- HAR files are saved to `output/har_files/` directory
- Files can be very large (10-100MB+ per test)
- Only enable when you need to analyze network traffic

**Analyze HAR Files:**
```bash
python har_analyzer.py
```

**Note:** HAR recording is disabled by default to improve performance. Only enable when debugging network issues.


### Environment Variables

Ensure all required environment variables are set:
- `ACCESS_TOKEN`
- `REFRESH_TOKEN`
- `CLIENT_ID`
- `CLIENT_SECRET`
- `WAF_BYPASS_SECRET`


## 📚 Additional Resources

- [TestSuites/Resources/README_TEST_DATA_SYSTEM.md](TestSuites/Resources/README_TEST_DATA_SYSTEM.md) - Comprehensive test data system documentation
- [PARALLEL_SETUP_GUIDE.md](PARALLEL_SETUP_GUIDE.md) - Detailed guide for parallel testing configuration  
- [Robot Framework Documentation](https://docs.robotframework.org/)
- [Robot Framework Browser Library](https://marketsquare.github.io/robotframework-browser/Browser.html)
- [Playwright Documentation](https://playwright.dev/)
- [PabotLib Documentation](https://pabot.org/) - Parallel execution library


## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
