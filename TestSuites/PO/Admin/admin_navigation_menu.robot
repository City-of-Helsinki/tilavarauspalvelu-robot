*** Settings ***
Library     Browser


*** Keywords ***
Admin navigates to requested reservations
    Click    [href="/kasittely/reservations/requested"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to reservations
    Click    [href="/kasittely/reservations"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to application rounds
    Click    [href="/kasittely/application-rounds"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to reservation units
    Click    [href="/kasittely/reservation-units"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to units
    Click    [href="/kasittely/units"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to my units
    Click    [href="/kasittely/my-units"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin navigates to notifications
    Click    [href="/kasittely/notifications"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s
