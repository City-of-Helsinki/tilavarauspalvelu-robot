*** Settings ***
Library     Browser


*** Keywords ***
Admin Navigates To Requested Reservations
    Click    [href="/kasittely/reservations/requested"]
    Sleep    4s

Admin Navigates To Reservations
    Click    [href="/kasittely/reservations"]
    Sleep    4s

Admin Navigates To Application Rounds
    Click    [href="/kasittely/application-rounds"]
    Sleep    4s

Admin Navigates To Reservation Units
    Click    [href="/kasittely/reservation-units"]
    Sleep    4s

Admin Navigates To Units
    Click    [href="/kasittely/units"]
    Sleep    4s

Admin Navigates To My Units
    Click    [href="/kasittely/my-units"]
    Sleep    4s

Admin Navigates To Notifications
    Click    [href="/kasittely/notifications"]
    # The create link is only on the notifications list page
    Wait For Elements State    [href="/kasittely/notifications/new"]    visible    timeout=15s
