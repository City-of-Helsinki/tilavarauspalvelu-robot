*** Settings ***
Library     Browser


*** Keywords ***
Admin Navigates To Requested Reservations
    Click    [href="/kasittely/reservations/requested"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Navigates To Reservations
    Click    [href="/kasittely/reservations"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Navigates To Application Rounds
    Click    [href="/kasittely/application-rounds"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Navigates To Reservation Units
    Click    [href="/kasittely/reservation-units"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Navigates To Units
    Click    [href="/kasittely/units"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Navigates To My Units
    Click    [href="/kasittely/my-units"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Navigates To Notifications
    Click    [href="/kasittely/notifications"]
    Sleep    1s
    Wait For Load State    load    timeout=15s
