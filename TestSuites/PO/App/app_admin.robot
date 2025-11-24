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
Admin Checks The Info And Sets Reservation Free And Approves It
    admin_reservations.Admin Checks Reservation H1    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
    admin_reservations.Admin Checks Reservation Title Tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin Checks Reservation Info Before Handling
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_ADMIN_SIDE}    ${ADMIN_STATUS_PROCESSED}
    ...    ${PURPOSE_OF_THE_BOOKING}    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}    ${SINGLEBOOKING_SUBVENTED_ADMIN_SIDE_AGE_GROUP}
    admin_reservations.Admin Clicks Button In Reservation Page    [data-testid="approval-buttons__approve-button"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s
    admin_reservations.Admin Checks Reason For Subvention In Dialog
    admin_reservations.Admin Clicks Set Reservation To Free
    admin_reservations.Admin Clicks Button In Reservation Page    [data-testid="approval-dialog__accept-button"]
    # Waiting payment status to be updated
    Sleep    1.5s
    Wait For Load State    load    timeout=15s
    admin_reservations.Admin Checks Reservation Info After Handling
    ...    ${SINGLEBOOKING_NO_PAYMENT_ADMIN_SIDE}    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${PURPOSE_OF_THE_BOOKING}    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}    ${SINGLEBOOKING_SUBVENTED_ADMIN_SIDE_AGE_GROUP}    ${NONE}

Admin Checks The Info And Cancels Reservation
    admin_reservations.Admin Checks Reservation H1    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
    admin_reservations.Admin Checks Reservation Title Tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin Checks Reservation Info Before Handling
    ...    ${DEFAULT_PRICE_ALWAYS_REQUESTED_UNIT}
    ...    ${ADMIN_STATUS_PROCESSED}
    ...    ${PURPOSE_OF_THE_BOOKING}
    ...    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    ...    ${NONE}
    app_admin.Admin Rejects Reservation And Checks The Status
    admin_reservations.Admin Saves Reservation Number
    admin_reservations.Admin Checks Reservation Info After Handling
    ...    ${DEFAULT_PRICE_ALWAYS_REQUESTED_UNIT}
    ...    ${MYBOOKINGS_STATUS_REJECTED}
    ...    ${PURPOSE_OF_THE_BOOKING}
    ...    ${SINGLEBOOKING_DESCRIPTION}
    ...    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    ...    ${NONE}
    ...    ${ADMIN_REASON_REJECTED}

Admin Returns Reservation To Handling State From Rejected State
    admin_reservations.Admin Clicks Button In Reservation Page
    ...    [data-testid="approval-buttons__return-to-handling-button"] >> nth=-1
    Sleep    1s
    Wait For Elements State    id=info-dialog    visible
    Find And Click Element With Text    id=info-dialog >> span    ${RESERVATION_STATUS_DIALOG}
    Sleep    2s
    admin_reservations.Admin Checks Reservation Status    ${ADMIN_STATUS_PROCESSED}

Admin Edits Reservation Time
    Log    Reservation needs to be approved first in order to do this step

    # This sets the variables for ${MODIFIED_HOUR_STARTTIME_SUBVENTED_RESERVATION}, ${MODIFIED_HOUR_ENDTIME_SUBVENTED_RESERVATION}, ${MODIFIED_DATE_SUBVENTED_RESERVATION}, ${MODIFIED_STARTTIME_SUBVENTED_RESERVATION}
    admin_reservations.Admin Opens Calendar And Changes Reservation Time
    data_modification.Set Info Card Duration Time Info
    ...    ${MODIFIED_STARTTIME_SUBVENTED_RESERVATION}
    ...    ${MODIFIED_DATE_SUBVENTED_RESERVATION}
    ${admin_modified_formatted_date}    ${admin_modified_formatted_date_minus_t}=    Set Info Card Duration Time Info
    ...    ${MODIFIED_STARTTIME_SUBVENTED_RESERVATION}
    ...    ${MODIFIED_DATE_SUBVENTED_RESERVATION}

    Set Suite Variable    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD}    ${admin_modified_formatted_date}
    Set Suite Variable    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD_MINUS_T}    ${admin_modified_formatted_date_minus_t}

    # This sets ${RESERVATION_TAGLINE} back to client side.
    data_modification.Formats Tagline For Admin Side
    ...    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD}
    ...    ${ALWAYS_PAID_UNIT_SUBVENTED_WITH_UNIT_LOCATION}
    admin_reservations.Admin Checks Reservation H1    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}
    admin_reservations.Admin Checks Reservation Title Tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin Checks Reservation Status    ${MYBOOKINGS_STATUS_CONFIRMED}

