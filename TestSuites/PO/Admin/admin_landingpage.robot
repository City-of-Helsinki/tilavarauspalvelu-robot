*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/serial_users.robot
Library     Browser


*** Keywords ***
Checks The Admin Landing Page H1
    [Arguments]    ${expected_H1_text}
    Wait Until Keyword Succeeds    ${BROWSER_TIMEOUT_GLOBAL}    250ms    Admin Landing Page H1 Should Contain    ${expected_H1_text}
    # The top navigation renders a moment after the heading
    Sleep    2s
    Wait For Load State    networkidle    timeout=40s
    Log    ${expected_H1_text}

Admin Landing Page H1 Should Contain
    [Arguments]    ${expected_H1_text}
    Wait For Elements State    css=H1    stable    timeout=5s
    ${landingPageH1}=    Get Text    css=H1
    Should Contain    ${landingPageH1}    ${expected_H1_text}    strip_spaces=true

Approve Cookies
    Wait For Elements State    css=.ch2-btn-text-sm    visible
    Click    css=.ch2-btn-text-sm
