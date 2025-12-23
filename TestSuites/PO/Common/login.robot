*** Settings ***
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/variables.robot
Resource    ../../Resources/parallel_test_data.robot
Resource    ../../Resources/custom_keywords.robot
Library     Browser
Library     BuiltIn


*** Keywords ***
Login Suomi Fi
    [Arguments]    ${input_hetu}
    # Wait for Suomi.fi login button
    Wait For Elements State    id=social-suomi_fi    visible    timeout=10s

    # Click Suomi.fi and wait for authentication provider selection page
    custom_keywords.Click And Wait For Navigation With Retry
    ...    id=social-suomi_fi
    ...    id=li_fakevetuma2
    ...    max_attempts=2
    ...    nav_timeout=15s

    # Click fakevetuma2 and wait for HETU input page
    custom_keywords.Click And Wait For Navigation With Retry
    ...    css=#li_fakevetuma2
    ...    css=#hetu_input
    ...    max_attempts=2
    ...    nav_timeout=15s

    # Enter HETU and submit
    Type Text    css=#hetu_input    ${input_hetu}
    Sleep    500ms

    # Click authenticate and wait for continue button
    custom_keywords.Click And Wait For Navigation With Retry
    ...    css=#tunnistaudu
    ...    css=#continue-button
    ...    max_attempts=2
    ...    nav_timeout=15s

    # Click continue to complete login
    Click    css=#continue-button
    Sleep    5s

    # Check for cookies after login
    ${fresh_cookies}=    Get Cookies
    ${fresh_cookie_count}=    Get Length    ${fresh_cookies}
    Log    "🔍 Login cookies after Tunnistamo: ${fresh_cookie_count}"

Login Django Admin
    [Documentation]    The input_password argument is kept for backward compatibility but is not used
    [Arguments]    ${input_username}    ${input_password}=${EMPTY}
    IF    '${input_password}' != '${EMPTY}'
        Log    Login Django Admin: input_password argument is ignored (using DJANGO_ADMIN_PASSWORD)    level=DEBUG
    END

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

    # Submit login form and wait for password field to disappear (indicates successful login)
    Click    [type="submit"]
    Sleep    5s    # wait for the page to load
    Wait For Load State    load    timeout=60s
    Wait For Elements State    id=id_password    hidden    timeout=5s    message=Check that login credentials are correct and match the backend data.

Login Suomi Fi Mobile
    [Arguments]    ${input_hetu}
    # Wait for Suomi.fi login button
    Wait For Elements State    id=social-suomi_fi    visible    timeout=15s

    # Click Suomi.fi and wait for authentication provider selection page
    custom_keywords.Click And Wait For Navigation With Retry
    ...    id=social-suomi_fi
    ...    id=li_fakevetuma2
    ...    max_attempts=3
    ...    nav_timeout=15s

    # Click fakevetuma2 (mobile uses nav >> prefix) and wait for HETU input page
    custom_keywords.Click And Wait For Navigation With Retry
    ...    nav >> id=li_fakevetuma2
    ...    css=#hetu_input
    ...    max_attempts=3
    ...    nav_timeout=15s

    # Enter HETU and submit
    Type Text    css=#hetu_input    ${input_hetu}
    Sleep    500ms

    # Click authenticate and wait for continue button
    custom_keywords.Click And Wait For Navigation With Retry
    ...    css=#tunnistaudu
    ...    css=#continue-button
    ...    max_attempts=3
    ...    nav_timeout=15s

    # Click continue to complete login - wait for page to fully load
    Click    css=#continue-button
    Sleep    5s    # wait for the page to load
