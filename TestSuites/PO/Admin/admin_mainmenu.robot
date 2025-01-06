*** Settings ***
Library     Browser


*** Keywords ***
Admin navigates to requested reservations
# TODO add id
    Click    xpath=(//a[@href='/kasittely/reservations/requested'])[last()]

Admin navigates to my units
    Click    xpath=(//a[@href='/kasittely/my-units'])[last()]
