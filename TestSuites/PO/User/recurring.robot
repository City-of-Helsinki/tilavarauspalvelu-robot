*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User Selects A Recurring Booking Round
    [Arguments]    ${name_of_the_recurring_reservation}
    custom_keywords.Find And Click Element In Card Element By Text
    ...    [data-testid="recurring-lander__application-round-container--active"] >> .card--default
    ...    [data-testid="card__heading"]
    ...    ${name_of_the_recurring_reservation}
    ...    a[href*="/recurring/"]:not([href*="/criteria"])

    # wait for units to load
    Sleep    4s
    Wait For Load State    load    timeout=15s

User Selects The Units For Recurring Reservation
    [Arguments]    ${name_of_the_recurring_unit}
    custom_keywords.Find And Click Element In Card Element By Text
    ...    [class*="Card__CardContent"]
    ...    [data-testid="card__heading"]
    ...    ${name_of_the_recurring_unit}
    ...    [data-testid="recurring-card__button--toggle"]

    # For animation
    Sleep    300ms

User Checks The Count Of Selected Units
    [Arguments]    ${expected_text}
    custom_keywords.Check Elements Text    id=reservationUnitCount    ${expected_text}

User Clicks Continue Button
    Wait For Elements State    id=startApplicationButton    visible
    Click    id=startApplicationButton

    # Wait for units to load
    Sleep    4s
    Wait For Load State    load    timeout=15s
