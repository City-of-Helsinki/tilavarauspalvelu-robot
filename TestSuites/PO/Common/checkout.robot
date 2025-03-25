*** Settings ***
Resource    ../../Resources/users.robot
Resource    ../../Resources/custom_keywords.robot
Library     Browser


*** Keywords ***
Allow all cookies
    Wait For Elements State    css=button.ch2-btn.ch2-allow-all-btn.ch2-btn-primary    visible
    Click    css=button.ch2-btn.ch2-allow-all-btn.ch2-btn-primary

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
    ...    ${BASIC_USER_MALE_EMAIL}

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
    Set Suite Variable    ${BOOKING_NUM_ONLY}
    Log    ${BOOKING_NUM_ONLY}

####
####

Check the info in checkout
    Sleep    1s
    Wait For Load State    load    timeout=15s
    Allow all cookies
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
    Wait For Load State    load    timeout=15s

Interrupted checkout
    [Arguments]    ${input_URL}
    Sleep    5s
    Allow all cookies
    Sleep    1s
    Go To    ${input_URL}
    Wait For Load State    load    timeout=15s
