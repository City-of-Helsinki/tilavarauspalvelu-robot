*** Settings ***
Resource    ../Admin/admin_reservations.robot
Resource    ../Admin/admin_navigation_menu.robot
Resource    ../Admin/admin_my_units.robot
Resource    ../Admin/admin_notifications_create_page.robot
Resource    ../Admin/admin_notifications.robot
Resource    ../App/app_common.robot
Resource    ../../Resources/data_modification.robot
Resource    ../../Resources/custom_keywords.robot
Library     Browser


*** Keywords ***
Admin checks the info and sets reservation free and approves it
    admin_reservations.Admin checks reservation h1    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
    admin_reservations.Admin checks reservation title tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin checks reservation info before handling
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_ADMIN_SIDE}    ${ADMIN_STATUS_PROCESSED}
    ...    ${PURPOSE_OF_THE_BOOKING}    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}    ${SINGLEBOOKING_SUBVENTED_ADMIN_SIDE_AGE_GROUP}
    admin_reservations.Admin clicks button in reservation page    [data-testid="approval-buttons__approve-button"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s
    admin_reservations.Admin checks reason for subvention in dialog
    admin_reservations.Admin clicks set reservation to free
    admin_reservations.Admin clicks button in reservation page    [data-testid="approval-dialog__accept-button"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s
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
    admin_navigation_menu.Admin navigates to my units
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
    Wait For Load State    load    timeout=15s
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
    Sleep    500ms
    Wait For Load State    load    timeout=15s

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
    Sleep    500ms
    Wait For Load State    load    timeout=15s

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
    Sleep    500ms
    Wait For Load State    load    timeout=15s

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
    Sleep    500ms
    Wait For Load State    load    timeout=15s

###
# Notifications
###

Admin creates normal notification for user and admin side
    admin_notifications.Admin clicks create notification button
    #
    admin_notifications_create_page.Admin selects validity period to immediately
    #
    ${date_plus_60_days}=    data_modification.Get date plus 60 days
    Set Suite Variable    ${NOTIFICATION_ACTIVE_UNTIL}    ${date_plus_60_days}
    #
    admin_notifications_create_page.Admin selects notification active until
    ...    ${NOTIFICATION_ACTIVE_UNTIL}
    #
    # if the notification name exist already we cannot publish the notification
    ${randomvalue}=    data_modification.Generate random letter and number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    ...    ${NOTIFICATION_BANNER_MESSAGE_NORMAL} ${randomvalue}
    admin_notifications_create_page.Admin fills notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    #
    admin_notifications_create_page.Admin selects type of notification    ${NOTIFICATION_BANNER_MESSAGE_NORMAL}
    #
    admin_notifications_create_page.Admin selects target group all
    #

    ${randomvalue}=    data_modification.Generate random letter and number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_BANNER_MESSAGE_NORMAL} ${randomvalue}
    #
    admin_notifications_create_page.Admin fills notification text fi    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    #
    admin_notifications_create_page.Admin publishes notification

Admin creates warning notification for user and admin side
    admin_notifications.Admin clicks create notification button
    #
    admin_notifications_create_page.Admin selects validity period to immediately
    #
    ${date_plus_60_days}=    data_modification.Get date plus 60 days
    Set Suite Variable    ${NOTIFICATION_ACTIVE_UNTIL}    ${date_plus_60_days}
    #
    admin_notifications_create_page.Admin selects notification active until
    ...    ${NOTIFICATION_ACTIVE_UNTIL}
    #
    # if the notification name exist already we cannot publish the notification
    ${randomvalue}=    data_modification.Generate random letter and number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    ...    ${NOTIFICATION_BANNER_MESSAGE_WARNING} ${randomvalue}
    admin_notifications_create_page.Admin fills notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    #
    admin_notifications_create_page.Admin selects type of notification    ${NOTIFICATION_BANNER_MESSAGE_WARNING}
    #
    admin_notifications_create_page.Admin selects target group all
    #
    ${randomvalue}=    data_modification.Generate random letter and number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_BANNER_MESSAGE_WARNING} ${randomvalue}
    #
    admin_notifications_create_page.Admin fills notification text fi    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    #
    admin_notifications_create_page.Admin publishes notification

Admin creates error notification for user and admin side
    admin_notifications.Admin clicks create notification button
    #
    admin_notifications_create_page.Admin selects validity period to immediately
    #
    ${date_plus_60_days}=    data_modification.Get date plus 60 days
    Set Suite Variable    ${NOTIFICATION_ACTIVE_UNTIL}    ${date_plus_60_days}
    #
    admin_notifications_create_page.Admin selects notification active until
    ...    ${NOTIFICATION_ACTIVE_UNTIL}
    #
    # if the notification name exist already we cannot publish the notification
    ${randomvalue}=    data_modification.Generate random letter and number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    ...    ${NOTIFICATION_BANNER_MESSAGE_ERROR} ${randomvalue}
    admin_notifications_create_page.Admin fills notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    #
    admin_notifications_create_page.Admin selects type of notification    ${NOTIFICATION_BANNER_MESSAGE_ERROR}
    #
    admin_notifications_create_page.Admin selects target group all
    #

    ${randomvalue}=    data_modification.Generate random letter and number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_BANNER_MESSAGE_ERROR} ${randomvalue}
    #
    admin_notifications_create_page.Admin fills notification text fi    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    #
    admin_notifications_create_page.Admin publishes notification
