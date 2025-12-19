*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Resource    ../../Resources/parallel_test_data.robot
Library     Browser
Library     Collections
Library     String
Library     XML


*** Keywords ***
Select The Free Slot From Quick Reservation
    [Documentation]    This keyword selects a random reservation slot from a list of available slots for quick reservations.

    # DEVNOTE
    # This keyword/test cannot be run over midnight
    # Example -> Su 1.10.2023 klo 23:45-0:45, 1 t != La 30.9.2023 klo 23:45-su 1.10.20230:45, 1 t

    Sleep    2s

    # Get all available slots
    ${all_free_quick_timeslots}=    Browser.Get Elements
    ...    [class*="slide-visible"] >> [data-testid="quick-reservation__slot"]

    # Get the total number of slots
    ${total_slots}=    Get Length    ${all_free_quick_timeslots}
    Log    Total available slots: ${total_slots}

    # Check if there are any available slots
    IF    ${total_slots} == 0
        Fail    No free available slots in quick reservation slots
    END

    # Generate a random index between 0 and the number of slots - 1
    ${random_index}=    Evaluate    random.randint(0, ${total_slots} - 1)    random
    Log    Randomly selected slot index: ${random_index}

    # Get the time of the randomly selected slot
    ${time_of_selected_slot}=    Get Text    ${all_free_quick_timeslots}[${random_index}]
    Log    Selected slot time: ${time_of_selected_slot}

    # Click the randomly selected slot
    Click    ${all_free_quick_timeslots}[${random_index}]

    Store Test Data Variable    TIME_OF_QUICK_RESERVATION_FREE_SLOT    ${time_of_selected_slot}
    Set Test Variable    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}    ${time_of_selected_slot}

User Clicks Submit Button In Quick Reservation
    Sleep    300ms    # Wait for rendering
    # Verify the button exists inside quick-reservation before clicking
    ${button_count}=    Browser.Get Element Count    id=quick-reservation >> [data-testid="quick-reservation__button--submit"]
    Should Be Equal As Integers    ${button_count}    1
    ...    msg=Expected exactly 1 submit button inside quick-reservation, found ${button_count}. Button may have disappeared.
    
    Wait For Elements State    id=quick-reservation >> [data-testid="quick-reservation__button--submit"]    visible
    ...    message=Quick reservation submit button is not visible inside quick-reservation
    Click    id=quick-reservation >> [data-testid="quick-reservation__button--submit"]

Select Duration
    [Arguments]    ${duration}
    Log    ${duration}
    # Click    id=quick-reservation >> css=.Select-module_selectAndListContainer__vSJEv
    Click    id=quick-reservation >> id=quick-reservation__duration-main-button
    Sleep    1s
    Click    [role="option"] >> '${duration}'
    Wait For Load State    load    timeout=15s

Click More Available Slots
    Click    [data-testid="quick-reservation-next-available-time"]
    Sleep    500ms

Check The Quick Reservation Time
    [Documentation]    This keyword/test cannot be run overnight. For now varaamo cannot handle overnight reservations.
    ...    Example -> Su 1.10.2023 klo 23:45-0:45, 1 t != La 30.9.2023 klo 23:45-su 1.10.20230:45, 1 t
    [Arguments]    ${time_of_quick_reservation_slot}

    Log    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    Log    ${TIME_OF_QUICK_RESERVATION}
    Log    ${time_of_quick_reservation_slot}
    Wait For Elements State    [data-testid="reservation__reservation-info-card__duration"]    visible
    ${reservationtime}=    Get Text    [data-testid="reservation__reservation-info-card__duration"]
    Should Be Equal    ${time_of_quick_reservation_slot}    ${reservationtime}

Check The Price Of Quick Reservation
    [Arguments]    ${price_with_text}
    # TODO Add more robust way to check the final price is loaded
    # Otherwise can getHinta: 40,00 € (sis. alv 25,5%) != Hinta: 0 - 40,00 € (sis. alv 25,5%)
    Sleep    3s    # this sleeps ensures the final price is loaded
    Wait For Load State    load    timeout=10s
    ${reservation_price}=    Get Text    [data-testid="reservation__reservation-info-card__price"]
    ${normalized_string}=    custom_keywords.Remove Non-breaking Space    ${reservation_price}
    Log    expected price string ${price_with_text}
    Should Be Equal    ${normalized_string}    ${price_with_text}

