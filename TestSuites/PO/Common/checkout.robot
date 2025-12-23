*** Settings ***
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/parallel_test_data.robot
Library     Browser


*** Keywords ***
Allow All Cookies If Visible
    TRY
        Wait For Elements State    css=button[data-approved="required"]    visible    timeout=5s
        Click    css=button[data-approved="required"]
        Log    Cookie consent button found and clicked
    EXCEPT
        Log    Cookie consent button not found, continuing without clicking
    END

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
    Sleep    4s
    Allow All Cookies If Visible
    Sleep    2s
    Select Payment Method OP
    Sleep    1s
    Click Submit
    Sleep    4s
    Check Product List Has All The Info
    In Order Summary Get Booking Number From Product List
    Click Accept Terms
    Sleep    1s
    Click Submit
    Sleep    5s
    Wait For Load State    networkidle    timeout=50s

Interrupted Checkout
    [Arguments]    ${input_URL}
    Sleep    5s
    Allow All Cookies If Visible
    Sleep    1s
    Go To    ${input_URL}
    Sleep    2s    # wait for the page to load
    Wait For Load State    load    timeout=15s
