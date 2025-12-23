# Parallel Test Data Setup Guide

> **📖 This is the guide for parallel testing.** For a quick overview, see [README.md](README.md). This guide covers all technical details, flow diagrams, tag requirements, and how to add new tests or data sets.

## 🎯 Overview

The Varaamo test framework uses **tag-based data distribution** to ensure each parallel test gets unique user data, preventing conflicts and enabling reliable parallel execution.

### Key Logic Files

The parallel testing system relies on three core files:

- **`parallel_test_data.robot`** - Decides which user data file to use based on execution context (parallel vs sequential)
- **`suite_unit_selector.robot`** - Unit initialization logic (determines which test units/spaces to use)
- **`common_setups_teardowns.robot`** - Universal setup keyword that orchestrates the initialization flow

## 🔄 How Data Setup Works

### Flow Diagram
```
┌─────────────────────┐
│  Test Case Starts   │
│  with Tags          │
└──────────┬──────────┘
           │
           ▼
┌──────────────────────┐
│ Complete Test Setup  │
│    From Tags         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ 1. Initialize        │
│    Suite Units       │
│ (from suite tag)     │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ 2. Initialize        │
│    Test Data         │
│ (from data set tag)  │
└──────────┬───────────┘
           │
           ▼
    ┌──────────────┐
    │  PabotLib    │
    │ Available?   │
    └──┬────────┬──┘
       │        │
    Yes│        │No
       ▼        ▼
   ┌──────────────────┐  ┌──────────────────────┐
   │ Acquire          │  │ Shared Users         │
   │ Value Set        │  │ (Fallback)           │
   │ from             │  │ from                 │
   │ pabot_users.dat  │  │ serial_users.robot   │
   └──┬───────────────┘  └──────┬───────────────┘
      │                         │
      └────────────┬────────────┘
           │
           ▼
   ┌──────────────────┐
   │ All Variables Set│
   └─────────┬────────┘
             │
             ▼
   ┌──────────────────┐
   │ Test Executes    │
   └─────────┬────────┘
             │
             ▼
   ┌──────────────────┐
   │ Release & Cleanup│
   └──────────────────┘
```

### Execution Modes

The system supports two execution modes (see flow diagram above for visual representation):

**Parallel Mode** 🚀
- **Command**: `pabot --pabotlib --resourcefile pabot_users.dat --processes N`
- **User Data Source**: `pabot_users.dat` (INI format with value sets)
- **Behavior**: Each test gets a unique user from 31+ available data sets
- **Use Case**: CI/CD, fast execution

**Sequential Mode** 🌐
- **Command**: `robot` (or `robot --variable FORCE_SINGLE_USER:True`)
- **User Data Source**: `serial_users.robot` (Robot Framework variables)
- **Behavior**: All tests share the same 4 hardcoded users
- **Shared Users**: Ande AutomaatioTesteri (user), Tirehtoori Tötterstrom + Kari Kekkonen (admin), Marika Salminen (permissions)
- **Use Case**: Code editor debugging, single test runs, local development

**Automatic Fallback**: The system automatically uses `serial_users.robot` when:
- Running with `robot` command instead of `pabot`
- `FORCE_SINGLE_USER=True` is set
- PabotLib value set acquisition fails
- PabotLib is unavailable

## 📋 Required Tags

Each test needs **at least 2 tags** (Data Set Tag and Suite Type Tag):

### 1. Data Set Tag (REQUIRED)
**Purpose**: Links the test to a specific user data set in `pabot_users.dat`

**You need BOTH locations for parallel execution to work:**

1. **Test Tag** (in `.robot` file): `[Tags] admin-test-data-set-1 admin-suite`
   - Declares which data set the test needs
   - The code reads this tag and extracts `admin-test-data-set-1`
   - This becomes the value set name to request from PabotLib

2. **Value Set Tag** (in `pabot_users.dat`): `tags=admin-test-data-set-1`
   - Allows PabotLib to match and find the value set
   - When `Acquire Value Set admin-test-data-set-1` is called, PabotLib searches for value sets with this tag
   - **Without this tag**, PabotLib returns: `ValueError: No value set matching given tags exists`

