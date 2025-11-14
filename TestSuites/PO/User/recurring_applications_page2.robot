*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User selects type of the booking request
    [Arguments]    ${type_of_booking_request_txt}
    Click    css=[aria-label*="Aikatoiveen tyyppi. "]
    Sleep    300ms
    Find and click element with text
    ...    ul >> span
    ...    ${type_of_booking_request_txt}

User clicks available seasonal booking times for
    [Arguments]    ${name_of_the_unit}
    Click    css=[aria-label*="Näytä kausivarattavat "]
    Sleep    300ms
    Find and click element with text    ul >> span    ${name_of_the_unit}

User selects the times for recurring application
    [Arguments]    ${selector_for_time_of_the_booking}
    Click    ${selector_for_time_of_the_booking}
    Sleep    300ms

User clicks continue button
    Log    this is the same in the page 3
    Click    id=button__application--next
    Sleep    1s
    Wait For Load State    load    timeout=10s
