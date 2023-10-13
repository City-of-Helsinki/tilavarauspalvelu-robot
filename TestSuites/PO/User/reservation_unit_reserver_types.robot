*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
###
# BOOKING DETAILS
###

Select reserver Type
    [Arguments]    ${reserver_type}
    ${reserver_type_button}    Get Element    ${reserver_type}
    Click    ${reserver_type}

###
# NONPROFIT
###

###
# BUSINESS
###
