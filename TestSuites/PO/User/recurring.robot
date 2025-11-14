*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User selects a recurring booking round
    [Arguments]    ${name_of_the_recurring_reservation}
    custom_keywords.Find and click element in card element by text
    ...    [data-testid="recurring-lander__application-round-container--active"] >> .card--default
    ...    [data-testid="card__heading"]
    ...    ${name_of_the_recurring_reservation}
    ...    a[href*="/recurring/"]:not([href*="/criteria"])

    # wait for units to load
    Sleep    2s
    Wait For Load State    load    timeout=15s

User selects the units for recurring reservation
    [Arguments]    ${name_of_the_recurring_unit}
    custom_keywords.Find and click element in card element by text
    ...    [class*="Card__CardContent"]
    ...    [data-testid="card__heading"]
    ...    ${name_of_the_recurring_unit}
    ...    [data-testid="recurring-card__button--toggle"]

    # For animation
    Sleep    300ms

User checks the count of selected units
    [Arguments]    ${expected_text}
    custom_keywords.Check elements text    id=reservationUnitCount    ${expected_text}

User clicks continue button
    Wait For Elements State    id=startApplicationButton    visible
    Click    id=startApplicationButton

    # Wait for units to load
    Sleep    2s
    Wait For Load State    load    timeout=15s
