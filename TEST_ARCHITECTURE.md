# Test Architecture & Coverage

This document provides detailed information about the test suite architecture, coverage, and execution modes.

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

## 📊 Test Execution Modes

### **Parallel Mode**
Uses PabotLib value sets for isolated test execution:
- **Desktop Tests**: 12 parallel-enabled tests with dedicated users
- **Admin Tests**: 2 parallel-enabled tests with admin users  
- **Combined Tests**: 6 parallel-enabled user+admin workflow tests
- **Mobile Android**: 6 parallel-enabled mobile browser tests
- **Mobile iPhone**: 6 parallel-enabled iOS Safari tests
- **Total Parallel Tests**: **32 tests** with complete user isolation

### **Sequential Mode**
For tests requiring serialized execution:
- **Admin Notifications**: All tests run sequentially with `FORCE_SINGLE_USER=True`
- **Single User**: All tests use the same user (Ande AutomaatioTesteri)

## 🔄 Parallel Execution Architecture

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

## 🎯 Test Data Management System

The project uses test data management system with **PabotLib value sets** to ensure test isolation:

### **Configuration Files**
- **`test_value_sets.dat`**: ConfigParser/INI format file containing user data for each test
- **`parallel_test_data.robot`**: Robot Framework keywords for test data initialization  
- **`suite_specific_units.robot`**: Suite-specific unit definitions for parallel isolation
- **`suite_unit_selector.robot`**: Dynamic unit assignment based on test suite type

## 📁 Test Suite Structure

### Page Object Structure

The test suites use a Page Object Model (POM) for maintainable test code:

- **`PO/Admin/`** - Admin interface page objects
- **`PO/App/`** - Application-specific page objects
- **`PO/Common/`** - Shared UI components and patterns
- **`PO/User/`** - User interface page objects

## WIP: Robot Code Test Configuration

This section is work in progress and will cover:
- Robot Framework test configuration details
- Keyword libraries and custom keywords
- Test data management and variables


## 📚 Additional Resources

- [PARALLEL_SETUP_GUIDE.md](PARALLEL_SETUP_GUIDE.md) - Detailed guide for parallel testing configuration  
- [Robot Framework Documentation](https://docs.robotframework.org/)
- [Robot Framework Browser Library](https://marketsquare.github.io/robotframework-browser/Browser.html)
- [PabotLib Documentation](https://pabot.org/) - Parallel execution library
