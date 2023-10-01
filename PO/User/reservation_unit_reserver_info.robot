*** Settings ***
# Resource    ../../Resources/devices.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/users.robot
# Resource    ../User/user_landingpage.robot
# Resource    ../Common/topNav.robot
# Resource    ../Common/login.robot
Library     Browser
Library     Dialogs


*** Keywords ***
Enter first name
    [Arguments]    ${firstname}
    # Click    css=#reserveeFirstName
    Type Text    css=#reserveeFirstName    ${firstname}

Enter last name
    [Arguments]    ${lastname}
    Type Text    css=#reserveeLastName    ${lastname}

Enter email
    [Arguments]    ${email}
    Type Text    css=#reserveeEmail    ${email}

Enter phone number
    [Arguments]    ${phonenumber}
    Type Text    css=#reserveePhone    ${phonenumber}

Click submit button continue
    Click    [data-test="reservation__button--update"]

Click the checkbox accepted terms
    Click    [for="cancellation-and-payment-terms-terms-accepted"]

Click the checkbox generic terms
    Click    [for="generic-and-service-specific-terms-terms-accepted"]

Click submit button reservation
    Click    [data-test="reservation__button--update"]
    Wait For Elements State    [data-testid="reservation__confirmation--button__calendar-url"]    visible

Check the quick reservation time
    # DEVNOTE
    # This keyword/test cannot be run after 23.15
    # Example -> Su 1.10.2023 klo 23:45-0:45, 1 t != La 30.9.2023 klo 23:45-su 1.10.20230:45, 1 t
    Log    ${TIME_OF_SECOND_FREE_SLOT}
    custom_keywords.Get Finnish Formatted Date    ${TIME_OF_SECOND_FREE_SLOT}
    ${reservationtime}    Get Text    [data-testid="reservation__reservation-info-card__duration"]
    Should Be Equal    ${TIME_OF_QUICK_RESERVATION}    ${reservationtime}

Check the reservation status message
    [Arguments]    ${expected_reservation_message}
    ${PageH1}    Get Text    css=h1
    Should Contain    ${PageH1}    ${expected_reservation_message}
    Log    ${expected_reservation_message}
