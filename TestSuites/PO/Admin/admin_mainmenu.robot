*** Settings ***
Library     Browser


*** Keywords ***
Admin navigates to requested reservations
# TODO add id
    Click    xpath=(//a[@href='/kasittely/reservations/requested'])[last()]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to my units
    Click    xpath=(//a[@href='/kasittely/my-units'])[last()]
    Sleep    500ms
    Wait For Load State    load    timeout=15s
