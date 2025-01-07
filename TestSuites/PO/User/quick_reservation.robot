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

    # Generate a random index between 0 and the number of slots - 1
    ${random_index}=    Evaluate    random.randint(0, ${total_slots} - 1)    random
    Log    Randomly selected slot index: ${random_index}

    # Get the time of the randomly selected slot
    ${time_of_selected_slot}=    Get Text    ${all_free_quick_timeslots}[${random_index}]
    Log    Selected slot time: ${time_of_selected_slot}

    # Click the randomly selected slot
    Click    ${all_free_quick_timeslots}[${random_index}]

    Set Suite Variable    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}    ${time_of_selected_slot}

    # Submits selected time
    Click    id=quick-reservation >> [data-testid="quick-reservation__button--submit"]

Select duration
    [Arguments]    ${duration}
    Log    ${duration}
    # devnote fix real selector here
    # Wait For Elements State    id=quick-reservation >> id=duration-toggle-button    visible
    # Click    id=quick-reservation >> id=duration-toggle-button
    # Wait For Elements State    id=quick-reservation >> id=hds-select-92-main-button    visible
    Click    id=quick-reservation >> css=.Select-module_selectAndListContainer__vSJEv
    Click    [role="option"] >> '${duration}'

Click more available slots
    Click    [data-testid="quick-reservation-next-available-time"]

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
    Click    [role="option"] >> '${duration}'
