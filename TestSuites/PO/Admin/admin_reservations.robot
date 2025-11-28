*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Library     Browser


*** Keywords ***
Admin Searches Reservation With Id Number And Clicks It From Name
    [Documentation]    This keyword types the reservation number and there should be only one match in the list
    [Arguments]    ${booking_number}    ${user_fullname}
    Wait For Elements State    id=search    visible
    Type Text    id=search    ${booking_number}
    Sleep    500ms
    Click    [type="submit"]
    Sleep    500ms
    custom_keywords.Check Elements Text    [data-testid="pk-0"]    ${booking_number}
    custom_keywords.Find And Click Element With Text    [data-testid="reservee_name-0"] >> a    ${user_fullname}
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin Searches Reservation With Id Number And Checks The Status
    [Arguments]    ${booking_number}    ${reservation_status}
    Type Text    id=search    ${booking_number}
    Sleep    1s
    Click    [type="submit"]
    Sleep    500ms
    custom_keywords.Check Elements Text    [data-testid="pk-0"]    ${booking_number}
    custom_keywords.Check Elements Text    [data-testid="state-0"]    ${reservation_status}
    Sleep    2s

Admin Checks Reservation H1
    [Arguments]    ${h1_reservationnumber_firstname_lastname}
    Wait For Elements State    [data-testid="reservation_title_section__reservation_state"]    visible
    custom_keywords.Check Elements Text    h1    ${h1_reservationnumber_firstname_lastname}

Admin Checks Reservation Title Tagline
    [Arguments]    ${reservation_tagline}
    Wait For Elements State    [data-testid="reservation_title_section__tagline"]    visible

    # ${RESERVATION_TAGLINE} is set with keyword Formats tagline for admin side
    custom_keywords.Check Elements Text    [data-testid="reservation_title_section__tagline"]    ${reservation_tagline}

Admin Checks Reservation Info Dialog Time Tagline
    # TODO Not in use for now
    [Arguments]    ${reservation_tagline}
    custom_keywords.Find Text From Elements Or Fail
    ...    [class*="EditTimeModal__TimeInfoBox"] >> b
    ...    ${reservation_tagline}

Admin Checks Reservation User Info
    # TODO get better ids here
    custom_keywords.Find And Click Element With Text    css=.label    Tilan käyttäjän tiedot
    Sleep    500ms
    custom_keywords.Check Elements Text    [data-testid="reservation__info--Sukunimi"]    ${ADMIN_BEHALF_LASTNAME_FI}
    custom_keywords.Check Elements Text    [data-testid="reservation__info--Etunimi"]    ${ADMIN_BEHALF_FIRSTNAME_FI}

Admin Checks Reservation Maker Info
    # TODO get better ids here
    custom_keywords.Find And Click Element With Text    css=.label    Varauksen tekijä
    Sleep    500ms
    custom_keywords.Check Elements Text
    ...    [data-testid="reservation__info--Varauksen tekijä"]
    ...    ${BASIC_ADMIN_MALE_FULLNAME}
    custom_keywords.Check Elements Text    [data-testid="reservation__info--Sähköposti"]    ${BASIC_ADMIN_MALE_EMAIL}

Admin Checks Reservation Info After Handling
    [Arguments]
    ...    ${singlebooking_price}
    ...    ${singlebooking_status}
    ...    ${purpose_of_the_booking}
    ...    ${singlebooking_description}
    ...    ${singlebooking_number_of_participants}
    ...    ${singlebooking_age_group}
    ...    ${reason_of_rejection}

    # Check price if provided
    IF    "${singlebooking_price}" != "${NONE}"
        custom_keywords.Check Elements Text With Remove Non-breaking Space
        ...    [data-testid="reservation__summary--Hinta"]
        ...    ${singlebooking_price}
    END

    # Check status if provided
    IF    "${singlebooking_status}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation_title_section__reservation_state"]
        ...    ${singlebooking_status}
    END

    # Check purpose if provided
    IF    "${purpose_of_the_booking}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Käyttötarkoitus"]
        ...    ${purpose_of_the_booking}
    END

    # Check description if provided
    IF    "${singlebooking_description}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Kuvaus"]
        ...    ${singlebooking_description}
    END

    # Check number of participants if provided
    IF    "${singlebooking_number_of_participants}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Osallistujamäärä"]
        ...    ${singlebooking_number_of_participants}
    END

    # Check age group if provided
    IF    "${singlebooking_age_group}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Ikäryhmä"]
        ...    ${singlebooking_age_group}
    END

    # Check reason of rejection if provided
    IF    "${reason_of_rejection}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Hylkäyksen syy"]
        ...    ${reason_of_rejection}
    END

