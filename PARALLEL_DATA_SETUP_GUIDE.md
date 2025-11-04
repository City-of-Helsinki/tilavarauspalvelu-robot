# Parallel Test Data Setup Guide

## 🎯 Overview

The Varaamo test framework uses **tag-based data distribution** to ensure each parallel test gets unique user data, preventing conflicts and enabling reliable parallel execution.

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
   ┌─────┐  ┌─────────┐
   │Lock │  │ Basic   │
   │Value│  │ Users   │
   │ Set │  │ Fallback│
   └──┬──┘  └────┬────┘
      │          │
      └────┬─────┘
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

### Parallel Mode (Default)
```
Test Case → Tags → PabotLib Value Set → Unique User Data
```

1. **Test starts** with tags: `[Tags] desktop-test-data-set-4 desktop-suite`
2. **Complete Test Setup From Tags** is called
3. **Suite units initialized** from tags (loads suite-specific units based on `desktop-suite` tag)
4. **System reads data set tag** and finds: `desktop-test-data-set-4`
5. **PabotLib acquires** the value set (reserves it for this test)
6. **User variables loaded** from `test_value_sets.dat` file: email, name, password, etc.
7. **Test runs** with isolated data (both units and users)

### Single Mode (Fallback)
```
Test Case → Tags → Basic Users from users.robot
```

1. **Same tag setup** as parallel mode
2. **Complete Test Setup From Tags** is called
3. **Suite units initialized** from tags (same as parallel mode)
4. **PabotLib unavailable** → Falls back to basic users
5. **Default users loaded**:
   - User tests: Ande AutomaatioTesteri
   - Admin tests: Tirehtoori Tötterstrom + Kari Kekkonen
   - Permission tests: Marika Salminen + Kari Kekkonen

## 📋 Required Tags

Each test needs **2 tags**:

### 1. Data Set Tag
Specifies which user data to use:
- `desktop-test-data-set-0` through `desktop-test-data-set-11` (12 users)
- `admin-test-data-set-0` through `admin-test-data-set-2` (3 admins)
- `combined-test-data-set-0` through `combined-test-data-set-1` (2 combined)
- `mobile-android-data-set-0` through `mobile-android-data-set-5` (6 Android)
- `mobile-iphone-data-set-0` through `mobile-iphone-data-set-5` (6 iPhone)

### 2. Suite Type Tag
Specifies which test environment to load:
- `desktop-suite` - Desktop user tests
- `admin-suite` - Admin tests  
- `combined-suite` - Admin+user tests
- `android-suite` - Android mobile tests
- `iphone-suite` - iPhone mobile tests

## 📝 Usage Examples

### Desktop User Test
```robot
User logs in and out with suomi_fi
    [Tags]    desktop-test-data-set-0    desktop-suite    smoke
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User logs in with suomi_fi
    app_common.User logs out
```

## 🆕 Adding New Tests

### Step 1: Choose Data Set
Pick an available data set from `test_value_sets.dat`:
- Desktop: `desktop-test-data-set-0` to `desktop-test-data-set-11`
- Admin: `admin-test-data-set-0` to `admin-test-data-set-2`
- Combined: `combined-test-data-set-0` to `combined-test-data-set-1`

### Step 2: Add Tags
```robot
Your New Test
    [Tags]    desktop-test-data-set-5    desktop-suite    your-feature
    common_setups_teardowns.Complete Test Setup From Tags
    # ... your test steps ...
```

## ➕ Adding New Data Sets

Need more users? Add new data sets to `test_value_sets.dat`:

**Example:**
```ini
[desktop-test-data-set-12]
# TEST: "User makes recurring booking"
tags=desktop-test-data-set-12,desktop-test-data,user-data,desktop-suite,recurring-booking
CURRENT_USER_EMAIL=qfaksi+recurring12@gmail.com
CURRENT_USER_HETU=123456-789B
CURRENT_USER_PHONE=+35840123699
CURRENT_USER_FIRST_NAME=Recurring
CURRENT_USER_LAST_NAME=Tester
CURRENT_USER_FULLNAME=Recurring Tester
CURRENT_PASSWORD=User
```

Then use it: `[Tags] desktop-test-data-set-12 desktop-suite`


## 🔍 Data Set Reference

| Suite Type | Data Sets | Users Available |
|------------|-----------|-----------------|
| Desktop User | `desktop-test-data-set-0` to `desktop-test-data-set-11` | 12 unique users |
| Admin | `admin-test-data-set-0` to `admin-test-data-set-2` | 3 unique admins |
| Combined | `combined-test-data-set-0` to `combined-test-data-set-1` | 2 user+admin pairs |
| Android | `mobile-android-data-set-0` to `mobile-android-data-set-5` | 6 unique users |
| iPhone | `mobile-iphone-data-set-0` to `mobile-iphone-data-set-5` | 6 unique users |

## 🐛 Troubleshooting
- WIP

## 📁 Key Files

- **`test_value_sets.dat`** - Contains all user data sets
- **`users.robot`** - Fallback users for single mode
- **`parallel_test_data.robot`** - Data initialization logic
- **`suite_unit_selector.robot`** - Unit initialization logic
- **`common_setups_teardowns.robot`** - Universal setup keyword