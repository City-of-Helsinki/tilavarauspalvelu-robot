*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
Check the user landing page h1
    [Arguments]    ${expected_h1_text}
    ${landingPageH1}=    Get Text    css=h1
    Should Contain    ${landingPageH1}    ${expected_h1_text}
    Log    ${expected_h1_text}

Check the name in the login button
    Log    ${BASIC_USER_MALE_FULLNAME}
    ${TOPNAV_LOGIN_BUTTON_TEXT}=    Get Text    id=userDropdown-button
    Log    ${TOPNAV_LOGIN_BUTTON_TEXT}
    Should Be Equal    ${TOPNAV_LOGIN_BUTTON_TEXT}    ${BASIC_USER_MALE_FULLNAME}

Check the interrupted payment notification
    [Arguments]    ${banner_title}
    ${PAYMENT_NOTIFICATION_TITLE}=    Get Text    [data-testid="unpaid-reservation-notification__title"]
    Should Be Equal    ${PAYMENT_NOTIFICATION_TITLE}    ${banner_title}

Approve interrupted payment
    Click    [data-testid="reservation-notification__button--checkout"]
    Wait For Load State    domcontentloaded    timeout=7s
