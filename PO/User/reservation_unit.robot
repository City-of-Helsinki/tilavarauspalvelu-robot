*** Settings ***
Resource    ../../Resources/variables.robot
Library     Browser


*** Keywords ***
Quick reservation click the second free slot
    ${all_free_quick_timeslots}=    Get Elements    [data-testid="quick-reservation-slot"]
    ${TIME_OF_SECOND_FREE_SLOT}=    Get Text    ${all_free_quick_timeslots}[1]
    Log    ${TIME_OF_SECOND_FREE_SLOT}
    Click    ${all_free_quick_timeslots}[1]
    Click    css=[data-test="quick-reservation__button--submit"]:not([disabled])
    Set Suite Variable    ${TIME_OF_SECOND_FREE_SLOT}

Quick reservation select duration
    # Set to 1h
    [Arguments]    ${duration}
    Click    [id="desktop-quick-reservation-duration-toggle-button"]
    Click    [role="option"] >> '${duration}'
