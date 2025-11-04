*** Settings ***
Documentation       Suite-specific unit selector for parallel execution

Resource            suite_specific_units.robot
Resource            variables.robot


*** Keywords ***
# =============================================================================
# TAG-BASED SUITE UNIT INITIALIZATION
# =============================================================================

Initialize suite units from tags
    [Documentation]    Tag-based suite unit initialization
    ...
    ...    Automatically determines which suite units to load based on test tags:
    ...    - desktop-suite: Desktop user test units
    ...    - admin-suite: Admin test units
    ...    - combined-suite: Combined admin+user units
    ...    - android-suite: Android mobile units
    ...    - iphone-suite: iPhone mobile units
    ...
    ...    EXAMPLE TAGS:
    ...    [Tags]    desktop-test-data-set-0    desktop-suite    smoke
    ...    [Tags]    admin-test-data-set-2    admin-suite    permissions

    ${test_tags}=    Get Variable Value    ${TEST TAGS}    []
    ${test_name}=    Get Variable Value    ${TEST NAME}    unknown_test

    Log    🏷️ Initializing suite units from tags for: ${test_name}
    Log    🏷️ Tags: ${test_tags}

    # Check for suite type tags
    IF    'desktop-suite' in ${test_tags}
        Log    📱 Loading desktop suite units
        Set desktop suite units
    ELSE IF    'admin-suite' in ${test_tags}
        Log    👨‍💼 Loading admin suite units
        Set admin suite units
    ELSE IF    'combined-suite' in ${test_tags}
        Log    🔄 Loading combined suite units
        Set combined suite units
    ELSE IF    'android-suite' in ${test_tags}
        Log    📱 Loading Android suite units
        Set Android Suite Units
    ELSE IF    'iphone-suite' in ${test_tags}
        Log    📱 Loading iPhone suite units
        Set iPhone Suite Units
    ELSE
        Log    ⚠️ No suite type tag found, using desktop as default
        Set desktop suite units
    END

Set desktop suite units
    [Documentation]    Set units specific to desktop user tests
    Set Suite Variable    ${CURRENT_ALWAYS_FREE_UNIT}    ${DESKTOP_ALWAYS_FREE_UNIT}
    Set Suite Variable    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}    ${DESKTOP_ALWAYS_FREE_UNIT_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT}    ${DESKTOP_ALWAYS_PAID_UNIT}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}    ${DESKTOP_ALWAYS_PAID_UNIT_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}    ${DESKTOP_ALWAYS_PAID_UNIT_SUBVENTED}
    Set Suite Variable
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${DESKTOP_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_FREE_UNIT_NO_CANCEL}    ${DESKTOP_FREE_UNIT_NO_CANCEL}
    Set Suite Variable    ${CURRENT_FREE_UNIT_NO_CANCEL_WITH_LOCATION}    ${DESKTOP_FREE_UNIT_NO_CANCEL_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNAVAILABLE_UNIT}    ${DESKTOP_UNAVAILABLE_UNIT}
    Set Suite Variable    ${CURRENT_UNAVAILABLE_UNIT_WITH_LOCATION}    ${DESKTOP_UNAVAILABLE_UNIT_WITH_LOCATION}

Set admin suite units
    [Documentation]    Set units specific to admin tests
    Set Suite Variable    ${CURRENT_UNAVAILABLE_UNIT}    ${DESKTOP_UNAVAILABLE_UNIT}
    Set Suite Variable
    ...    ${CURRENT_UNAVAILABLE_UNIT_WITH_LOCATION}
    ...    ${DESKTOP_UNAVAILABLE_UNIT_WITH_LOCATION}

Set combined suite units
    [Documentation]    Set units specific to combined user+admin tests
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}    ${COMBINED_ALWAYS_PAID_UNIT_SUBVENTED}
    Set Suite Variable
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${COMBINED_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING}    ${COMBINED_UNIT_REQUIRES_ALWAYS_HANDLING}
    Set Suite Variable
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${COMBINED_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNIT_WITH_ACCESS_CODE}    ${DESKTOP_UNIT_WITH_ACCESS_CODE}
    Set Suite Variable
    ...    ${CURRENT_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    ...    ${DESKTOP_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}

Set Android Suite Units
    [Documentation]    Set units specific to Android mobile tests
    Set Suite Variable    ${CURRENT_ALWAYS_FREE_UNIT}    ${ANDROID_ALWAYS_FREE_UNIT}
    Set Suite Variable    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}    ${ANDROID_ALWAYS_FREE_UNIT_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT}    ${ANDROID_ALWAYS_PAID_UNIT}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}    ${ANDROID_ALWAYS_PAID_UNIT_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNIT_WITH_ACCESS_CODE}    ${ANDROID_UNIT_WITH_ACCESS_CODE}
    Set Suite Variable
    ...    ${CURRENT_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    ...    ${ANDROID_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}    ${ANDROID_ALWAYS_PAID_UNIT_SUBVENTED}
    Set Suite Variable
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${ANDROID_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING}    ${ANDROID_UNIT_REQUIRES_ALWAYS_HANDLING}
    Set Suite Variable
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${ANDROID_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}

Set iPhone Suite Units
    [Documentation]    Set units specific to iPhone mobile tests
    Set Suite Variable    ${CURRENT_ALWAYS_FREE_UNIT}    ${IPHONE_ALWAYS_FREE_UNIT}
    Set Suite Variable    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}    ${IPHONE_ALWAYS_FREE_UNIT_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT}    ${IPHONE_ALWAYS_PAID_UNIT}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}    ${IPHONE_ALWAYS_PAID_UNIT_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNIT_WITH_ACCESS_CODE}    ${IPHONE_UNIT_WITH_ACCESS_CODE}
    Set Suite Variable
    ...    ${CURRENT_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    ...    ${IPHONE_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}    ${IPHONE_ALWAYS_PAID_UNIT_SUBVENTED}
    Set Suite Variable
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${IPHONE_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING}    ${IPHONE_UNIT_REQUIRES_ALWAYS_HANDLING}
    Set Suite Variable
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${IPHONE_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
