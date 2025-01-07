*** Settings ***
Library     Browser
Library     ../../Resources/token_manager.py
Library     ../../Resources/generate_tokens.py
Library     ../../Resources/email_tools.py
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Resource    ../../Resources/users.robot
Resource    ../../Resources/variables.robot


*** Keywords ***
Check emails from reservations
    Log    ${ATTACHMENT_FILENAME}
    ${texts}=    email_tools.Search Reservations
    ...    ${USERMAIL_EMAIL}
    ...    ${NUMBER_OF_RESERVATION_FOR_MAIL_TEST}
    ...    ${ATTACHMENT_FILENAME}
    ...    ${DOWNLOAD_DIR}

    ${count}=    Evaluate    len(${texts})
    Log    Found ${count} emails with reservation number: ${NUMBER_OF_RESERVATION_FOR_MAIL_TEST}

    # Fail the test if no emails are found
    IF    ${count} == 0
        Fail    No emails found with reservation number: ${NUMBER_OF_RESERVATION_FOR_MAIL_TEST}
    END

Verify reservation confirmation email
    Log    ${EMAIL_FILE_PATH}
    ${result}=    email_tools.Check Email Content
    ...    ${EMAIL_FILE_PATH}
    ...    ${ALWAYS_PAID_UNIT}
    ...    ${CONFIRMATION_TEXT_IN_MAIL}
    ...    ${NUMBER_OF_RESERVATION_FOR_MAIL_TEST}
    ...    ${FORMATTED_STARTTIME_EMAIL}
    ...    ${FORMATTED_ENDTIME_EMAIL}
    IF    not ${result}
        Fail    Some required terms are missing in email content
    END

Verify reservation cancellation email
    Log    ${EMAIL_FILE_PATH}
    ${result}=    email_tools.Check Email Content
    ...    ${EMAIL_FILE_PATH}
    ...    ${ALWAYS_PAID_UNIT}
    ...    ${CANCELLATION_TEXT_IN_MAIL}
    ...    ${NUMBER_OF_RESERVATION_FOR_MAIL_TEST}
    ...    ${FORMATTED_STARTTIME_EMAIL}
    ...    ${FORMATTED_ENDTIME_EMAIL}
    IF    not ${result}
        Fail    Some required terms are missing in email content
    END

Verify payment receipt email
    Log    ${EMAIL_FILE_PATH}
    ${result}=    email_tools.Check Email Content
    ...    ${EMAIL_FILE_PATH}
    ...    ${ALWAYS_PAID_UNIT}
    ...    ${CONFIRMATION_AND_RECEIPT_TEXT_IN_MAIL}
    ...    ${NUMBER_OF_RESERVATION_FOR_MAIL_TEST}
    ...    ${RESERVATION_TIME_EMAIL_RECEIPT}
    ...    ${EXPECTED_ATTACHMENT_STATUS}
    IF    not ${result}
        Fail    Some required terms are missing in email content
    END

Verify refund email for paid reservation
    Log    ${EMAIL_FILE_PATH}
    ${result}=    email_tools.Check Email Content
    ...    ${EMAIL_FILE_PATH}
    ...    ${ALWAYS_PAID_UNIT}
    ...    ${CANCELLATION_AND_REFUND_TEXT_IN_MAIL}
    ...    ${NUMBER_OF_RESERVATION_FOR_MAIL_TEST}
    ...    ${RESERVATION_TIME_EMAIL_RECEIPT}
    IF    not ${result}
        Fail    Some required terms are missing in email content
    END

Format reservation time for email texts and receipts
    [Arguments]    ${time_of_reservation}

    # This sets "Alkamisaika: 1.11.2024 klo 11:00" and "Päättymisaika: 1.11.2024 klo 12:00"
    Log    this formats variables "FORMATTED_STARTTIME" and "FORMATTED_ENDTIME"
    data_modification.Formats reservation time to start and end time    ${time_of_reservation}
    Log    this formats variables "RESERVATION_TIME_EMAIL_RECEIPT"
    data_modification.Format reservation time for email receipt    ${time_of_reservation}

###
###
###
