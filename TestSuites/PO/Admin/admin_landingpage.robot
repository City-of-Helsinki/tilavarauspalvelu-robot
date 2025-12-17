*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/serial_users.robot
Library     Browser


*** Keywords ***
Checks The Admin Landing Page H1
    [Arguments]    ${expected_H1_text}
    Sleep    2s    # Wait for the page to render.
    Wait For Load State    networkidle    timeout=40s
    Wait For Elements State    css=H1    stable
    ${landingPageH1}=    Get Text    css=H1
    Should Contain    ${landingPageH1}    ${expected_H1_text}    strip_spaces=true
    Log    ${expected_H1_text}

Approve Cookies
    Wait For Elements State    css=.ch2-btn-text-sm    visible
    Click    css=.ch2-btn-text-sm
