*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Library     Browser
Library     Collections
Library     String
Library     Dialogs
Library     XML


*** Keywords ***
Select the free slot and submits
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

    Set Suite Variable    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}    ${time_of_selected_slot}    # Submits selected time
    Click    id=quick-reservation >> [data-testid="quick-reservation__button--submit"]

Select duration
    [Arguments]    ${duration}
    Log    ${duration}
    # devnote fix real selector here
    # Wait For Elements State    id=quick-reservation >> id=duration-toggle-button    visible
    # Click    id=quick-reservation >> id=duration-toggle-button
    # Wait For Elements State    id=quick-reservation >> id=hds-select-92-main-button    visible
    Click    id=quick-reservation >> css=.Select-module_selectAndListContainer__vSJEv
    Sleep    500ms
    Click    [role="option"] >> '${duration}'
    Wait For Load State    Load    timeout=15s

Click more available slots
    Click    [data-testid="quick-reservation-next-available-time"]
    Sleep    500ms

Check the quick reservation time
    [Documentation]    This keyword/test cannot be run overnight. For now varaamo cannot handle overnight reservations.
    ...    Example -> Su 1.10.2023 klo 23:45-0:45, 1 t != La 30.9.2023 klo 23:45-su 1.10.20230:45, 1 t
    [Arguments]    ${time_of_quick_reservation_slot}

    Log    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    Log    ${TIME_OF_QUICK_RESERVATION}
    Log    ${time_of_quick_reservation_slot}
    Wait For Elements State    [data-testid="reservation__reservation-info-card__duration"]    visible
    ${reservationtime}=    Get Text    [data-testid="reservation__reservation-info-card__duration"]
    Should Be Equal    ${time_of_quick_reservation_slot}    ${reservationtime}

Check the price of quick reservation
    [Arguments]    ${price_with_text}
    # TODO Add more robust way to check the final price is loaded
    # Otherwise can getHinta: 40,00 € (sis. alv 25,5%) != Hinta: 0 - 40,00 € (sis. alv 25,5%)
    Sleep    3s    # this sleeps ensures the final price is loaded
    Wait For Load State    load    timeout=10s
    ${reservation_price}=    Get text    [data-testid="reservation__reservation-info-card__price"]
    ${normalized_string}=    custom_keywords.Remove non-breaking space    ${reservation_price}
    Log    expected price string ${price_with_text}
    Should Be Equal    ${normalized_string}    ${price_with_text}

Get booking number
    Sleep    1s
    ${reservation_number}=    Get text    [data-testid="reservation__reservation-info-card__reservationNumber"]
    ${BOOKING_NUM_ONLY}=    Set Variable    ${reservation_number}
    Set Suite Variable    ${BOOKING_NUM_ONLY}
    Log    ${BOOKING_NUM_ONLY}

Check booking number
    [Arguments]    ${booking_number}
    Wait For Elements State    [data-testid="reservation__reservation-info-card__reservationNumber"]    visible
    ${quick_booking_num}=    Get text    [data-testid="reservation__reservation-info-card__reservationNumber"]
    Log    quick_booking_num: ${quick_booking_num}, booking_number: ${booking_number}
    Should Be Equal    ${quick_booking_num}    ${booking_number}

Get access code
    Wait For Elements State    [data-testid="reservation__reservation-info-card__accessType"]    visible
    ${access_code}=    Get text    [data-testid="reservation__reservation-info-card__accessType"]
    Set Suite Variable    ${ACCESS_CODE}    ${access_code}
    Log    ${ACCESS_CODE}

Check access code
    # TODO Change here real selector
    [Arguments]    ${access_code}
    Wait For Elements State    [data-testid="reservation__reservation-info-card__accessType"]    visible
    ${quick_access_code}=    Get text    [data-testid="reservation__reservation-info-card__accessType"]
    Log    access code: ${quick_access_code}, access code should be: ${access_code}
    Should Be Equal    ${quick_access_code}    ${access_code}

Confirms date picker opens from quick reservation
    Wait For Elements State    id=quick-reservation__date    visible
    Click    id=quick-reservation >> [aria-label="Valitse päivämäärä"]

    # Waiting for the animation
    Sleep    1s

    # Ensures cancel button is visible
    ${Closing_button}=    Browser.Get Element    button >> span:text-is("Sulje")
    Wait For Elements State    ${Closing_button}    visible

    # Confirms the select button exists and closes the datepicker dialog window
    Click    id=quick-reservation >> [data-testid="selectButton"]

Get the value from date input
    ${value}=    Browser.Get Attribute    id=quick-reservation__date    value
    Log    The value of the quick reservation date is: ${value}
    RETURN    ${value}

###
# MOBILE
###

Select duration mobile
    # Set to 1h
    [Arguments]    ${duration}
    Wait For Elements State    id=mobile-quick-reservation-duration-toggle-button    visible
    Click    id=mobile-quick-reservation-duration-toggle-button
    Sleep    500ms
    Click    [role="option"] >> '${duration}'
    Wait For Load State    Load    timeout=15s

Verify time slot not available
    [Documentation]    Verifies that the specified time slot is not available in the list of free slots.
    [Arguments]    ${time_to_check}
    Log    Verifying time slot not available: ${time_to_check}

    # 1 Collect all time slots
    ${elements}=    Browser.Get Elements    [class*="slider-list"] >> [data-testid="quick-reservation__slot"]

    # 2 Fail test if no slots are found
    ${count}=    Get Length    ${elements}
    IF    ${count} == 0
        Fail    No slots found at all. Cannot verify exclusion of ${time_to_check}
    END

    # 3 Lower Browser’s default timeout to 1 second
    Set Browser Timeout    1 second    scope=Test

    # 4 Iterate, swallowing any Get Text failures and skipping blanks
    ${slot_texts}=    Create List
    FOR    ${el}    IN    @{elements}
        ${ok}=    Run Keyword And Return Status    Get Text    ${el}
        IF    not ${ok}    CONTINUE

        ${t}=    Get Text    ${el}
        IF    '${t}' == ''    CONTINUE

        Append To List    ${slot_texts}    ${t}
        IF    '${t}' == '${time_to_check}'    BREAK
    END

    # 5 Restore the original timeout
    Set Browser Timeout    60s    scope=Global

    Log    Collected slots: ${slot_texts}

    # 6 Final assertion
    List Should Not Contain Value    ${slot_texts}    ${time_to_check}
    Log    Slot '${time_to_check}' is not available, as expected.
