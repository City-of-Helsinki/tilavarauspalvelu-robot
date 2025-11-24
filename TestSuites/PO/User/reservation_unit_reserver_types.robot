*** Settings ***
Library     Browser


*** Keywords ***
###
# BOOKING DETAILS
###

Select Reserver Type
    [Arguments]    ${reserver_type}
    Click    ${reserver_type}
