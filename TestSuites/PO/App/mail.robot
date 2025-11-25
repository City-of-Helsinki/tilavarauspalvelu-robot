*** Settings ***
Library     Browser
# New cache-based email testing library (replaces Gmail API)
Library     ../../Resources/robot_email_test_tool.py
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/variables.robot


*** Keywords ***
Verify Reservation Confirmation Email
    [Documentation]    Verify confirmation email contains all required terms
    [Arguments]    ${reservation_number}
    
    Log    Verifying confirmation email for reservation: ${reservation_number}
    
    # Build list of expected terms
    ${expected_terms}=    Create List
    ...    ${ALWAYS_PAID_UNIT}
    ...    ${CONFIRMATION_TEXT_IN_MAIL}
    ...    ${reservation_number}
    ...    ${FORMATTED_STARTTIME_EMAIL}
    ...    ${FORMATTED_ENDTIME_EMAIL}
    
    # Use new API-based verification
    ${result}=    Verify Reservation Email
    ...    ${reservation_number}
    ...    ${expected_terms}
    ...    ${False}    # No attachment expected
    
    IF    not ${result}
        Fail    Some required terms are missing in confirmation email
    END

Verify Reservation Cancellation Email
    [Documentation]    Verify cancellation email contains all required terms
    [Arguments]    ${reservation_number}
    
    Log    Verifying cancellation email for reservation: ${reservation_number}
    
    ${expected_terms}=    Create List
    ...    ${ALWAYS_PAID_UNIT}
    ...    ${CANCELLATION_TEXT_IN_MAIL}
    ...    ${reservation_number}
    ...    ${FORMATTED_STARTTIME_EMAIL}
    ...    ${FORMATTED_ENDTIME_EMAIL}
    
    ${result}=    Verify Reservation Email
    ...    ${reservation_number}
    ...    ${expected_terms}
    ...    ${False}    # No attachment expected
    
    IF    not ${result}
        Fail    Some required terms are missing in cancellation email
    END

Format Reservation Time For Email Texts And Receipts
    [Documentation]    Format reservation times for email verification
    [Arguments]    ${time_of_reservation}

    # This sets "Alkamisaika: 1.11.2024 klo 11:00" and "Päättymisaika: 1.11.2024 klo 12:00"
    Log    this formats variables "FORMATTED_STARTTIME" and "FORMATTED_ENDTIME"
    data_modification.Formats Reservation Time To Start And End Time    ${time_of_reservation}

###
###
###