Admin Navigates To Own Units And Selects Unit Group
    # TODO: separate this to two keywords
    [Arguments]    ${unit_group_name}
    admin_navigation_menu.Admin Navigates To My Units
    admin_my_units.Admin Searches Own Unit And Clicks It    ${unit_group_name}
    # TODO: old version for using calendar UI
    # admin_my_units.Admin clicks calendar open in own units    ${unit_name}
    # admin_my_units.Admin clicks make reservation
    # admin_my_units.Admin selects unit from reservation units dropdown    ${unit_name}

Admin Opens Make Reservation Modal And Selects Unit
    [Arguments]    ${unit_name}
    admin_my_units.Admin Clicks Make Reservation
    admin_my_units.Admin Selects Unit From Reservation Units Dropdown    ${unit_name}

Admin Checks That Reservation Cannot Be Made
    admin_my_units.Admin Checks Make Reservation Button Is Disabled

###
# Access code
###

Admin Opens Access Code Modal
    admin_reservations.Admin Open Access Code Modal

Admin Changes Access Code
    admin_reservations.Admin Changes Access Code
    admin_reservations.Admin Clicks Confirm Access Code Button
    # waiting for the access code to be changed
    Sleep    3s
    Wait For Elements State    [data-testid="reservation__info--Ovikoodi"]    visible    timeout=5s

Admin Checks Access Code Matches
    [Documentation]    Verifies that the access code matches the expected value (extracts numbers only).
    [Arguments]    ${access_code}
    custom_keywords.Check Elements Text
    ...    [data-testid="reservation__info--Ovikoodi"]
    ...    ${access_code}

Admin Checks Access Code Does Not Match
    [Documentation]    Verifies that the access code does NOT match the expected value (extracts numbers only).
    [Arguments]    ${access_code}
    custom_keywords.Verify Element With Text Is Not Found
    ...    [data-testid="reservation__info--Ovikoodi"]
    ...    ${access_code}

Admin Saves Access Code
    ${access_code}=    Get Text    [data-testid="reservation__info--Ovikoodi"]
    Store Test Data Variable    ACCESS_CODE_ADMINSIDE    ${access_code}
    Set Test Variable    ${ACCESS_CODE_ADMINSIDE}    ${access_code}
    Log    ${ACCESS_CODE_ADMINSIDE}

###
###

###
# Top navigation
###

###
# Basic permissions
###

Admin Checks Top Navigation For Notification Manager
    custom_keywords.Verify Element Is Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservations/requested"]

Admin Checks Top Navigation For Reserver
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]

Admin Checks Top Navigation For Viewer
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]

Admin Checks Top Navigation For Handler
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]

Admin Checks Top Navigation For Admin
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/units"]
##
##

###
# Unit permissions
###

Admin Checks Top Navigation For Notification Manager With Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservations/requested"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]

Admin Checks Top Navigation For Viewer With Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]

Admin Checks Top Navigation For Reserver With Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]

Admin Checks Top Navigation For Handler With Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]

Admin Checks Top Navigation For Admin With Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]

##
##

###
# Group unit permissions
###

Admin Checks Top Navigation For Notification Manager With Group Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservations/requested"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]

Admin Checks Top Navigation For Viewer With Group Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]

Admin Checks Top Navigation For Reserver With Group Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]

Admin Checks Top Navigation For Handler With Group Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]

