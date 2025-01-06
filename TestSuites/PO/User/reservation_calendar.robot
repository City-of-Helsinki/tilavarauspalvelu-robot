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
    Click    [data-testid="reservation__input--duration"] >> id=duration-toggle-button
    Sleep    1s
    Click    [role="option"] >> '${duration}'

Click and store free reservation time
    Click    id=time-toggle-button

    # Wait for animation
    Sleep    1s

    ${calendar_control_time_of_third_free_slot}=    Get Text    id=time-item-2
    Set Suite Variable    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}    ${calendar_control_time_of_third_free_slot}
    Log    This selects the third free time slot
    Log    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}
    Click    id=time-item-2

Get current date from datepicker
    ${value}=    Browser.Get Attribute    id=reservationDialog.date    value
    Log    The value of the quick reservation date is: ${value}
    RETURN    ${value}

Click continue button
    Click    [data-testid="reservation__button--continue"]
    Sleep    1s
