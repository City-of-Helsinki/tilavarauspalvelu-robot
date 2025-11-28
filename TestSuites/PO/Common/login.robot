*** Settings ***
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/variables.robot
Resource    ../../Resources/parallel_test_data.robot
Library     Browser
Library     BuiltIn


*** Keywords ***
Login Suomi Fi
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

Login Django Admin
    [Documentation]    The input_password argument is kept for backward compatibility but is not used
    [Arguments]    ${input_username}    ${input_password}=${EMPTY}
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=id_username    visible    timeout=10s
    Type Text    id=id_username    ${input_username}
    # Verify that the username was actually typed
    ${typed_username}=    Get Property    id=id_username    value
    Should Be Equal    ${typed_username}    ${input_username}
    Sleep    100ms

    # Use password from Robot Framework variable (loaded by env_loader.py)
    # Suppress logging when typing password
    ${original_log_level}=    Set Log Level    WARN
    Type Text    id=id_password    ${DJANGO_ADMIN_PASSWORD}
    # Verify that the password was actually typed (without logging the value)
    ${typed_password}=    Get Property    id=id_password    value
    Should Be Equal    ${typed_password}    ${DJANGO_ADMIN_PASSWORD}
    Set Log Level    ${original_log_level}
    Click    [type="submit"]
    Sleep    2s
    Wait For Load State    load    timeout=60s
    Wait For Elements State    id=id_password    hidden    timeout=5s    message=Check that login credentials are correct and match the backend data.

Login Suomi Fi Mobile
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
