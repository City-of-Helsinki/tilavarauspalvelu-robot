*** Settings ***
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/parallel_test_data.robot
Library     Browser


*** Keywords ***
Allow all cookies if visible
    TRY
        Wait For Elements State    css=button[data-approved="required"]    visible    timeout=5s
        Click    css=button[data-approved="required"]
        Log    Cookie consent button found and clicked
    EXCEPT
        Log    Cookie consent button not found, continuing without clicking
    END

Select payment method OP
    Wait For Elements State    css=#OP    visible
    Click    css=#OP

Click submit
    Wait For Elements State    css=.submit    visible
    Click    css=.submit

Click accept terms
    Wait For Elements State    css=#acceptTerms    visible
    Click    css=#acceptTerms

Check user details in checkout
    # TODO - add more checks here
    custom_keywords.Find text from elements or fail
    ...    css=.customer-details-information >> td
    ...    ${CURRENT_USER_EMAIL}

Check product list has all the info
    # TODO - add more checks here
    custom_keywords.Check elements text    css=.product-summary >> span.cart-total.padded
    ...    ${SINGLEBOOKING_PAID_PRICE_CHECKOUT}

In order summary get booking number from product list
    Wait For Elements State    css=.product-list    visible

    # Get the next sibling element containing the reservation number
    ${element_next_to_varausnumero}=    Browser.Get Element
    ...    xpath=//div[contains(@class, 'product-list')]//div[contains(@class, 'meta-label') and text()='Varausnumero']/following-sibling::div[1]

    # Extract the text of the next sibling element
    ${reservation_number}=    Get Text    ${element_next_to_varausnumero}

    # Log the reservation number
    Log    Reservation number: ${reservation_number}

    ${BOOKING_NUM_ONLY}=    Set Variable    ${reservation_number}
    Store Test Data Variable    BOOKING_NUM_ONLY    ${BOOKING_NUM_ONLY}
    Set Test Variable    ${BOOKING_NUM_ONLY}    ${BOOKING_NUM_ONLY}
    Log    ${BOOKING_NUM_ONLY}

####
####

Check the info in checkout
    Sleep    2s
    Wait For Load State    load    timeout=20s
    Allow all cookies if visible
    Sleep    1s
    Wait For Load State    load    timeout=15s
    Select payment method OP
    Sleep    1s
    Click submit
    Sleep    3s
    Wait For Load State    load    timeout=15s
    Check user details in checkout
    Check product list has all the info
    In order summary get booking number from product list
    Click accept terms
    Sleep    1s
    Click submit
    Sleep    3s
    Wait For Load State    networkidle    timeout=50s

Interrupted checkout
    [Arguments]    ${input_URL}
    Sleep    5s
    Allow all cookies if visible
    Sleep    1s
    Go To    ${input_URL}
    Wait For Load State    load    timeout=15s

Check the info in checkout with auth validation
    [Documentation]    Enhanced checkout with authentication validation and timing

    # Basic session validation
    Sleep    2s
    Wait For Load State    load    timeout=20s

    # Validate we're not on a 403 page
    ${current_url}=    Get Url
    Should Not Contain    ${current_url}    403
    Should Not Contain    ${current_url}    forbidden

    Allow all cookies if visible
    Sleep    1s
    Wait For Load State    load    timeout=15s

    # Double-check session is still valid before proceeding
    ${cookies}=    Get Cookies
    ${has_session}=    Set Variable    False
    FOR    ${cookie}    IN    @{cookies}
        IF    'sessionid' in '${cookie}[name]' or 'AUTH_SESSION_ID' in '${cookie}[name]'
            ${has_session}=    Set Variable    True
            Log    "✅ Active session cookie: ${cookie}[name]"
            BREAK
        END
    END

    Should Be True    ${has_session}
    ...    msg=No session cookie found before checkout - authentication may have failed

    Select payment method OP
    Sleep    1s
    Click submit
    Sleep    3s
    Wait For Load State    load    timeout=15s
    Check user details in checkout
    Check product list has all the info
    In order summary get booking number from product list
    Click accept terms
    Sleep    1s
    Click submit
    Sleep    3s
    Wait For Load State    networkidle    timeout=50s
