*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
###
# BOOKING DETAILS
###

Type the name of the booking
    [Arguments]    ${name_of_the_booking}
    type text    id=name    ${name_of_the_booking}

Select the purpose of the booking
    [Arguments]    ${purpose}
    Click    id=purpose-toggle-button
    Wait For Elements State    id=purpose-item-0    visible
    custom_keywords.Find and click element with text    li    ${purpose}

Select the number of participants
    [Arguments]    ${number_of_persons}
    type text    id=numPersons    ${number_of_persons}

Type the description of the booking
    [Arguments]    ${description_txt}
    type text    id=description    ${description_txt}

Click the apply for free of charge
    Click    id=applyingForFreeOfCharge

Type justification for free of charge
    [Arguments]    ${reason}
    Type Text    id=freeOfChargeReason    ${reason}

###
# NONPROFIT
###

###
# BUSINESS
###