Get Booking Number
    Sleep    1s
    ${reservation_number}=    Get Text    [data-testid="reservation__reservation-info-card__reservationNumber"]
    ${BOOKING_NUM_ONLY}=    Set Variable    ${reservation_number}
    Store Test Data Variable    BOOKING_NUM_ONLY    ${BOOKING_NUM_ONLY}
    Set Test Variable    ${BOOKING_NUM_ONLY}    ${BOOKING_NUM_ONLY}
    Log    ${BOOKING_NUM_ONLY}

Check Booking Number
    [Arguments]    ${booking_number}
    Wait For Elements State    [data-testid="reservation__reservation-info-card__reservationNumber"]    visible
    ${quick_booking_num}=    Get Text    [data-testid="reservation__reservation-info-card__reservationNumber"]
    Log    quick_booking_num: ${quick_booking_num}, booking_number: ${booking_number}
    Should Be Equal    ${quick_booking_num}    ${booking_number}

Get Access Code
    [Documentation]    Extracts and saves the numeric access code from the element.
    Wait For Elements State    [data-testid="reservation__reservation-info-card__accessType"]    visible
    Sleep    2s
    ${access_code_numbers}=    custom_keywords.Get Number From Element Text
    ...    [data-testid="reservation__reservation-info-card__accessType"]
    # Add # at the end as it's required for access code entry in the system
    ${access_code_with_hash}=    Set Variable    ${access_code_numbers}#
    Store Test Data Variable    ACCESS_CODE    ${access_code_with_hash}
    Set Test Variable    ${ACCESS_CODE}    ${access_code_with_hash}
    Log    Saved access code (with #): ${ACCESS_CODE}

Check Access Code
    [Arguments]    ${access_code}
    custom_keywords.Check Number From Text Is Equal To
    ...    [data-testid="reservation__reservation-info-card__accessType"]
    ...    ${access_code}

Confirms Date Picker Opens From Quick Reservation
    Wait For Elements State    id=quick-reservation__date    visible
    Click    id=quick-reservation >> [aria-label="Valitse päivämäärä"]

    # Waiting for the animation
    Sleep    1s

    # Ensures cancel button is visible
    ${Closing_button}=    Browser.Get Element    button >> span:text-is("Sulje")
    Wait For Elements State    ${Closing_button}    visible

    # Confirms the select button exists and closes the datepicker dialog window
    Click    id=quick-reservation >> [data-testid="selectButton"]

Get The Value From Date Input
    [Documentation]    Gets the current date value from the quick reservation date input field
    ${value}=    Browser.Get Attribute    id=quick-reservation__date    value
    Log    The value of the quick reservation date is: ${value}
    RETURN    ${value}

###
# MOBILE
###

Select Duration Mobile
    # Set to 1h
    [Arguments]    ${duration}
    Wait For Elements State    id=mobile-quick-reservation-duration-toggle-button    visible
    Click    id=mobile-quick-reservation-duration-toggle-button
    Sleep    500ms
    Click    [role="option"] >> '${duration}'
    Wait For Load State    load    timeout=15s

Verify Time Slot Not Available
    [Documentation]    Verifies that the specified time slot is not available in the list of free slots.
    [Arguments]    ${time_to_check}
    Log    Verifying time slot not available: ${time_to_check}

    Sleep    2s
    Wait For Elements State    id=quick-reservation__duration-main-button    visible

    # 1 Collect all time slots
    ${elements}=    Browser.Get Elements    [class*="slider-list"] >> [data-testid="quick-reservation__slot"]

    # 2 Fail test if no slots are found
    ${count}=    Get Length    ${elements}
    IF    ${count} == 0
        Fail    No slots found at all. Cannot verify exclusion of ${time_to_check}
    END

    # 3 Lower Browser's default timeout
    Set Browser Timeout    3s    scope=Test

    # 4 Iterate, swallowing any Get Text failures and skipping blanks
    VAR    @{slot_texts}    @{EMPTY}
    FOR    ${el}    IN    @{elements}
        ${ok}=    Run Keyword And Return Status    Get Text    ${el}
        IF    not ${ok}    CONTINUE

        ${t}=    Get Text    ${el}
        IF    '${t}' == ''    CONTINUE

        Append To List    ${slot_texts}    ${t}
        IF    '${t}' == '${time_to_check}'    BREAK
    END

    # 5 Restore the original timeout
    Set Browser Timeout    ${BROWSER_TIMEOUT_GLOBAL}    scope=Global

    Log    Collected slots: ${slot_texts}

    # 6 Final assertion
    List Should Not Contain Value    ${slot_texts}    ${time_to_check}
    Log    Slot '${time_to_check}' is not available, as expected.
