*** Settings ***
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/parallel_test_data.robot
Library     Browser


*** Keywords ***
Allow All Cookies If Visible
    # The banner is not shown again once the consent is saved
    ${consent_saved}=    Evaluate JavaScript    ${None}    () => document.cookie.includes('helfi-cookie-consents=')
    IF    ${consent_saved}
        Log    Cookie consent already saved, the banner is not shown
        RETURN
    END
    TRY
        Wait For Elements State    css=button[data-approved="required"]    visible    timeout=5s
    EXCEPT    TimeoutError*    type=glob
        Log    Cookie consent button not found, continuing without clicking
        RETURN
    END
    # A keyboard press, in the Android emulation the other cookie button blocks a mouse click
    Focus    css=button[data-approved="required"]
    Keyboard Key    press    Enter
    Wait For Elements State    css=button[data-approved="required"]    hidden    timeout=5s
    ...    message=The cookie banner did not close
    Log    Cookie consent button found and clicked

Select Payment Method OP
    Wait For Elements State    css=#OP    visible
    Click    css=#OP

Click Submit
    Wait For Elements State    css=.submit    visible
    Click    css=.submit

Click Accept Terms
    Wait For Elements State    css=#acceptTerms    visible
    Click    css=#acceptTerms

Check User Details In Checkout
    custom_keywords.Find Text From Elements Or Fail
    ...    css=.customer-details-information >> td
    ...    ${CURRENT_USER_EMAIL}

Check Product List Has All The Info
    custom_keywords.Check Elements Text    css=.product-summary >> span.cart-total.padded
    ...    ${SINGLEBOOKING_PAID_PRICE_CHECKOUT}

In Order Summary Get Booking Number From Product List
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

Check The Info In Checkout
    # The checkout opens on its payment method step
    Wait For Elements State    css=#OP    visible    timeout=30s
    Allow All Cookies If Visible
    Select Payment Method OP
    Click Submit
    # Submitting the payment method opens the summary step
    custom_keywords.Wait For Url To Contain    /summary    timeout=20s
    Check Product List Has All The Info
    In Order Summary Get Booking Number From Product List
    Click Accept Terms
    Click Submit
    # Submitting the summary goes through the payment back to Varaamo
    Wait Until Keyword Succeeds    50s    500ms    Url Should Start With    ${URL_TEST}
    Wait For Load State    load    timeout=50s

Url Should Start With
    [Arguments]    ${prefix}
    ${url}=    Get Url
    Should Start With    ${url}    ${prefix}

Interrupted Checkout
    [Arguments]    ${input_URL}
    # The checkout opens on its payment method step
    Wait For Elements State    css=#OP    visible    timeout=30s
    Allow All Cookies If Visible
    Go To    ${input_URL}
    Wait For Load State    load    timeout=15s
