*** Settings ***
Resource    ../../Resources/users.robot
Resource    ../../Resources/variables.robot
Library     Browser
Library     BuiltIn


*** Keywords ***
Login Suomi_fi
    [Arguments]    ${input_hetu}
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=social-suomi_fi    visible    timeout=10s
    Click    id=social-suomi_fi
    Sleep    3s
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=li_fakevetuma2    visible    timeout=10s
    Click    css=#li_fakevetuma2
    Sleep    3s
    Wait For Load State    load    timeout=15s
    Type Text    css=#hetu_input    ${input_hetu}
    Sleep    1s
    Click    css=#tunnistaudu
    Sleep    3s
    Click    css=#continue-button
    Sleep    3s
    Wait For Load State    load    timeout=60s

    # Check for cookies after login
    ${fresh_cookies}=    Get Cookies
    ${fresh_cookie_count}=    Get Length    ${fresh_cookies}
    Log    "🔍 Login cookies after Tunnistamo: ${fresh_cookie_count}"

Login django admin
    [Arguments]    ${input_username}    ${input_password}
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=id_username    visible    timeout=10s
    Type Text    id=id_username    ${input_username}
    Type Text    id=id_password    ${input_password}
    Click    [type="submit"]
    Sleep    2s
    Wait For Load State    load    timeout=60s

Login Suomi_fi mobile
    [Arguments]    ${input_hetu}
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=social-suomi_fi    visible    timeout=15s
    Click    id=social-suomi_fi
    Sleep    3s
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=li_fakevetuma2    visible    timeout=15s
    Click    nav >> id=li_fakevetuma2
    Sleep    3s
    Wait For Load State    load    timeout=15s
    Type Text    css=#hetu_input    ${input_hetu}
    Sleep    1s
    Click    css=#tunnistaudu
    Sleep    3s
    Click    css=#continue-button
    Sleep    3s
    Wait For Load State    load    timeout=60s
