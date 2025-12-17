# Test Architecture & Coverage

This document provides detailed information about the test suite architecture, coverage, and execution modes.

## 📊 Test Coverage

The test suites cover various booking scenarios including:

- **Single bookings**: Free, paid, subvented, and non-cancellable reservations
- **Recurring reservations**: Multi-week booking applications with unit selection and application management
- **Payment flows**: Complete checkout processes with payment verification
- **Email verification**: Confirmation and cancellation email validation
- **Access codes**: Reservations requiring special access codes
- **Calendar integration**: ICS file download and validation
- **Mobile compatibility**: Touch-optimized interfaces for mobile devices
- **Admin functionality**: Notification management and reservation oversight
- **Smoke tests**: Critical functionality validation

## 📊 Test Distribution

- **Total Parallel Tests**: 31 tests with complete user isolation
  - Desktop: 11 tests | Admin: 5 tests | Combined: 3 tests
  - Mobile Android: 6 tests | Mobile iPhone: 6 tests
- **Serial Tests**: 4 tests (admin notifications - must run serially)

### Page Object Structure

The test suites use a Page Object Model (POM):

- **`PO/Admin/`** - Admin interface page objects
- **`PO/App/`** - Application-specific page objects
- **`PO/Common/`** - Shared UI components and patterns
- **`PO/User/`** - User interface page objects

