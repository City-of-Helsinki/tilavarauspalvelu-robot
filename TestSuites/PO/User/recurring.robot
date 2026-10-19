*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User Selects A Recurring Booking Round
    [Arguments]    ${name_of_the_recurring_reservation}
    ${url_before}=    Get Url
    custom_keywords.Find And Click Element In Card Element By Text
    ...    [data-testid="recurring-lander__application-round-container--active"] >> .card--default
    ...    [data-testid="card__heading"]
    ...    ${name_of_the_recurring_reservation}
    ...    a[href*="/recurring/"]:not([href*="/criteria"])
    # The round's page opens, its units are waited for when they are selected
    Wait Until Keyword Succeeds    20s    250ms    custom_keywords.Url Should Have Changed    ${url_before}    ${EMPTY}

User Selects The Units For Recurring Reservation
    [Arguments]    ${name_of_the_recurring_unit}
    # The units are loaded after the page opens
    Wait For Elements State
    ...    [class*="Card__CardContent"] >> [data-testid="card__heading"] >> text="${name_of_the_recurring_unit}" >> nth=0
    ...    visible    timeout=20s
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
    # Starting the application opens its first page
    custom_keywords.Click And Wait For Page    id=startApplicationButton    /page1
