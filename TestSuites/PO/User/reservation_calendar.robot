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
    # The list is open when its options are shown
    Wait For Elements State    id=calendar-controls__time-option-0    visible    timeout=5s
    ...    message=The time selection list did not open

    # Check if enough time slots are available for the current day
    ${time_slot_exists}=    Run Keyword And Return Status
    ...    Browser.Get Element    id=calendar-controls__time-option-2
    IF    not ${time_slot_exists}
        ${available_slots}=    Get Element Count    css=[id^="calendar-controls__time-option-"]
        Fail    Not enough available time slots for the current day. Expected at least 3 slots, but found ${available_slots}. Try selecting a different date or time range.
    END

    ${calendar_control_time_of_third_free_slot}=    Get Text    id=calendar-controls__time-option-2
    Set Suite Variable    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}    ${calendar_control_time_of_third_free_slot}
    # Clicking the current time would unselect it and keep the continue button disabled
    ${is_current_time}=    Get Element Count
    ...    id=calendar-controls__time-main-button >> text="${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}"
    IF    ${is_current_time} > 0
        Log    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT} is the current time, changing to a different time
        Changing Time Again
    ELSE
        Log    Attempting to select time: ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}
        Click    id=calendar-controls__time-option-2
    END
    Wait For Elements State
    ...    id=calendar-controls__time-main-button >> text="${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}" >> nth=0
    ...    visible    timeout=5s
    custom_keywords.Close Select List If Open    id=calendar-controls__time-main-button

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
    Click    id=calendar-controls__time-option-3

Get Current Date From Datepicker
    # ${value}=    Browser.Get Attribute    id=reservationDialog.date    value
    ${value}=    Browser.Get Attribute    id=controlled-date-input__date    value
    Log    The value of the quick reservation date is: ${value}
    RETURN    ${value}

Click Continue Button
    Click    [data-testid="reservation__button--continue"]
    # Continuing opens the terms step of the edit
    Wait For Elements State    [for="cancellation-and-payment-terms-terms-accepted"]    visible    timeout=15s

User Click Reservation Calendar Toggle Button
    Click    [data-testid="calendar-controls__toggle-button"]
    Sleep    1.5s    # Wait for animation
