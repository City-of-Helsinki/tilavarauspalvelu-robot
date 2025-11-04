*** Settings ***
Documentation       Unified setup and teardown keywords for all test suites
...                 Simple approach: One setup does everything, one teardown cleans everything

Resource            ${CURDIR}/suite_unit_selector.robot
Resource            ${CURDIR}/parallel_test_data.robot
Resource            ${CURDIR}/devices.robot
Library             Browser
Library             Collections
Library             DateTime
Library             OperatingSystem


*** Keywords ***
# =============================================================================
# TAG-BASED UNIFIED TEST SETUP
# =============================================================================

Complete Test Setup From Tags
    [Documentation]    Tag-based test setup
    ...
    ...    Automatically initializes test data and suite units based on test tags.
    ...
    ...    REQUIRED TAGS on each test:
    ...    - Data set tag: desktop-test-data-set-0, admin-test-data-set-2, etc.
    ...    - Suite type tag: desktop-suite, admin-suite, combined-suite, android-suite, iphone-suite
    ...
    ...    EXAMPLE:
    ...    Test Case
    ...    [Tags]    desktop-test-data-set-0    desktop-suite    smoke

    ${test_name}=    Get Variable Value    ${TEST NAME}    unknown_test
    Log    🚀 Starting tag-based setup for: ${test_name}

    # Initialize suite-specific units from tags
    Initialize suite units from tags

    # Initialize test data (users) from tags
    Initialize Test Data From Tags

    Log    ✓ Test setup completed successfully

# =============================================================================
# TEST TEARDOWN
# =============================================================================

Complete Test Teardown
    [Documentation]    Complete teardown with session cleanup
    Sleep    2s
    # Always take screenshot on failure
    Run Keyword If Test Failed    Take Screenshot    EMBED

    # Cleanup process
    Run Keywords    Release Test Data
    ...    AND    Run Keyword And Ignore Error    Close Browser