**How it works**: When a test runs, the system:
1. Reads the data set tag from the test's `[Tags]` line (e.g., `admin-test-data-set-1`)
2. Calls `Acquire Value Set admin-test-data-set-1` to request the value set from PabotLib
3. PabotLib matches the request against value sets in `pabot_users.dat` that have `tags=admin-test-data-set-1`
4. If found, loads the user data (email, HETU, name, etc.) for that test
5. If not found, falls back to single user mode with shared users

**Available data set tags**:

| Suite Type | Data Sets | Users Available |
|------------|-----------|-----------------|
| Desktop User | `desktop-test-data-set-0` to `desktop-test-data-set-11` | 11 unique users (set-6 is unused) |
| Admin | `admin-test-data-set-0` to `admin-test-data-set-4` | 5 unique admins |
| Combined | `combined-test-data-set-0` to `combined-test-data-set-2` | 3 user+admin pairs |
| Android | `mobile-android-data-set-0` to `mobile-android-data-set-5` | 6 unique users |
| iPhone | `mobile-iphone-data-set-0` to `mobile-iphone-data-set-5` | 6 unique users |

### 2. Suite Type Tag (REQUIRED)
**Purpose**: Tells the system which test units to use for the test

**How it works**: The system uses this tag to:
1. Determine which suite-specific units to use
2. Set the unit variables that tests reference (e.g., `CURRENT_ALWAYS_FREE_UNIT`, `CURRENT_ALWAYS_PAID_UNIT`) - each suite type maps to different unit names:
   - `desktop-suite`: "Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA)"
   - `android-suite`: "Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA) (android)"
   - `iphone-suite`: "Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone)"

**Available suite type tags**:
- `desktop-suite` - Desktop browser tests for regular users
- `admin-suite` - Desktop browser tests for admin users
- `combined-suite` - Tests requiring both user and admin accounts
- `android-suite` - Mobile browser tests on Android emulation
- `iphone-suite` - Mobile browser tests on iPhone emulation

### 3. Permission Test Tag (Required only for permission tests)
**Purpose**: Determines which admin user's permissions will be modified

**How it works**: The system uses this tag to select the correct permission target admin:
- `general-permissions-test` - Tests general admin role changes
- `unit-permissions-test` - Tests unit-specific permission changes
- `unit-group-permissions-test` - Tests unit group permission changes

**Execution mode tags**:
- `serialonly` - Forces test to run in serial mode only (excluded from parallel runs)
  - **Why**: Used for notification tests (`Tests_admin_notifications_serial.robot`) because these tests cannot handle being run in parallel when creating notifications simultaneously
  - **Behavior**: Tests with this tag are automatically excluded from parallel execution (`pabot --exclude serialonly`)
- `smoke` - Basic smoke test marker (used in CI/CD workflows for filtering)
  - **Why**: Gates GitHub Actions workflow execution - if smoke tests fail, other tests do not run
  - **Behavior**: Used in CI/CD to validate basic functionality before running full test suites

## 📝 Usage Examples

### Desktop User Test
```robot
User logs in and out with suomi_fi
    [Tags]    desktop-test-data-set-0    desktop-suite    smoke
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User logs in with suomi_fi
    app_common.User logs out
```

## ➕ Adding New Data Sets

Need more users? Add new data sets to `pabot_users.dat`:

**Example:**
```ini
[desktop-test-data-set-12]
# TEST: "User makes recurring booking"
tags=desktop-test-data-set-12
CURRENT_USER_EMAIL=qfaksi+recurring12@gmail.com
CURRENT_USER_HETU=123456-789B
CURRENT_USER_PHONE=+35840123699
CURRENT_USER_FIRST_NAME=Recurring
CURRENT_USER_LAST_NAME=Tester
CURRENT_USER_FULLNAME=Recurring Tester
CURRENT_PASSWORD=User
```

Then add a test case in the appropriate test suite file (e.g., `Tests_user_desktop_FI.robot`):

```robot
Your New Test
    [Tags]    desktop-test-data-set-12    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    # ... your test steps ...
```

**Summary - Two-Step Tag Matching:**
1. **Test declares need**: `[Tags] desktop-test-data-set-12` → Code extracts `desktop-test-data-set-12`
2. **PabotLib finds match**: Searches `pabot_users.dat` for value set with `tags=desktop-test-data-set-12`
3. **If both match**: Value set is acquired and user data is loaded ✅
4. **If either missing**: Falls back to single user mode ⚠️

## 🐛 Troubleshooting

### Common Issues