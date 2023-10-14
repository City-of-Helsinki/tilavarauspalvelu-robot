*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/custom_keywords.robot
Library     Browser


*** Keywords ***
Select the second free slot
    # DEVNOTE
    # This keyword/test cannot be run after 23.00
    # Example -> Su 1.10.2023 klo 23:45-0:45, 1 t != La 30.9.2023 klo 23:45-su 1.10.20230:45, 1 t
    ${all_free_quick_timeslots}=    Get Elements    [data-testid="quick-reservation-slot"]
    ${TIME_OF_SECOND_FREE_SLOT}=    Get Text    ${all_free_quick_timeslots}[1]
    Log    ${TIME_OF_SECOND_FREE_SLOT}
    Click    ${all_free_quick_timeslots}[1]
    Click    css=[data-test="quick-reservation__button--submit"]:not([disabled])
    Set Suite Variable    ${TIME_OF_SECOND_FREE_SLOT}

Select duration
    # Set to 1h
    [Arguments]    ${duration}
    Click    id=desktop-quick-reservation-duration-toggle-button
    Click    [role="option"] >> '${duration}'

Click more available slots
    Click    [data-testid="quick-reservation-next-available-time"]

Check the quick reservation time
    # DEVNOTE
    # This keyword/test cannot be run after 23.00
    # Example -> Su 1.10.2023 klo 23:45-0:45, 1 t != La 30.9.2023 klo 23:45-su 1.10.20230:45, 1 t
    Log    ${TIME_OF_SECOND_FREE_SLOT}
    custom_keywords.Get Finnish Formatted Date    ${TIME_OF_SECOND_FREE_SLOT}
    ${reservationtime}=    Get Text    [data-testid="reservation__reservation-info-card__duration"]
    Should Be Equal    ${TIME_OF_QUICK_RESERVATION}    ${reservationtime}

Check the price of quick reservation
    ${reservation_price}=    Get text    [data-testid="reservation__reservation-info-card__price"]
    custom_keywords.Normalize string    ${reservation_price}
    Should Be Equal    ${normalized_string}    ${SINGLEBOOKING_FREE_PRICE}

###
# MOBILE
###

Select duration mobile
    # Set to 1h
    [Arguments]    ${duration}
    Wait For Elements State    [aria-owns="mobile-quick-reservation-duration-menu"]    visible
    Click    id=mobile-quick-reservation-duration-toggle-button
    Click    [role="option"] >> '${duration}'

Select the second free slot mobile
    ${all_free_quick_timeslots}=    Get Elements
    ...    id=quick-reservation-mobile >> [data-testid="quick-reservation-slot"]
    ${TIME_OF_SECOND_FREE_SLOT}=    Get Text    ${all_free_quick_timeslots}[1]
    Log    ${TIME_OF_SECOND_FREE_SLOT}
    ${element_of_second_free_slot}=    Get Element    ${all_free_quick_timeslots}[1]
    Click    ${element_of_second_free_slot}
    Click    css=[data-test="quick-reservation__button--submit"]:not([disabled])
    Set Suite Variable    ${TIME_OF_SECOND_FREE_SLOT}
