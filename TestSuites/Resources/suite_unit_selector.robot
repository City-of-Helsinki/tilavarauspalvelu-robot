*** Settings ***
Documentation       Suite-specific unit selector for parallel execution

Resource            suite_specific_units.robot
Resource            variables.robot


*** Keywords ***
Initialize Suite Units
    [Documentation]    Initialization that uses hard-coded suite-specific units
    [Arguments]    ${suite_type}

    IF    '${suite_type}' == 'desktop'
        Set Desktop Suite Units
    ELSE IF    '${suite_type}' == 'admin'
        Set Admin Suite Units
    ELSE IF    '${suite_type}' == 'combined'
        Set Combined Suite Units
    ELSE IF    '${suite_type}' == 'android'
        Set Android Suite Units
    ELSE IF    '${suite_type}' == 'iphone'
        Set iPhone Suite Units
    ELSE
        # Default fallback
        Set Desktop Suite Units
    END

Set Desktop Suite Units
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
    Set Suite Variable    ${CURRENT_UNIT_WITH_ACCESS_CODE}    ${DESKTOP_UNIT_WITH_ACCESS_CODE}
    Set Suite Variable
    ...    ${CURRENT_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    ...    ${DESKTOP_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNAVAILABLE_UNIT}    ${DESKTOP_UNAVAILABLE_UNIT}
    Set Suite Variable    ${CURRENT_UNAVAILABLE_UNIT_WITH_LOCATION}    ${DESKTOP_UNAVAILABLE_UNIT_WITH_LOCATION}

Set Admin Suite Units
    [Documentation]    Set units specific to admin tests
    Set Suite Variable    ${CURRENT_UNAVAILABLE_UNIT}    ${DESKTOP_UNAVAILABLE_UNIT}
    Set Suite Variable
    ...    ${CURRENT_UNAVAILABLE_UNIT_WITH_LOCATION}
    ...    ${DESKTOP_UNAVAILABLE_UNIT_WITH_LOCATION}

Set Combined Suite Units
    [Documentation]    Set units specific to combined user+admin tests
    Set Suite Variable    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}    ${COMBINED_ALWAYS_PAID_UNIT_SUBVENTED}
    Set Suite Variable
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${COMBINED_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    Set Suite Variable    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING}    ${COMBINED_UNIT_REQUIRES_ALWAYS_HANDLING}
    Set Suite Variable
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${COMBINED_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}

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