Admin Checks Top Navigation For Admin With Group Unit Permissions
    custom_keywords.Verify Element Is Not Found    [href="/kasittely/notifications"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/application-rounds"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservation-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/my-units"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations"]
    custom_keywords.Verify Element Is Found    [href="/kasittely/reservations/requested"]

##
##

Admin Navigates To Reservations By Units And Checks Reservation Info
    # TODO lets fix this to better keyword
    ${ByUnitsElement}=    Browser.Get Element    css=[role="tablist"] >> span:text-is("${RESERVATIONS_BY_UNITS_FI}")
    Click    ${ByUnitsElement}
    admin_reservations.Admin Selects Reservation Unit    ${ALWAYS_FREE_UNIT}
    admin_reservations.Admin Finds Reservation And Clicks It    ${CALENDAR_EVENT_NAME}
    app_common.Switch To New Tab From Current Page
    admin_reservations.Admin Checks Reservation Title Tagline    ${RESERVATION_TAGLINE}
    admin_reservations.Admin Checks Reservation User Info

Admin Clicks Make Reservation And Checks Dialog Opens
    admin_my_units.Admin Clicks Make Reservation
    Sleep    1s
    Wait For Elements State
    ...    id=info-dialog
    ...    visible
    ...    timeout=5s
    ...    message=Info dialog should be visible after clicking make reservation button

Admin Rejects Reservation And Checks The Status
    # Get all elements and click the last one to avoid strict mode violation that might happen
    # when accordion is open
    ${elements}=    Browser.Get Elements    [data-testid="approval-buttons__reject-button"]
    ${element_count}=    Get Length    ${elements}
    Log    Found ${element_count} reject buttons
    Click    ${elements}[-1]
    Sleep    500ms
    Wait For Load State    load    timeout=15s
    admin_reservations.Admin Selects Reason For Rejection    ${ADMIN_REASON_REJECTED}
    Sleep    1s
    Click    [data-testid="deny-dialog__deny-button"]
    Sleep    2s
    Wait For Load State    load    timeout=15s
    admin_reservations.Admin Checks Reservation Status    ${MYBOOKINGS_STATUS_REJECTED}

Admin Makes Reservation For Behalf
    Log
    ...    This sets variables for MODIFIED_HOUR_STARTTIME_SUBVEBTED_RESERVATION, MODIFIED_HOUR_ENDTIME_SUBVEBTED_RESERVATION, MODIFIED_DATE_SUBVEBTED_RESERVATION and MODIFIED_STARTTIME_SUBVEBTED_RESERVATION

    # Call the keyword and capture the returned values
    ${date_plus_x_days}    ${start_hour}    ${end_hour}=    data_modification.Get Modified Date And Time

    Set Suite Variable    ${UNAVAILABLE_RESERVATION_DATE}    ${date_plus_x_days}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}    ${start_hour}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}    ${end_hour}

    admin_reservations.Admin Enters Reservation Time And Type Of Reservation
    ...    [for=BEHALF]
    ...    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}
    ...    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}
    ...    ${UNAVAILABLE_RESERVATION_DATE}
    admin_reservations.Admin Fills Reservation Details Behalf    # this keyword generates the info for checking calendar content
    admin_reservations.Admin Clicks Button In Reservation Page
    ...    [data-testid="CreateReservationModal__accept-reservation"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin Makes Reservation For Closed
    # Call the keyword and capture the returned values
    ${date_plus_x_days}    ${start_hour}    ${end_hour}=    data_modification.Get Modified Date And Time

    Set Suite Variable    ${UNAVAILABLE_RESERVATION_DATE}    ${date_plus_x_days}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}    ${start_hour}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}    ${end_hour}

    admin_reservations.Admin Enters Reservation Time And Type Of Reservation
    ...    [for=BLOCKED]
    ...    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}
    ...    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}
    ...    ${UNAVAILABLE_RESERVATION_DATE}
    admin_reservations.Admin Clicks Button In Reservation Page
    ...    [data-testid="CreateReservationModal__accept-reservation"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin Makes Reservation For Staff
    # Call the keyword and capture the returned values
    ${date_plus_x_days}    ${start_hour}    ${end_hour}=    data_modification.Get Modified Date And Time

    Set Suite Variable    ${UNAVAILABLE_RESERVATION_DATE}    ${date_plus_x_days}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}    ${start_hour}
    Set Suite Variable    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}    ${end_hour}

    admin_reservations.Admin Enters Reservation Time And Type Of Reservation
    ...    [for=STAFF]
    ...    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}
    ...    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}
    ...    ${UNAVAILABLE_RESERVATION_DATE}
    admin_reservations.Admin Clicks Button In Reservation Page
    ...    [data-testid="CreateReservationModal__accept-reservation"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin Attempts To Make An Unavailable Reservation
    admin_reservations.Admin Enters Reservation Time And Type Of Reservation
    ...    [for="BEHALF"]
    ...    ${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}
    ...    ${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}
    ...    ${UNAVAILABLE_RESERVATION_DATE}
    Wait For Elements State    [data-testid="CreateReservationModal__accept-reservation"]    visible
    Sleep    1s
    Scroll To Element    [data-testid="CreateReservationModal__accept-reservation"]
    custom_keywords.Check Elements Text
    ...    [data-testid="CreateReservationModal__collision-warning"] >> [class*="Notification-module_body__"]
    ...    ${RESERVATION_TIME_NOT_FREE}
    Click    data-testid=CreateReservationModal__cancel-reservation
    Sleep    500ms
    Wait For Load State    load    timeout=15s

###
# Notifications
###

Admin Creates Normal Notification For User And Admin Side
    admin_notifications.Admin Clicks Create Notification Button
    #
    admin_notifications_create_page.Admin Selects Validity Period To Immediately
    #
    ${date_plus_60_days}=    data_modification.Get Date Plus 60 Days
    Set Suite Variable    ${NOTIFICATION_ACTIVE_UNTIL}    ${date_plus_60_days}
    #
    admin_notifications_create_page.Admin Selects Notification Active Until
    ...    ${NOTIFICATION_ACTIVE_UNTIL}
    #
    # if the notification name exist already we cannot publish the notification
    ${randomvalue}=    data_modification.Generate Random Letter And Number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    ...    ${NOTIFICATION_BANNER_MESSAGE_NORMAL} ${randomvalue}
    admin_notifications_create_page.Admin Fills Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    #
    admin_notifications_create_page.Admin Selects Type Of Notification    ${NOTIFICATION_BANNER_MESSAGE_NORMAL}
    #
    admin_notifications_create_page.Admin Selects Target Group All
    #

    ${randomvalue}=    data_modification.Generate Random Letter And Number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_BANNER_MESSAGE_NORMAL} ${randomvalue}
    #
    admin_notifications_create_page.Admin Fills Notification Text Fi    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    #
    admin_notifications_create_page.Admin Publishes Notification

