*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Resource    ../Admin/admin_reservations.robot
Resource    ../Admin/admin_mainmenu.robot
Resource    ../Admin/admin_my_units.robot
Resource    ../../Resources/data_modification.robot
Resource    ../App/app_common.robot
Library     Browser


*** Keywords ***
###
# Front page
###

Admin checks the info and sets reservation free and approves it
    Sleep    3s
    admin_reservations.Admin checks reservation h1    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
    admin_reservations.Admin checks reservation title tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin checks reservation info before handling
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_ADMIN_SIDE}    ${ADMIN_STATUS_PROCESSED}
    ...    ${PURPOSE_OF_THE_BOOKING}    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}    ${SINGLEBOOKING_SUBVENTED_ADMIN_SIDE_AGE_GROUP}
    admin_reservations.Admin clicks button in reservation page    [data-testid="approval-buttons__approve-button"]
    admin_reservations.Admin checks reason for subvention in dialog
    admin_reservations.Admin clicks set reservation to free
    admin_reservations.Admin clicks button in reservation page    [data-testid="approval-dialog__accept-button"]
    admin_reservations.Admin checks reservation info after handling
    ...    ${SINGLEBOOKING_NO_PAYMENT_ADMIN_SIDE}    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${PURPOSE_OF_THE_BOOKING}    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}    ${SINGLEBOOKING_SUBVENTED_ADMIN_SIDE_AGE_GROUP}    ${NONE}

Admin checks the info and cancels reservation
    admin_reservations.Admin checks reservation h1    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
    admin_reservations.Admin checks reservation title tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin checks reservation info before handling
    ...    ${DEFAULT_PRICE_ALWAYS_REQUESTED_UNIT}
    ...    ${ADMIN_STATUS_PROCESSED}
    ...    ${PURPOSE_OF_THE_BOOKING}
    ...    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    ...    ${NONE}
    app_admin.Admin rejects reservation and checks the status
    admin_reservations.Admin saves reservation number
    admin_reservations.Admin checks reservation info after handling
    ...    ${DEFAULT_PRICE_ALWAYS_REQUESTED_UNIT}
    ...    ${MYBOOKINGS_STATUS_REJECTED}
    ...    ${PURPOSE_OF_THE_BOOKING}
    ...    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    ...    ${NONE}
    ...    ${ADMIN_REASON_REJECTED}

Admin returns reservation to handling state from rejected state
    admin_reservations.Admin clicks button in reservation page
    ...    [data-testid="approval-buttons__return-to-handling-button"]
    Sleep    1s
    Wait For Elements State    id=info-dialog    visible
    Find and click element with text    id=info-dialog >> span    ${RESERVATION_STATUS_DIALOG}
    Sleep    2s
    admin_reservations.Admin checks reservation status    ${ADMIN_STATUS_PROCESSED}

Admin edits reservation time
    Log    Reservation needs to be approved first in order to do this step

    # This sets the variables for ${MODIFIED_HOUR_STARTTIME_SUBVENTED_RESERVATION}, ${MODIFIED_HOUR_ENDTIME_SUBVENTED_RESERVATION}, ${MODIFIED_DATE_SUBVENTED_RESERVATION}, ${MODIFIED_STARTTIME_SUBVENTED_RESERVATION}
    admin_reservations.Admin opens calendar and changes reservation time

    data_modification.Set info card duration time info
    ...    ${MODIFIED_STARTTIME_SUBVENTED_RESERVATION}
    ...    ${MODIFIED_DATE_SUBVENTED_RESERVATION}
    ${admin_modified_formatted_date}    ${admin_modified_formatted_date_minus_t}=    Set info card duration time info
    ...    ${MODIFIED_STARTTIME_SUBVENTED_RESERVATION}
    ...    ${MODIFIED_DATE_SUBVENTED_RESERVATION}

    Set Suite Variable    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD}    ${admin_modified_formatted_date}
    Set Suite Variable    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD_MINUS_T}    ${admin_modified_formatted_date_minus_t}

    # This sets ${RESERVATION_TAGLINE} back to client side.
    data_modification.Formats tagline for admin side
    ...    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD}
    ...    ${ALWAYS_PAID_UNIT_SUBVENTED_WITH_UNIT_LOCATION}

    admin_reservations.Admin checks reservation h1    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
    admin_reservations.Admin checks reservation title tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin checks reservation status    ${MYBOOKINGS_STATUS_CONFIRMED}

