*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/serial_users.robot
Library     Browser


*** Keywords ***
###
# BOOKING DETAILS
###

Type the name of the booking
    [Arguments]    ${name_of_the_booking}
    Type Text    id=reservation-form-field__name    ${name_of_the_booking}

Select the purpose of the booking
    [Arguments]    ${purpose}
    Click    id=reservation-form-field__purpose-main-button
    Sleep    1s    # wait for dropdown to load
    Wait For Elements State    id=reservation-form-field__purpose-option-2    visible
    custom_keywords.Find and click element with text    li    ${purpose}

Select the number of participants
    [Arguments]    ${number_of_persons}
    Type Text    id=reservation-form-field__numPersons    ${number_of_persons}

Type the description of the booking
    [Arguments]    ${description_txt}
    Type Text    id=reservation-form-field__description    ${description_txt}

Click to apply for a free booking
    Click    id=reservation-form-field__applyingForFreeOfCharge

Type justification for free of charge
    [Arguments]    ${reason}
    Type Text    id=reservation-form-field__freeOfChargeReason    ${reason}

Click and select AgeGroup Button
    [Arguments]    ${age_group}
    Wait For Elements State    id=reservation-form-field__ageGroup-main-button    visible
    Click    id=reservation-form-field__ageGroup-main-button
    Sleep    1s    # wait for dropdown to load
    custom_keywords.Find and click element with text    li    ${age_group}
    Sleep    1s
