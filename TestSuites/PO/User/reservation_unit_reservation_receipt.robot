*** Settings ***
Resource    ../../Resources/users.robot
Resource    ../../Resources/texts_FI.robot
Library     Browser


*** Keywords ***
Check users reservation info
    Wait For Elements State    [data-testid="confirm_reserveePhone"]    visible
#
    ${confirmed_firstname}    Get Text    [data-testid="confirm_reserveeFirstName"]
    Should Contain    ${confirmed_firstname}    ${BASIC_USER_MALE_FIRSTNAME}
#
    ${confirmed_lastname}    Get Text    [data-testid="confirm_reserveeLastName"]
    Should Contain    ${confirmed_lastname}    ${BASIC_USER_MALE_LASTNAME}
#
    ${confirmed_email}    Get Text    [data-testid="confirm_reserveeEmail"]
    Should Contain    ${confirmed_email}    ${BASIC_USER_MALE_EMAIL}
#
    ${confirmed_phone}    Get Text    [data-testid="confirm_reserveePhone"]
    Should Contain    ${confirmed_phone}    ${BASIC_USER_MALE_PHONE}

Check single free booking info
    Wait For Elements State    [data-testid="confirm_reserveePhone"]    visible
#
    ${confirmed_bookersname}    Get Text    [data-testid="reservation-confirm__name"]
    Should Contain    ${confirmed_bookersname}    ${SINGLEBOOKING_NAME}
#
    ${confirmed_purpose}    Get Text    [data-testid="reservation-confirm__purpose"]
    Should Contain    ${confirmed_purpose}    ${PURPOSE_OF_THE_BOOKING}
#
    ${confirmed_description}    Get Text    [data-testid="reservation-confirm__description"]
    Should Contain    ${confirmed_description}    ${SINGLEBOOKING_DESCRIPTION}
#
    ${confirmed_reason_for_free}    Get Text    [data-testid="reservation-confirm__freeOfChargeReason"]
    Should Contain    ${confirmed_reason_for_free}    ${JUSTIFICATION_FOR_FREE_OF_CHARGE}
#
    ${confirmed_number_of_persons}    Get Text    [data-testid="reservation-confirm__numPersons"]
    Should Contain    ${confirmed_number_of_persons}    ${SINGLEBOOKING_NUMBER_OF_PERSONS}

Check the reservation status message
    [Arguments]    ${expected_reservation_message}
    ${PageH1}    Get Text    css=h1
    Should Contain    ${PageH1}    ${expected_reservation_message}
    Log    ${expected_reservation_message}

Click the checkbox accepted terms
    Click    [for="cancellation-and-payment-terms-terms-accepted"]

Click the checkbox generic terms
    Click    [for="generic-and-service-specific-terms-terms-accepted"]
