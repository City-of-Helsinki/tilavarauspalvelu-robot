*** Settings ***
Resource    ../../Resources/users.robot
Resource    ../../Resources/texts_FI.robot
Resource    ../../Resources/parallel_test_data.robot
Library     Browser
### TODO unify this checks to one single keyword


*** Keywords ***
Check reservation user info
    [Documentation]    Validates the reservation details of the user.
    Wait For Elements State    [data-testid="reservation__reserveePhone"]    visible
#
    ${confirmed_firstname}    Get Text    [data-testid="reservation__reserveeFirstName"]
    Should Contain    ${confirmed_firstname}    ${CURRENT_USER_FIRST_NAME}
#
    ${confirmed_lastname}    Get Text    [data-testid="reservation__reserveeLastName"]
    Should Contain    ${confirmed_lastname}    ${CURRENT_USER_LAST_NAME}
#
    ${confirmed_email}    Get Text    [data-testid="reservation__reserveeEmail"]
    Should Contain    ${confirmed_email}    ${CURRENT_USER_EMAIL}
#
    ${confirmed_phone}    Get Text    [data-testid="reservation__reserveePhone"]
    Should Contain    ${confirmed_phone}    ${CURRENT_USER_PHONE}

Check free single booking info
    [Documentation]    Validates details for a free single booking.
    Wait For Elements State    [data-testid="reservation__reserveePhone"]    visible
#
    ${confirmed_name_of_booking}    Get Text    [data-testid="reservation__name"]
    Should Contain    ${confirmed_name_of_booking}    ${SINGLEBOOKING_NAME}
#
    ${confirmed_purpose}    Get Text    [data-testid="reservation__purpose"]
    Should Contain    ${confirmed_purpose}    ${PURPOSE_OF_THE_BOOKING}
#
    ${confirmed_description}    Get Text    [data-testid="reservation__description"]
    Should Contain    ${confirmed_description}    ${SINGLEBOOKING_DESCRIPTION}
#
    ${confirmed_reason_for_free}    Get Text    [data-testid="confirm_freeOfChargeReason"]
    Should Contain    ${confirmed_reason_for_free}    ${JUSTIFICATION_FOR_FREE_OF_CHARGE}
#
    ${confirmed_number_of_persons}    Get Text    [data-testid="reservation__numPersons"]
    Should Contain    ${confirmed_number_of_persons}    ${SINGLEBOOKING_NUMBER_OF_PERSONS}

Check single booking info
    [Documentation]    Validates details for a single booking.
    Wait For Elements State    [data-testid="reservation__reserveePhone"]    visible
#
    ${confirmed_name_of_booking}    Get Text    [data-testid="reservation__name"]
    Should Contain    ${confirmed_name_of_booking}    ${SINGLEBOOKING_NAME}
#
    ${confirmed_purpose}    Get Text    [data-testid="reservation__purpose"]
    Should Contain    ${confirmed_purpose}    ${PURPOSE_OF_THE_BOOKING}
#
    ${confirmed_description}    Get Text    [data-testid="reservation__description"]
    Should Contain    ${confirmed_description}    ${SINGLEBOOKING_DESCRIPTION}
#
    ${confirmed_number_of_persons}    Get Text    [data-testid="reservation__numPersons"]
    Should Contain    ${confirmed_number_of_persons}    ${SINGLEBOOKING_NUMBER_OF_PERSONS}

Check noncancelable booking info
    [Documentation]    Validates details for a non-cancelable booking.
    Wait For Elements State    [data-testid="reservation__description"]    visible
#
    ${confirmed_description}    Get Text    [data-testid="reservation__description"]
    Should Contain    ${confirmed_description}    ${SINGLEBOOKING_DESCRIPTION}
#
    ${confirmed_number_of_persons}    Get Text    [data-testid="reservation__numPersons"]
    Should Contain    ${confirmed_number_of_persons}    ${SINGLEBOOKING_NUMBER_OF_PERSONS}

###
# VALIDATION MESSAGES
###

Check the reservation status message
    [Arguments]    ${expected_reservation_message}
    ${confirmation_text}    Get Text    [data-testid="reservation__status-notification"]
    Should Contain    ${confirmation_text}    ${expected_reservation_message}
    Log    ${expected_reservation_message}

###
# TERMS AND CONDITIONS
###

Click the checkbox accepted terms
    Click    [for="cancellation-and-payment-terms-terms-accepted"]

Click the checkbox generic terms
    Click    [for="generic-and-service-specific-terms-terms-accepted"]