Admin Creates Warning Notification For User And Admin Side
    admin_notifications.Admin Clicks Create Notification Button
    #
    admin_notifications_create_page.Admin Selects Validity Period To Immediately
    #
    ${date_plus_60_days}=    data_modification.Get Date Plus 60 Days
    Set Suite Variable    ${NOTIFICATION_ACTIVE_UNTIL}    ${date_plus_60_days}
    #
    admin_notifications_create_page.Admin Selects Notification Active Until
    ...    ${NOTIFICATION_ACTIVE_UNTIL}
    #
    # if the notification name exist already we cannot publish the notification
    ${randomvalue}=    data_modification.Generate Random Letter And Number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    ...    ${NOTIFICATION_BANNER_MESSAGE_WARNING} ${randomvalue}
    admin_notifications_create_page.Admin Fills Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    #
    admin_notifications_create_page.Admin Selects Type Of Notification    ${NOTIFICATION_BANNER_MESSAGE_WARNING}
    #
    admin_notifications_create_page.Admin Selects Target Group All
    #
    ${randomvalue}=    data_modification.Generate Random Letter And Number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_BANNER_MESSAGE_WARNING} ${randomvalue}
    #
    admin_notifications_create_page.Admin Fills Notification Text Fi    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    #
    admin_notifications_create_page.Admin Publishes Notification

Admin Creates Error Notification For User And Admin Side
    admin_notifications.Admin Clicks Create Notification Button
    #
    admin_notifications_create_page.Admin Selects Validity Period To Immediately
    #
    ${date_plus_60_days}=    data_modification.Get Date Plus 60 Days
    Set Suite Variable    ${NOTIFICATION_ACTIVE_UNTIL}    ${date_plus_60_days}
    #
    admin_notifications_create_page.Admin Selects Notification Active Until
    ...    ${NOTIFICATION_ACTIVE_UNTIL}
    #
    # if the notification name exist already we cannot publish the notification
    ${randomvalue}=    data_modification.Generate Random Letter And Number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    ...    ${NOTIFICATION_BANNER_MESSAGE_ERROR} ${randomvalue}
    admin_notifications_create_page.Admin Fills Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    #
    admin_notifications_create_page.Admin Selects Type Of Notification    ${NOTIFICATION_BANNER_MESSAGE_ERROR}
    #
    admin_notifications_create_page.Admin Selects Target Group All
    #

    ${randomvalue}=    data_modification.Generate Random Letter And Number
    Set Suite Variable
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_BANNER_MESSAGE_ERROR} ${randomvalue}
    #
    admin_notifications_create_page.Admin Fills Notification Text Fi    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    #
    admin_notifications_create_page.Admin Publishes Notification