Admin navigates to own units and selects unit
    [Arguments]    ${unit_name}
    admin_mainmenu.Admin navigates to my units
    admin_my_units.Admin searches own unit and clicks it    ${UNIT_LOCATION}
    admin_my_units.Admin clicks calendar open in own units    ${unit_name}

Admin tries to make reserevation that is unavailable
    [Arguments]    ${unit_name}
    admin_my_units.Admin clicks calendar open in own units    ${unit_name}

Admin navigates to reservations by units and checks reserevation info
    # TODO lets fix this to better keyword
    ${ByUnitsElement}=    Browser.Get Element    css=[role="tablist"] >> span:text-is("${RESERVATIONS_BY_UNITS_FI}")
    Click    ${ByUnitsElement}
    admin_reservations.Admin selects reservation unit    ${ALWAYS_FREE_UNIT}
    admin_reservations.Admin finds reservation and clicks it    ${CALENDAR_EVENT_NAME}
    app_common.Switch to new tab from current page
    admin_reservations.Admin checks reservation title tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin checks reservation user info

Admin rejects reservation and checks the status
    admin_reservations.Admin clicks button in reservation page    [data-testid="approval-buttons__reject-button"]
    admin_reservations.Admin selects reason for rejection    ${ADMIN_REASON_REJECTED}
    Sleep    1s
    Click    [data-testid="deny-dialog__deny-button"]
    Sleep    2s
    admin_reservations.Admin checks reservation status    ${MYBOOKINGS_STATUS_REJECTED}

Admin makes reservation for behalf
    Log
    ...    This sets variables for MODIFIED_HOUR_STARTTIME_SUBVEBTED_RESERVATION, MODIFIED_HOUR_ENDTIME_SUBVEBTED_RESERVATION, MODIFIED_DATE_SUBVEBTED_RESERVATION and MODIFIED_STARTTIME_SUBVEBTED_RESERVATION

    # Call the keyword and capture the returned values
    ${date_plus_x_days}    ${start_hour}    ${end_hour}=    data_modification.Get modified date and time

    Set Suite Variable    ${UNAVAILABLE_RESERVATION_DATE}    ${date_plus_x_days}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}    ${start_hour}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}    ${end_hour}

    admin_reservations.Admin enters reservation time and type of reservation
    ...    [for=BEHALF]
    ...    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}
    ...    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}
    ...    ${UNAVAILABLE_RESERVATION_DATE}
    admin_reservations.Admin fills reservation details behalf    # this keyword generates the info for checking calendar content
    admin_reservations.Admin clicks button in reservation page
    ...    [data-testid="CreateReservationModal__accept-reservation"]
    Sleep    2s

Admin makes reservation for closed
    # Call the keyword and capture the returned values
    ${date_plus_x_days}    ${start_hour}    ${end_hour}=    data_modification.Get modified date and time

    Set Suite Variable    ${UNAVAILABLE_RESERVATION_DATE}    ${date_plus_x_days}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}    ${start_hour}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}    ${end_hour}

    admin_reservations.Admin enters reservation time and type of reservation
    ...    [for=BLOCKED]
    ...    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}
    ...    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}
    ...    ${UNAVAILABLE_RESERVATION_DATE}
    admin_reservations.Admin clicks button in reservation page
    ...    [data-testid="CreateReservationModal__accept-reservation"]
    Sleep    2s

Admin makes reservation for staff
    # Call the keyword and capture the returned values
    ${date_plus_x_days}    ${start_hour}    ${end_hour}=    data_modification.Get modified date and time

    Set Suite Variable    ${UNAVAILABLE_RESERVATION_DATE}    ${date_plus_x_days}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}    ${start_hour}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}    ${end_hour}

    admin_reservations.Admin enters reservation time and type of reservation
    ...    [for=STAFF]
    ...    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}
    ...    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}
    ...    ${UNAVAILABLE_RESERVATION_DATE}
    admin_reservations.Admin clicks button in reservation page
    ...    [data-testid="CreateReservationModal__accept-reservation"]
    Sleep    2s

Admin attempts to make an unavailable reservation
    admin_reservations.Admin enters reservation time and type of reservation
    ...    [for="BEHALF"]
    ...    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}
    ...    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}
    ...    ${UNAVAILABLE_RESERVATION_DATE}
    custom_keywords.Check elements text
    ...    [data-testid="CreateReservationModal__collision-warning"] >> [class*="Notification-module_body__"]
    ...    ${RESERVATION_TIME_NOT_FREE}
    Click    data-testid=CreateReservationModal__cancel-reservation
