*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/serial_users.robot
Library     Browser


*** Keywords ***
###
# BOOKING DETAILS
###

Type The Name Of The Booking
    [Arguments]    ${name_of_the_booking}
    Type Text    id=reservation-form-field__name    ${name_of_the_booking}

Select The Purpose Of The Booking
    [Arguments]    ${purpose}
    Click    id=reservation-form-field__purpose-main-button
    Sleep    1s    # wait for dropdown to load
    Wait For Elements State    id=reservation-form-field__purpose-option-2    visible
    custom_keywords.Find And Click Element With Text    li    ${purpose}

Select The Number Of Participants
    [Arguments]    ${number_of_persons}
    Type Text    id=reservation-form-field__numPersons    ${number_of_persons}

Type The Description Of The Booking
    [Arguments]    ${description_txt}
    Type Text    id=reservation-form-field__description    ${description_txt}

Click To Apply For A Free Booking
    Click    id=reservation-form-field__applyingForFreeOfCharge

Type Justification For Free Of Charge
    [Arguments]    ${reason}
    Type Text    id=reservation-form-field__freeOfChargeReason    ${reason}

Click And Select AgeGroup Button
    [Arguments]    ${age_group}
    Wait For Elements State    id=reservation-form-field__ageGroup-main-button    visible
    Click    id=reservation-form-field__ageGroup-main-button
    Sleep    1s    # wait for dropdown to load
    custom_keywords.Find And Click Element With Text    li    ${age_group}
    Sleep    1s
