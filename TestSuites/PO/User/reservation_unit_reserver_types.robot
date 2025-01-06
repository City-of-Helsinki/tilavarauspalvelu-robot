*** Settings ***
Library     Browser


*** Keywords ***
###
# BOOKING DETAILS
###

Select reserver type
    [Arguments]    ${reserver_type}
    Click    ${reserver_type}
