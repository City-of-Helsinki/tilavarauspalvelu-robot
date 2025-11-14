*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/serial_users.robot
Library     Browser


*** Keywords ***
Checks the admin landing page H1
    [Arguments]    ${expected_H1_text}
    Sleep    2s    # Wait for the page to render. TODO: remove after frontend is updated
    Wait For Load State    networkidle    timeout=40s
    Wait For Elements State    css=H1    stable
    ${landingPageH1}=    Get Text    css=H1
    Should Contain    ${landingPageH1}    ${expected_H1_text}    strip_spaces=true
    Log    ${expected_H1_text}

Approve cookies
    Wait For Elements State    css=.ch2-btn-text-sm    visible
    Click    css=.ch2-btn-text-sm
