*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/custom_keywords.robot
Library     Browser
Library     Collections
Library     String
##
# DEVNOTE This is not the quick reservation form
##


*** Keywords ***
Select Duration Calendar
    [Arguments]    ${duration}
    # Click    [data-testid="reservation__input--duration"] >> id=duration-toggle-button
    Click    [data-testid="calendar-controls__duration"] >> id=calendar-controls__duration-main-button
    Sleep    1s
    Click    [role="option"] >> '${duration}'
    Sleep    1s

Click And Store Free Reservation Time
    Click    id=calendar-controls__time-main-button

    # Wait for animation
    Sleep    2s
    Wait For Load State    load    timeout=15s

    # Check if enough time slots are available for the current day
    ${time_slot_exists}=    Run Keyword And Return Status
    ...    Browser.Get Element    id=calendar-controls__time-option-2
    IF    not ${time_slot_exists}
        ${available_slots}=    Get Element Count    css=[id^="calendar-controls__time-option-"]
        Fail    Not enough available time slots for the current day. Expected at least 3 slots, but found ${available_slots}. Try selecting a different date or time range.
    END

    ${calendar_control_time_of_third_free_slot}=    Get Text    id=calendar-controls__time-option-2
    Set Suite Variable    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}    ${calendar_control_time_of_third_free_slot}
    Log    Attempting to select time: ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}
    Sleep    500ms
    Click    id=calendar-controls__time-option-2
    Sleep    1.3s

    ${aria_expanded}=    Get Attribute    css=[aria-controls="calendar-controls__time-list"]    aria-expanded
    IF    '${aria_expanded}'=='true'
        Log    Time selection dropdown is still expanded, which means the selected time was already the current time
        Log    Changing to a different time to ensure the continue button will be enabled
        Changing Time Again
    END

    # Wait for animation
    Sleep    2s
    Wait For Load State    domcontentloaded    timeout=15s

Changing Time Again
    # Check if the 4th time slot is available
    ${time_slot_exists}=    Run Keyword And Return Status
    ...    Browser.Get Element    id=calendar-controls__time-option-3
    IF    not ${time_slot_exists}
        ${available_slots}=    Get Element Count    css=[id^="calendar-controls__time-option-"]
        Fail    Not enough available time slots to change time. Expected at least 4 slots, but found ${available_slots}. Try selecting a different date or time range.
    END

    ${calendar_control_time_of_fourth_free_slot}=    Get Text    id=calendar-controls__time-option-3
    Set Suite Variable    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}    ${calendar_control_time_of_fourth_free_slot}
    Log    Selecting alternative time: ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}
    Sleep    500ms
    Click    id=calendar-controls__time-option-3
    Sleep    1s

Get Current Date From Datepicker
    # ${value}=    Browser.Get Attribute    id=reservationDialog.date    value
    ${value}=    Browser.Get Attribute    id=controlled-date-input__date    value
    Log    The value of the quick reservation date is: ${value}
    RETURN    ${value}

Click Continue Button
    Click    [data-testid="reservation__button--continue"]
    Sleep    1s

User Click Reservation Calendar Toggle Button
    Click    [data-testid="calendar-controls__toggle-button"]
    Sleep    1s    # Wait for animation
    Wait For Load State    load    timeout=15s