## Test Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        SUITE SETUP (Once)                       │
├─────────────────────────────────────────────────────────────────┤
│ 1. Create Robot Test Data (Resources/create_data.robot)         │
│    • API POST to application backend test data endpoint         │
│    • Token authentication (X-Robot-API-Secret)                  │
│    • Creates all users, reservation units, reservations, and    │
│      all needed test data                                       │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     TEST SETUP (Per Test)                       │
├─────────────────────────────────────────────────────────────────┤
│ 2. Browser Initialization (devices.robot)                       │
│    • Apply staggered startup (8s * pool_id + random 2-4s)       │
│    • Available browsers/devices:                                │
│      - Chromium Desktop (1440x900)                              │
│      - Firefox Desktop (1440x900, for permission tests -        │
│        separate session from Django admin and Admin UI)         │
│      - iPhone WebKit (390x664)                                  │
│      - Android Chromium (393x727)                               │
│    • Create browser with args (example: no-sandbox, headless)   │
│    • Apply WAF bypass headers (X-Test-Secret) to bypass         │
│      Application Gateway traffic limits                         │
│    • Create context (viewport, locale, HAR recording)           │
│    • Create new page                                            │
│                                                                 │
│ 3. First Navigation Gate (Parallel Coordination)                │
│    • First worker: Navigate + wait for networkidle              │
│    • Other workers: Wait with jitter (0.8-1.6s)                 │
│    • Navigate to ${URL_TEST}                                    │
│    • Wait for load state                                        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                    TEST EXECUTION (Per Test)                    │
├─────────────────────────────────────────────────────────────────┤
│ 4. Complete Test Setup From Tags                                │
│    (common_setups_teardowns.robot)                              │
│    • Initialize suite units from tags:                          │
│      (suite_unit_selector.robot)                                │
│      Examples: desktop-suite, admin-suite, android-suite,       │
│      iphone-suite                                               │
│    • Initialize test data from tags (assign user from pool):    │
│      (parallel_test_data.robot)                                 │
│      Examples: desktop-test-data-set-0, admin-test-data-set-1,  │
│      mobile-android-data-set-1, mobile-iphone-data-set-2        │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     EXECUTE TEST STEPS                          │
├─────────────────────────────────────────────────────────────────┤
│ 5. Run Test Actions                                             │
│    • Login, navigate, interact, verify                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                   TEST TEARDOWN (Per Test)                      │
├─────────────────────────────────────────────────────────────────┤
│ 6. Cleanup (common_setups_teardowns.robot)                      │
│    • Take screenshot if test failed                             │
│    • Release test data (return user to pool)                    │
│    • Close browser                                              │
└─────────────────────────────────────────────────────────────────┘
```

## Test Data Management

### API-Based Data Creation (Resources/create_data.robot)

Test data is created once per suite via API endpoint during Suite Setup:
- Creates all users, reservation units, and initial reservations

### GraphQL-Based Cleanup (Resources/graphql_commands.robot)

Admin notification tests require cleanup to handle **phantom notifications** - leftover notifications from failed test runs that can interfere with new tests.

**Cleanup Process:**
1. **Draft all notifications** - Sets all existing banner notifications to DRAFT state
2. **Delete by pattern** - Removes notifications matching `${NOTIFICATION_BANNER_CLEANUP_PATTERN}` variable (set to "ROBOVIESTI" in `texts_FI.robot`)

**Why it's needed:**
- If a test fails mid-execution, it may leave active notifications in the system
- These phantom notifications can cause subsequent test runs to fail
- Pattern-based deletion ensures only robot test notifications are removed, not other test data
- The cleanup pattern "ROBOVIESTI" identifies notifications created by robot tests

**Used in:** `Tests_admin_notifications_serial.robot` for admin notification management tests

## Parallel Execution Coordination Details

### Staggered Startup Strategy

**Why it's needed:**
- Prevents resource conflicts and browser crashes when multiple workers start simultaneously
- Reduces memory spikes and CPU contention during parallel test initialization
- Avoids race conditions in browser driver initialization

**Progressive pattern:**
- Worker 0: 2-4s delay
- Worker 1: 10-12s delay (8s base + 2-4s random)
- Worker 2: 18-20s delay (16s base + 2-4s random)
- Worker 3: 26-28s delay (24s base + 2-4s random)
- Formula: `(pool_id * 8) + random(2.0, 4.0)` seconds

**Single execution fallback:**
- When running tests serially (no pabot), uses 0.5-1.5s random delay
- Prevents system resource conflicts even in single-worker mode

### First Navigation Gate

**Why it exists:**
- Ensures CSRF token is properly bootstrapped before parallel test execution
- Prevents race conditions when multiple workers hit the server simultaneously
- Reduces server load by coordinating initial page loads

**Lock mechanism:**
- Uses PabotLib's `FIRST_NAV_BOOTSTRAP` lock for coordination
- Stores completion state in shared `FIRST_NAV_DONE` flag

**How it works:**
1. **First worker** (wins the lock race):
   - Acquires `FIRST_NAV_BOOTSTRAP` lock
   - Navigates to the test URL
   - Waits for `networkidle` state (ensures all initial requests complete)
   - Adds 0.6-0.9s post-navigation delay
   - Sets `FIRST_NAV_DONE` flag to `true`
   - Releases lock
2. **Subsequent workers** (arrive after flag is set):
   - Check `FIRST_NAV_DONE` flag
   - Wait with jitter (0.8-1.6s random delay)
   - Navigate normally with 30s load timeout

## Dynamic Test Data Handling Examples

## Mail Test Synchronization

The email verification test uses a lock-based synchronization mechanism to ensure proper test execution order:

1. **Paid Booking Test** (`User can make paid single booking`) runs first:
   - Acquires `PAID_BOOKING_EMAIL_SEQUENCE` lock
   - Creates a paid reservation and cancels it
   - Stores booking data (booking number, time, unit name) in shared test data
   - Marks test as completed and releases lock

2. **Email Verification Test** (`Check emails from reservations`) runs after:
   - Waits for paid booking test completion (with timeout)
   - Skips if paid booking test failed or didn't run
   - Retrieves stored booking number from paid booking test
   - Verifies reservation confirmation and cancellation emails exist in backend cache

**Note:** Previously, mail tests directly accessed Gmail to verify sent emails. Paid reservations were used because they contained all possible email types: confirmation emails, cancellation emails, payment receipts, and refund receipts. Now the system checks the **backend cache** instead, eliminating the need for Gmail access and making tests more reliable. However, the backend cache currently **does not support receipt emails from Verkkokauppa** (payment provider), so payment and refund receipts are not verified in the current implementation anymore.

## Reservation Time Management

Tests dynamically capture and format reservation times to verify booking details across multiple locations. This process ensures consistency when validating reservations in the UI, emails, and booking lists.

### Time Capture and Formatting Process

```
1. User Selects Time Slot (app_user.robot)
   └─> Select duration (e.g., 60 minutes)
   └─> Open date picker calendar
   └─> Get current date value (e.g., "5.12.2023")
   └─> Select available free time slot (e.g., "11:30" or "11.30")
   └─> Store raw time slot in ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}

