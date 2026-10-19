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

    # The carousel can move when its slots change, wait until it shows slots and has stopped
    Wait For Elements State
    ...    [class*="slide-visible"] >> [data-testid="quick-reservation__slot"] >> nth=0    visible    timeout=10s
    ...    message=No free available slots in quick reservation slots
    Wait For Elements State
    ...    [class*="slide-visible"] >> [data-testid="quick-reservation__slot"] >> nth=0    stable    timeout=5s

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
    Focus    ${all_free_quick_timeslots}[${random_index}]
    Click    ${all_free_quick_timeslots}[${random_index}]
    Get Attribute    ${all_free_quick_timeslots}[${random_index}]    aria-pressed    ==    true
    ...    message=The clicked slot was not selected

    Store Test Data Variable    TIME_OF_QUICK_RESERVATION_FREE_SLOT    ${time_of_selected_slot}
    Set Test Variable    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}    ${time_of_selected_slot}

User Clicks Submit Button In Quick Reservation
    [Documentation]    Clicks the submit button in quick reservation using JavaScript.
    ...    Polls for button to be enabled before clicking with dispatchEvent.

    ${button_selector}=    Set Variable    id=quick-reservation >> [data-testid="quick-reservation__button--submit"]

    # Wait for button to be visible
    Wait For Elements State    ${button_selector}    visible    timeout=10s

    # Verify the button exists inside quick-reservation before clicking
    ${button_count}=    Browser.Get Element Count    ${button_selector}
    Should Be Equal As Integers    ${button_count}    1
    ...    msg=Expected exactly 1 submit button inside quick-reservation, found ${button_count}. Button may have disappeared.
    Scroll To Element    ${button_selector}

    # Alternative: Basic Browser library click (commented out - less reliable with React re-renders)
    # Wait For Elements State    ${button_selector}    enabled    timeout=10s
    # Click    ${button_selector}

    # Use JavaScript to wait for button to be enabled and then click with dispatchEvent
    ${click_result}=    Evaluate JavaScript    ${button_selector}
    ...    async (button) => {
    ...    const maxWait = 10000;
    ...    const pollInterval = 200;
    ...    let waited = 0;
    ...    while (button.disabled && waited < maxWait) {
    ...    await new Promise(r => setTimeout(r, pollInterval));
    ...    waited += pollInterval;
    ...    }
    ...    if (button.disabled) {
    ...    return { success: false, error: 'Button still disabled after 10s' };
    ...    }
    ...    await new Promise(r => setTimeout(r, 300));
    ...    const mouseDown = new MouseEvent('mousedown', { bubbles: true, cancelable: true, view: window });
    ...    const mouseUp = new MouseEvent('mouseup', { bubbles: true, cancelable: true, view: window });
    ...    const click = new MouseEvent('click', { bubbles: true, cancelable: true, view: window });
    ...    button.dispatchEvent(mouseDown);
    ...    button.dispatchEvent(mouseUp);
    ...    button.dispatchEvent(click);
    ...    return { success: true, waited: waited };
    ...    }

    Log    Click result: ${click_result}
    Should Be True    ${click_result}[success]    msg=Failed to click button: ${click_result}

    # Wait for the target page element
    Wait For Elements State    [data-testid="reservation__form--reservee-info"]    visible    timeout=20s
    ...    message=ERROR: Reservee info form not visible on booking details page. Check screenshot.

Get Unit Lock Name
    [Documentation]    Returns a lock name for the open reservation unit page.
    ${url}=    Get Url
    ${unit_page}=    Fetch From Left    ${url}    ?
    RETURN    QUICK_RESERVATION_${unit_page}

Reload Reservation Unit Page And Wait For Reservations
    [Documentation]    Reloads and waits for the unit's existing reservations (AffectingReservations query),
    ...    so that the free slots shown are up to date.
    ${reservations_loaded}=    Start Waiting For Reservations Query
    Reload
    Wait For Reservations Query    ${reservations_loaded}

Start Waiting For Reservations Query
    [Documentation]    Starts waiting for the next AffectingReservations response. Call it before the action that opens the page.
    ${started}=    Evaluate    int(time.time() * 1000)    modules=time
    ${reservations_loaded}=    Promise To    Wait For Response
    ...    matcher=response => response.request().timing().startTime >= ${started} && response.url().includes('/graphql') && (response.request().postData() || '').includes('AffectingReservations')
    ...    timeout=20s
    RETURN    ${reservations_loaded}

Wait For Reservations Query
    [Arguments]    ${reservations_loaded}
    ${response}=    Wait For    ${reservations_loaded}
    Should Be True    $response.get('ok')    msg=Reservations query failed: HTTP ${response}[status]
    Should Be True    'errors' not in ($response.get('body') or {})    msg=Reservations query returned errors

Select Duration
    [Arguments]    ${duration}
    Log    ${duration}
    # Click    id=quick-reservation >> css=.Select-module_selectAndListContainer__vSJEv
    ${main_button}=    Set Variable    id=quick-reservation__duration-main-button
    # Clicking the selected duration would unselect it
    ${already_selected}=    Get Element Count    ${main_button} >> text="${duration}"
    IF    ${already_selected} == 0
        Click    id=quick-reservation >> ${main_button}
        Click    [role="option"] >> '${duration}'
    END
    Wait For Elements State    ${main_button} >> text="${duration}" >> nth=0    visible    timeout=5s
    custom_keywords.Close Select List If Open    ${main_button}

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
    [Documentation]    Verifies the price in quick reservation info card.
    ...                Note: Price may not render immediately, causing mismatches like
    ...                "40,00 €" vs "0 - 40,00 €". Retries until the price is fully rendered.
    [Arguments]    ${price_with_text}
    Log    expected price string ${price_with_text}
    Wait Until Keyword Succeeds    ${CONTENT_WAIT_TIMEOUT}    250ms    Info Card Price Should Be    ${price_with_text}

Info Card Price Should Be
    [Arguments]    ${price_with_text}
    ${reservation_price}=    Get Text    [data-testid="reservation__reservation-info-card__price"]
    ${normalized_string}=    custom_keywords.Remove Non-breaking Space    ${reservation_price}
    Should Be Equal    ${normalized_string}    ${price_with_text}

Get Booking Number
    # The number is shown once the reservation has loaded
    ${reservation_number}=    Get Text    [data-testid="reservation__reservation-info-card__reservationNumber"]
    ...    matches    ^\\d+$
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

    # Ensures cancel button is visible
    Wait For Elements State    button >> span:text-is("Sulje")    visible

    # Confirms the select button exists and closes the datepicker dialog window
    Click    id=quick-reservation >> [data-testid="selectButton"]

    # Verify the datepicker dialog is closed
    Wait For Elements State    id=hds-date-picker >> [data-testid="selectButton"]    hidden    timeout=5s

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
    Sleep    1s
    Click    [role="option"] >> '${duration}'
    Sleep    1.5s    # wait for animation to complete

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
