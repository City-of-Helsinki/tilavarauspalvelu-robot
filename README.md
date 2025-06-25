# Varaamo Robot Framework Tests

This repository contains automated test suites for the Varaamo booking system using Robot Framework with the Browser Library (Playwright).

## Prerequisites

- Docker installed

> **Note:** This project uses Docker for easy setup and execution. If you prefer to install Robot Framework manually, please refer to the [official Robot Framework installation guide](https://docs.robotframework.org/docs/getting_started/testing#install-robot-framework).

## Local Setup

1. Clone the repository and navigate to the project directory

2. Build the Docker image:
   ```
   docker build --no-cache -t robotframework-tests .
   ```

## Running Tests

### Running Complete Test Suites

To run an entire test suite, use the following command pattern:

**Windows (CMD):**

```
docker run --rm -v "%cd%\TestSuites:/opt/robotframework/tests" -v "%cd%\Reports:/opt/robotframework/reports" robotframework-tests robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```

**Windows (PowerShell):**

```
docker run --rm -v "${PWD}\TestSuites:/opt/robotframework/tests" -v "${PWD}\Reports:/opt/robotframework/reports" robotframework-tests robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```

**Linux/Mac:**

```
docker run --rm -v "$(pwd)/TestSuites:/opt/robotframework/tests" -v "$(pwd)/Reports:/opt/robotframework/reports" robotframework-tests robot --outputdir /opt/robotframework/reports /opt/robotframework/tests
```

Available test suites:

- `Tests_user_desktop_FI.robot` - Desktop browser tests (includes recurring reservations)
- `Tests_user_mobile_iphone_FI.robot` - Mobile iPhone tests
- `Tests_user_mobile_android_FI.robot` - Mobile Android tests
- `Tests_users_with_admin_desktop.robot` - Combined user and admin tests
- `Tests_admin_desktop_FI.robot` - Admin user tests

### Test Coverage

The test suites cover various booking scenarios including:

- **Single bookings**: Free, paid, subvented, and non-cancelable reservations
- **Recurring reservations**: Multi-week booking applications with unit selection and application management
- **Payment flows**: Complete checkout processes with payment verification
- **Email verification**: Confirmation and cancellation email validation
- **Access codes**: Reservations requiring special access codes
- **Calendar integration**: ICS file download and validation
- **Mobile compatibility**: Touch-optimized interfaces for mobile devices
- **Admin functionality**: Notification management and reservation oversight

Example:

```
docker run --rm -v "%cd%\TestSuites:/opt/robotframework/tests" -v "%cd%\Reports:/opt/robotframework/reports" robotframework-tests robot --outputdir /opt/robotframework/reports /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

### Running Individual Test Cases

To run a specific test case from a suite, add the test case name with the `-t` flag:

```
docker run --rm -v "%cd%\TestSuites:/opt/robotframework/tests" -v "%cd%\Reports:/opt/robotframework/reports" robotframework-tests robot --outputdir /opt/robotframework/reports -t "User logs in and out with suomi_fi" /opt/robotframework/tests/Tests_user_desktop_FI.robot
```

## Test Reports

After running tests, reports are generated in the `Reports` directory:

- `report.html` - HTML report with test results summary
- `log.html` - Detailed log of test execution
- `output.xml` - XML output containing all test data

To view the reports, open the `report.html` HTML file in your browser after test execution completes.

For failed tests, screenshots are automatically captured and included in the reports.

## GitHub Actions

This project includes GitHub Actions workflows that automatically run tests when:

- Code is pushed to the main branch
- Manually triggered via the GitHub Actions UI

To manually run tests via GitHub Actions:

1. Go to the "Actions" tab in your GitHub repository
2. Select the "Varaamo Robot Framework Tests" workflow
3. Click "Run workflow"
4. Select which test suite you want to run from the dropdown menu
5. Click "Run workflow"

The workflow will execute the selected tests and make the reports available as downloadable artifacts.

## Project Structure

```
.
├── .github/
│   └── workflows/                      # GitHub Actions workflows
│       └── testing.yaml                # CI/CD workflow with test suite selection options
├── TestSuites/                         # Test suite directory
│   ├── PO/                             # Page Objects (PO) for separation of test logic and UI elements
│   │   ├── Admin/                      # Admin interface page objects
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
│   │   │   └── popups.robot            # Popup handling (cookies, confirmations)
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
│   │   └── data_modification.robot     # Data manipulation utilities
│   ├── Tests_user_desktop_FI.robot     # Desktop browser tests (includes recurring reservations)
│   ├── Tests_admin_desktop_FI.robot    # Admin UI tests
│   ├── Tests_user_mobile_android_FI.robot # Mobile Chrome tests for Android
│   └── Tests_users_with_admin_desktop.robot # Combined user/admin workflow tests
├── Reports/                           # Test reports (created at runtime)
│   ├── log.html                       # Detailed execution logs
│   ├── report.html                    # Test result summary
│   ├── output.xml
│   └── screenshots/                   # Captured screenshots from test failures
└── Dockerfile                         # Docker configuration 
```

## Troubleshooting

### Browser Crashes

If browser tests crash, increase the shared memory size:

--shm-size=4g or --shm-size=2g

```
docker run --rm --shm-size=4g -v "%cd%\TestSuites:/opt/robotframework/tests" -v "%cd%\Reports:/opt/robotframework/reports" robotframework-tests robot --outputdir /opt/robotframework/reports /opt/robotframework/tests/Tests_user_desktop_FI.robot
```
