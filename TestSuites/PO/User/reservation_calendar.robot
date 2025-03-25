*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/custom_keywords.robot
Library     Browser
Library     Collections
Library     String
Library     Dialogs
##
# DEVNOTE This is not the quick reservation form
##


*** Keywords ***
Select duration calendar
    [Arguments]    ${duration}
    # Click    [data-testid="reservation__input--duration"] >> id=duration-toggle-button
    Click    [data-testid="calendar-controls__duration"] >> id=calendar-controls__duration-main-button
    Sleep    1s
    Click    [role="option"] >> '${duration}'
    Sleep    500ms
    Wait For Load State    Load    timeout=15s

Click and store free reservation time
    Click    id=calendar-controls__time-main-button

    # Wait for animation
    Sleep    1s
    Wait For Load State    Load    timeout=15s

    ${calendar_control_time_of_third_free_slot}=    Get Text    id=calendar-controls__time-option-2
    Set Suite Variable    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}    ${calendar_control_time_of_third_free_slot}
    Log    This selects the third free time slot
    Log    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}
    Click    id=calendar-controls__time-option-2

    # Wait for animation
    Sleep    500ms
    Wait For Load State    Load    timeout=15s

Get current date from datepicker
    # ${value}=    Browser.Get Attribute    id=reservationDialog.date    value
    ${value}=    Browser.Get Attribute    id=controlled-date-input__date    value
    Log    The value of the quick reservation date is: ${value}
    RETURN    ${value}

Click continue button
    Click    [data-testid="reservation__button--continue"]
    Sleep    1s
