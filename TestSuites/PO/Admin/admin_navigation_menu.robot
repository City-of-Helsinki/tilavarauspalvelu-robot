*** Settings ***
Library     Browser


*** Keywords ***
Admin navigates to requested reservations
# TODO add id
    # Click    xpath=(//a[@href='/kasittely/reservations/requested'])[last()]
    Click    [href="/kasittely/reservations/requested"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to my units
    # Click    xpath=(//a[@href='/kasittely/my-units'])[last()]
    Click    [href="/kasittely/my-units"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to notifications
# TODO add id
    Click    [href="/kasittely/messaging/notifications"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s