Admin Checks Reservation Info Before Handling
    [Arguments]    ${singlebooking_price}    ${singlebooking_status}    ${purpose_of_the_booking}
    ...    ${singlebooking_description}    ${singlebooking_number_of_participants}    ${singlebooking_age_group}

    # Check price if provided
    IF    "${singlebooking_price}" != "${NONE}"
        custom_keywords.Check Elements Text With Remove Non-breaking Space
        ...    [data-testid="reservation__summary--Hinta"]
        ...    ${singlebooking_price}
    END

    # Check status if provided
    IF    "${singlebooking_status}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation_title_section__reservation_state"]
        ...    ${singlebooking_status}
    END

    # Check purpose if provided
    IF    "${purpose_of_the_booking}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Käyttötarkoitus"]
        ...    ${purpose_of_the_booking}
    END

    # Check description if provided
    IF    "${singlebooking_description}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Kuvaus"]
        ...    ${singlebooking_description}
    END

    # Check number of participants if provided
    IF    "${singlebooking_number_of_participants}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Osallistujamäärä"]
        ...    ${singlebooking_number_of_participants}
    END

    # Check age group if provided
    IF    "${singlebooking_age_group}" != "${NONE}"
        custom_keywords.Check Elements Text
        ...    [data-testid="reservation__summary--Ikäryhmä"]
        ...    ${singlebooking_age_group}
    END

Admin Checks Reservation Status
    [Arguments]    ${status}
    Log    ${status}
    Sleep    2s
    Wait For Elements State    [data-testid="reservation_title_section__reservation_state"]    visible
    custom_keywords.Check Elements Text    [data-testid="reservation_title_section__reservation_state"]    ${status}

Admin Saves Reservation Number
    # Opens the reservation details section
    Click    id=reservation__reservation-details-heading
    Sleep    500ms
    Wait For Elements State    [data-testid="reservation__info--Varaustunnus"]    visible
    # Gets the reservation number
    ${reservation_number}=    Get Text    [data-testid="reservation__info--Varaustunnus"]
    Set Suite Variable    ${RESERVATION_NUMBER_ADMINSIDE}    ${reservation_number}

Admin Clicks Button In Reservation Page
    [Arguments]    ${button_data_id}
    Click    ${button_data_id}
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin Selects Reservation Unit
    [Arguments]    ${by_unit}
    Wait For Elements State    id=reservation-unit-toggle-button    visible
    Click    id=reservation-unit-toggle-button
    Sleep    1s
    Wait For Load State    load    timeout=15s
    custom_keywords.Find And Click Element With Text    id=reservation-unit-menu >> li    ${by_unit}
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin Open Access Code Modal
    Click    id=reservation__access-type
    # Wait for the modal to open
    Sleep    500ms

Admin Changes Access Code
    Click    [data-testid="AccessCodeChangeRepairButton--open-dialog"]
    # Wait for the modal to open
    Sleep    1s

###
# Dialog window
###

Admin Selects Reason For Rejection
    [Arguments]    ${reason_of_rejection}
    Wait For Elements State    id=denyReason-main-button    visible
    Click    id=denyReason-main-button
    Sleep    1s
    custom_keywords.Find And Click Element With Text    id=denyReason-list >> li    ${reason_of_rejection}

Admin Checks Reason For Subvention In Dialog
    custom_keywords.Find Text From Elements Or Fail    id=info-dialog >> p    ${JUSTIFICATION_FOR_SUBVENTION}

Admin Clicks Set Reservation To Free
    Wait For Elements State    id=clearPrice    visible
    Click    id=clearPrice
    Sleep    500ms
    ${value}=    Get Attribute    id=approvalPrice    value
    Should Be Equal    ${value}    0

Admin Fills Reservation Details Behalf
    # this keyword generates a random letter and number and uses that string as last name
    ${ADMIN_BEHALF_LASTNAME}=    data_modification.Generate Random Letter And Number
    Set Suite Variable    ${ADMIN_BEHALF_LASTNAME_FI}    ${ADMIN_BEHALF_LASTNAME}

    # this keyword generates the info for checking calendar content
    ${Calendar_event_content_name}=    data_modification.Formats Calendar Event Content
    ...    ${ADMIN_BEHALF_FIRSTNAME_FI}
    ...    ${ADMIN_BEHALF_LASTNAME_FI}
    ...    ${PREFIX_RESERVATIONS_BY_ADMIN_BEHALF_FI}
    Set Suite Variable    ${CALENDAR_EVENT_NAME}    ${Calendar_event_content_name}

    Type Text    [name="reserveeFirstName"]    ${ADMIN_BEHALF_FIRSTNAME_FI}
    Sleep    500ms
    Type Text    [name="reserveeLastName"]    ${ADMIN_BEHALF_LASTNAME_FI}
    Sleep    500ms
    Type Text    [name="reserveeEmail"]    ${BASIC_ADMIN_MALE_EMAIL}
    Sleep    500ms
    Type Text    [name="reserveePhone"]    ${ADMIN_BEHALF_PHONE_FI}
    Sleep    500ms

