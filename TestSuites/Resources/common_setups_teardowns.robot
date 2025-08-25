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
# UNIFIED TEST SETUP - DOES EVERYTHING NEEDED FOR ANY TEST
# =============================================================================

Complete Desktop User Test Setup
    [Documentation]    Complete setup for desktop user tests
    Initialize Suite Units    desktop
    ${data_type}=    Get Suite Data Type
    Initialize Test Data    ${data_type}

Complete Admin Desktop Test Setup
    [Documentation]    Complete setup for admin desktop tests
    Initialize Suite Units    admin
    ${data_type}=    Get Suite Data Type
    Initialize Test Data    ${data_type}
    # Select Suite Specific Admin User
    # app_common.Admin opens desktop browser to landing page

Complete Android Mobile Test Setup
    [Documentation]    Complete setup for Android mobile tests
    Initialize Suite Units    android
    ${data_type}=    Get Suite Data Type
    Initialize Test Data    ${data_type}
    # app_common.User opens android chrome to landing page

Complete iPhone Mobile Test Setup
    [Documentation]    Complete setup for iPhone mobile tests
    Initialize Suite Units    iphone
    ${data_type}=    Get Suite Data Type
    Initialize Test Data    ${data_type}
    # app_common.User opens iphone webkit to landing page

Complete Combined Test Setup
    [Documentation]    Complete setup for combined admin+user tests
    Initialize Suite Units    combined
    ${data_type}=    Get Suite Data Type
    Initialize Test Data    ${data_type}
    # app_common.User opens desktop browser to landing page

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
