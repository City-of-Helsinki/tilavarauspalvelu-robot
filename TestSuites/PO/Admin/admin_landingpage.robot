*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
Checks the admin landing page H1
    [Arguments]    ${expected_H1_text}
    ${landingPageH1}=    Get Text    css=H1
    Should Contain    ${landingPageH1}    ${expected_H1_text}
    Log    ${expected_H1_text}

Approve cookies
    Wait For Elements State    css=.ch2-btn-text-sm    visible
    Click    css=.ch2-btn-text-sm