Admin Enters Reservation Time And Type Of Reservation
    [Documentation]    This keyword changes the time with date and hours and minutes.
    ...    This test uses 00 for minutes. So all the changed times will be 10:00–11:00 -> 15:00–17:00 etc.
    [Arguments]    ${type_of_reservation}    ${startTime-hours}    ${endTime-hours}    ${date}

    # Click    ${type_of_reservation}
    # Type Text    id=ReservationDialog.startTime-hours    ${startTime-hours}
    Type Text    id=TimeInput.startTime-hours    ${startTime-hours}
    Sleep    500ms
    # Type Text    id=ReservationDialog.startTime-minutes    00
    Type Text    id=TimeInput.startTime-minutes    00
    Sleep    500ms
    # Type Text    id=ReservationDialog.endTime-hours    ${endTime-hours}
    Type Text    id=TimeInput.endTime-hours    ${endTime-hours}
    Sleep    500ms
    # Type Text    id=ReservationDialog.endTime-minutes    00
    Type Text    id=TimeInput.endTime-minutes    00
    Sleep    500ms
    Type Text    id=controlled-date-input__date    ${date}
    Sleep    500ms

    Click    ${type_of_reservation}

Admin Clicks Confirm Access Code Button
    Click    [data-testid="AccessCodeChangeRepairButton__ConfirmationDialog--accept"]
    # Wait for the modal to open
    Sleep    500ms

Admin Closes Dialog Modal
    Click    id=info-dialog >> [data-testid="CreateReservationModal__cancel-reservation"]
    # waiting for the dialog to close
    Sleep    1s

###
# Reservation calendar
###

Admin Opens Calendar And Changes Reservation Time
    [Documentation]    This keyword opens the reservation calendar and changes the reservation time.
    ...    It uses the keyword 'Admin enters reservation time and type of reservation' to set the new time.

    Click    id=reservation__calendar-heading
    Sleep    500ms
    custom_keywords.Find And Click Element With Text
    ...    id=reservation__calendar-content >> button
    ...    ${CALENDAR_CHANGE_TIME_FI}

    Sleep    500ms
    Wait For Load State    load    timeout=15s

    # Call the keyword and capture the returned values
    ${date_plus_x_days}    ${start_hour}    ${end_hour}=    data_modification.Get Modified Date And Time

    Set Suite Variable    ${MODIFIED_DATE_SUBVENTED_RESERVATION}    ${date_plus_x_days}
    Set Suite Variable    ${MODIFIED_HOUR_STARTTIME_SUBVENTED_RESERVATION}    ${start_hour}
    Set Suite Variable    ${MODIFIED_HOUR_ENDTIME_SUBVENTED_RESERVATION}    ${end_hour}

    # This for the keyword Set and format the reservation finnish time
    Set Suite Variable    ${MODIFIED_STARTTIME_SUBVENTED_RESERVATION}    ${start_hour}.00

    # Changes the reservation time with date and hours and minutes
    Log    This test uses 00 for minutes. So all the changed times will be 10:00–11:00 -> 15:00–17:00 etc

    # TODO Admin enters reservation time and type of reservation could be used here
    # Type Text    id=ReservationDialog.startTime-hours    ${MODIFIED_HOUR_STARTTIME_SUBVENTED_RESERVATION}
    Type Text    id=TimeInput.startTime-hours    ${MODIFIED_HOUR_STARTTIME_SUBVENTED_RESERVATION}
    Sleep    500ms
    # Type Text    id=ReservationDialog.startTime-minutes    00
    Type Text    id=TimeInput.startTime-minutes    00
    Sleep    500ms
    # Type Text    id=ReservationDialog.endTime-hours    ${MODIFIED_HOUR_ENDTIME_SUBVENTED_RESERVATION}
    Type Text    id=TimeInput.endTime-hours    ${MODIFIED_HOUR_ENDTIME_SUBVENTED_RESERVATION}
    Sleep    500ms
    # Type Text    id=ReservationDialog.endTime-minutes    00
    Type Text    id=TimeInput.endTime-minutes    00
    Sleep    500ms
    Type Text    id=controlled-date-input__date    ${MODIFIED_DATE_SUBVENTED_RESERVATION}
    Sleep    1s
    #
    Wait For Elements State    button[type="submit"]    enabled    message= Check that the modified time is available?
    #
    Focus    button[type="submit"]
    Click    button[type="submit"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Finds Reservation And Clicks It
    [Arguments]    ${reservation_name}
    Sleep    3s
    custom_keywords.Find And Click Element With Exact Text Using JS
    ...    [role="button"] >> css=.rbc-event-content
    ...    ${reservation_name}
    Sleep    500ms
    Wait For Load State    load    timeout=15s
