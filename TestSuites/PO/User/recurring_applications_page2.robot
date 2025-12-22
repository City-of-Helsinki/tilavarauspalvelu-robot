*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User Selects Type Of The Booking Request
    [Arguments]    ${type_of_booking_request_txt}
    Click    css=[aria-label*="Aikatoiveen tyyppi. "]
    Sleep    500ms
    Find And Click Element With Text
    ...    ul >> span
    ...    ${type_of_booking_request_txt}

User Clicks Available Seasonal Booking Times For
    [Arguments]    ${name_of_the_unit}
    Click    css=[aria-label*="Näytä kausivarattavat "]
    Sleep    500ms
    Find And Click Element With Text    ul >> span    ${name_of_the_unit}

User Selects The Times For Recurring Application
    [Arguments]    ${selector_for_time_of_the_booking}
    Click    ${selector_for_time_of_the_booking}
    Sleep    500ms

User Clicks Continue Button
    Log    this is the same in the page 3
    Click    id=button__application--next
    Sleep    3s    # wait for the page to load
    Wait For Load State    load    timeout=10s
