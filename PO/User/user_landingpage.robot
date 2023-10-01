*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
 Checks the user landing page H1
    [Arguments]    ${expected_h1_text}
    ${landingPageH1}=    Get Text    css=h1
    Should Contain    ${landingPageH1}    ${expected_h1_text}
    Log    ${expected_h1_text}

Check the name in the login button
    Log    ${BASIC_USER_FEM_FULLNAME}
    Log    ${BASIC_USER_MALE_FULLNAME}
    ${TOPNAV_LOGIN_BUTTON_TEXT}=    Get Text    css=#userDropdown-button
    Log    ${TOPNAV_LOGIN_BUTTON_TEXT}
    Should Be Equal    ${TOPNAV_LOGIN_BUTTON_TEXT}    ${BASIC_USER_MALE_FULLNAME}