2. Format Times (data_modification.robot: Set Info Card Duration Time Info)
   └─> Parse date: "5.12.2023" → day=5, month=12, year=2023
   └─> Parse time: "11.30" or "11:30" → hour=11, minute=30
   └─> Calculate end time: hour + 1 (assumes 60min duration) → 12:30
   └─> Get Finnish day name: "Ti" (Tuesday)
   └─> Format into Finnish format:
       • ${TIME_OF_QUICK_RESERVATION}:
         "Ti 5.12.2023 klo 11:30–12:30, 1 t"
       • ${TIME_OF_QUICK_RESERVATION_MINUS_T}:
         "Ti 5.12.2023 klo 11:30–12:30"

3. Store Formatted Times
   └─> Store in Test Data Variables (shared across parallel tests)
   └─> Store in Test Variables (local to current test)
```

### Usage of Formatted Times

The formatted time variables are used throughout tests for verification. Examples:
- **Reservation confirmation pages** - Check booking details match selected time
- **My Bookings list** - Verify reservation appears with correct time
- **Email notifications** - Confirm reservation and cancellation emails contain correct time
- **Modified bookings** - Validate time changes after modification
- **Cancelled bookings** - Verify cancelled reservation shows original time

**Note:** The formatting assumes **1-hour (60 minute) reservation duration**, which is hardcoded in the `Set Info Card Duration Time Info` keyword. The end time is calculated as start time + 1 hour.

## Admin-Side Data Formatting

In combined user/admin tests, reservation data must be formatted for admin UI verification and search operations.

### Flow: User Creates → Format for Admin → Admin Searches & Verifies

**Context**: Combined tests where user creates reservation, then admin processes it

```
1. User Creates Reservation (during test run)
   └─> Booking number captured dynamically: ${BOOKING_NUM_ONLY}
   └─> Reservation time captured dynamically: ${TIME_OF_QUICK_RESERVATION}
   └─> Unit with location from test data: ${CURRENT_UNIT_WITH_LOCATION}

2. Format for Admin Side (TestSuites/Resources/data_modification.robot)
   
   A. Format Reservation Number And Name (line 15)
      Input:
        • ${BOOKING_NUM_ONLY}: "12345678"
        • ${SINGLEBOOKING_NAME}: "John Doe"
      
      Process:
        └─> Concatenate: "${BOOKING_NUM_ONLY}, ${SINGLEBOOKING_NAME}"
      
      Output: ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
        "12345678, John Doe"
   
   B. Format Tagline For Admin Side (line 20)
      Input:
        • ${TIME_OF_QUICK_RESERVATION}: "Ti 5.12.2023 klo 11:30–12:30, 1 t"
        • ${UNIT_WITH_LOCATION}: "Harakka, piilokoju"
      
      Process:
        └─> Strip whitespace from time
        └─> Concatenate: "${TIME} | ${UNIT_WITH_LOCATION}"
        └─> Normalize spaces (multiple → single)
      
      Output: ${RESERVATION_TAGLINE}
        "Ti 5.12.2023 klo 11:30–12:30, 1 t | Harakka, piilokoju"

3. Admin Searches and Verifies
   └─> Search by: ${BOOKING_NUM_ONLY}
   └─> Click from name: ${CURRENT_USER_FULLNAME}
   └─> Verify tagline matches: ${RESERVATION_TAGLINE}
```

### Usage Example

From `Tests_users_with_admin_desktop.robot`:

```robot
# User creates subvented reservation requiring handling
User Creates Reservation...

# Format data for admin verification
Formats Reservation Number And Name For Admin Side
Formats Tagline For Admin Side
    ${TIME_OF_QUICK_RESERVATION}
    ${CURRENT_UNIT_WITH_LOCATION}

# Admin searches using formatted data
Admin Searches Reservation With Id Number And Clicks It From Name
    ${BOOKING_NUM_ONLY}
    ${CURRENT_USER_FULLNAME}

# Admin verifies reservation details using formatted variables
Admin Checks Reservation H1    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
Admin Checks Reservation Title Tagline    ${RESERVATION_TAGLINE}
```

## 📚 Additional Resources

- [PARALLEL_DATA_SETUP_GUIDE.md](PARALLEL_DATA_SETUP_GUIDE.md) - Detailed guide for parallel testing configuration  
- [Robot Framework Documentation](https://docs.robotframework.org/)
- [Robot Framework Browser Library](https://marketsquare.github.io/robotframework-browser/Browser.html)
- [PabotLib Documentation](https://pabot.org/) - Parallel execution library
