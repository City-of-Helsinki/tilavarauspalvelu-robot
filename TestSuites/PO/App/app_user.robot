*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/texts_FI.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Resource    ../../Resources/parallel_test_data.robot
Resource    ../User/recurring.robot
Resource    ../User/recurring_applications.robot
Resource    ../User/recurring_applications_page2.robot
Resource    ../User/recurring_applications_page3.robot
Resource    ../User/recurring_applications_page_preview.robot
Resource    ../User/recurring_applications_page_sent.robot
Resource    ../Common/topnav.robot
Resource    ../Common/checkout.robot
Resource    ../Common/popups.robot
Resource    ../User/reservation_calendar.robot
Resource    ../User/quick_reservation.robot
Resource    ../User/user_landingpage.robot
Resource    ../User/reservation_unit_reserver_info.robot
Resource    ../User/reservation_unit_reserver_types.robot
Resource    ../User/reservation_unit_booking_details.robot
Resource    ../User/reservation_unit_reservation_receipt.robot
Resource    ../User/reservation_lownav.robot
Resource    ../User/singlebooking.robot
Resource    ../User/mybookings.robot
Library     OperatingSystem


*** Keywords ***
###
# Front page
###

User Navigates To Single Booking Page
    topnav.Navigate To Single Booking Page

User Navigates To My Bookings
    topnav.Navigate To My Bookings

User Navigates To Recurring Booking Page
    topnav.Navigate To Recurring Booking Page
    Wait For Load State    load    timeout=15s

###

###
# Payment notification banner
###

User Accepts Payment To Checkout
    Log    This clicks approve button from notification banner
    Sleep    1.5s    # Wait for banner to load
    user_landingpage.Approve Interrupted Payment

###

###
# Checkout
###

User Checks Info In Paid Checkout And Confirms Booking
    Log    This step gets the reservation number
    checkout.Check The Info In Checkout

User Interrupts Paid Checkout
    [Arguments]    ${input_URL}
    checkout.Interrupted Checkout    ${input_URL}
    Sleep    1s
    user_landingpage.Check The User Landing Page H1    ${USER_LANDING_PAGE_H1_TEXT}
###

###
# Singlebooking
###

User Uses Search To Find Right Unit
    [Arguments]    ${nameoftheunit}

    # This checks if the search element is visible; if it isn’t, it clicks the "advanced search" toggle button to make it visible.
    singlebooking.Click Advanced Search If Search Not Visible
    singlebooking.Search Units By Name    ${nameoftheunit}

    # Waiting results to load
    Sleep    2s
    Wait For Load State    load    timeout=10s

    custom_keywords.Find And Click Element With Text
    ...    [data-testid="list-with-pagination__list--container"] >> [data-testid="card__heading"]
    ...    ${nameoftheunit}

    # Waiting results to load
    Sleep    2s
    Wait For Load State    load    timeout=10s

User Selects The Time With Quick Reservation And Sets Time Variables
    [Documentation]    here is keyword --> data_modification.Set info card duration time info
    ...    that sets $TIME_OF_QUICK_RESERVATION and $TIME_OF_QUICK_RESERVATION_MINUS_T

    Sleep    1s
    Wait For Elements State    id=quick-reservation    visible
    quick_reservation.Select Duration    ${QUICK_RESERVATION_DURATION}

    # Checks that calendar opens and has all the buttons inside
    quick_reservation.Confirms Date Picker Opens From Quick Reservation

    ${quick_reservation_current_date_value}=    quick_reservation.Get The Value From Date Input

    # This sets ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    quick_reservation.Select The Free Slot From Quick Reservation

    # Wait for load
    Sleep    1.5s
    Wait For Load State    load    timeout=50s
    Log    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}

    ${formatted_date}    ${formatted_date_minus_t}=    data_modification.Set Info Card Duration Time Info
    ...    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    ...    ${quick_reservation_current_date_value}

    Store Test Data Variable    TIME_OF_QUICK_RESERVATION    ${formatted_date}
    Store Test Data Variable    TIME_OF_QUICK_RESERVATION_MINUS_T    ${formatted_date_minus_t}
    Set Test Variable    ${TIME_OF_QUICK_RESERVATION}    ${formatted_date}
    Set Test Variable    ${TIME_OF_QUICK_RESERVATION_MINUS_T}    ${formatted_date_minus_t}

    Log    ${TIME_OF_QUICK_RESERVATION}
    Log    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

User Checks That Quick Reservation Does Not Have Reserved Time
    [Arguments]    ${reservationtime}
    Wait For Load State    load    timeout=15s
    Log    ${reservationtime}
    quick_reservation.Verify Time Slot Not Available    ${reservationtime}

User Checks That Reservation Calendar Does Not Have Reserved Time Slot Available
    [Documentation]    This keyword uses data_modification.Convert finnish short day to english and
    ...    data_modification.Compute reservation timeslot to set variables

    Log    This keyword sets the variable '${ENGLISH_DAY}'
    data_modification.Convert Finnish Short Day To English    ${TIME_OF_QUICK_RESERVATION}

    Log    This keyword sets the variable '${CALENDAR_TIMESLOT}'
    data_modification.Compute Reservation Time Slot
    ...    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    ...    ${QUICK_RESERVATION_DURATION}

    custom_keywords.Verify Reservation Slot Exists    ${CALENDAR_TIMESLOT}    ${ENGLISH_DAY}

User Fills The Reservation Info For Always Free Unit And Submits
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_reserver_info.Check Application Cannot Be Made Without Info
    reservation_unit_reserver_info.Enter First Name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter Last Name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter Email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter Phone Number    ${CURRENT_USER_PHONE}
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click Submit Button Continue

User Fills The Reservation Info For Unit With Payment And Submits
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Type The Name Of The Booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select The Purpose Of The Booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select The Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Type The Description Of The Booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_reserver_types.Select Reserver Type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter First Name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter Last Name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter Email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter Phone Number    ${CURRENT_USER_PHONE}
    reservation_unit_reserver_info.Select Home City    ${HOME_CITY}
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click Submit Button Continue

User Fills Subvented Booking Details As Individual And Submits
    [Arguments]    ${justification_for_not_paying}

    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Type The Name Of The Booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select The Purpose Of The Booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select The Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Click And Select AgeGroup Button    ${AGEGROUP_OF_PERSONS}
    reservation_unit_booking_details.Type The Description Of The Booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_booking_details.Click To Apply For A Free Booking
    reservation_unit_booking_details.Type Justification For Free Of Charge    ${justification_for_not_paying}
    reservation_unit_reserver_types.Select Reserver Type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter First Name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter Last Name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter Email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter Phone Number    ${CURRENT_USER_PHONE}
    reservation_unit_reserver_info.Select Home City    ${HOME_CITY}
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click Submit Button Continue

User Fills Noncancelable Booking Details As Individual And Submits
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Select The Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Type The Description Of The Booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_reserver_types.Select Reserver Type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter First Name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter Last Name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter Email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter Phone Number    ${CURRENT_USER_PHONE}
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click Submit Button Continue

User Fills Info For Unit That Is Always Handled As Individual And Submits
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Type The Name Of The Booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select The Purpose Of The Booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select The Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Type The Description Of The Booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_reserver_types.Select Reserver Type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter First Name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter Last Name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter Email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter Phone Number    ${CURRENT_USER_PHONE}
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click Submit Button Continue

User Fills Booking Details As Individual For Reservation With Access Code And Submits
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Type The Name Of The Booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select The Purpose Of The Booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select The Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Click And Select AgeGroup Button    ${AGEGROUP_OF_PERSONS}
    reservation_unit_booking_details.Type The Description Of The Booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_reserver_types.Select Reserver Type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter First Name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter Last Name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter Email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter Phone Number    ${CURRENT_USER_PHONE}
    reservation_unit_reserver_info.Select Home City    ${HOME_CITY}
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click Submit Button Continue

User Checks Unit That Is Always Handled Details Are Right Before Submit
    reservation_unit_reservation_receipt.Check Single Booking Info
    reservation_unit_reservation_receipt.Check Reservation User Info
    quick_reservation.Check The Price Of Quick Reservation    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms

User Checks Unit That Is Always Handled Details Are Right After Submit
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check The Price Of Quick Reservation    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    quick_reservation.Get Booking Number
    reservation_unit_reservation_receipt.Check The Reservation Status Message
    ...    ${RESERVATION_STATUS_REQUIRESHANDLING_MSG_FI}

User Checks The Free Single Booking Details Are Right
    reservation_unit_reservation_receipt.Check Free Single Booking Info
    reservation_unit_reservation_receipt.Check Reservation User Info
    quick_reservation.Check The Price Of Quick Reservation    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms
    reservation_lownav.Click Submit Button Continue
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check The Price Of Quick Reservation    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    quick_reservation.Get Booking Number
    reservation_unit_reservation_receipt.Check The Reservation Status Message
    ...    ${RESERVATION_STATUS_REQUIRESHANDLING_MSG_FI}

User Checks The Paid Reservation Info Is Right And Submits
    reservation_unit_reservation_receipt.Check Reservation User Info
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click Submit Button Continue

User Checks The Subvented Reservation Info Is Right And Submits
    reservation_unit_reservation_receipt.Check Reservation User Info
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check The Price Of Quick Reservation
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    #
    reservation_lownav.Click Submit Button Continue

User Checks The Subvented Reservation Info Is Right After Submitting
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check The Price Of Quick Reservation
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    quick_reservation.Get Booking Number

User Checks The Paid Reservation That Requires Handling Info Is Right And Submits
    reservation_unit_reservation_receipt.Check Reservation User Info
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click Submit Button Continue
    reservation_unit_reservation_receipt.Check The Reservation Status Message
    ...    ${RESERVATION_STATUS_REQUIRESHANDLING_MSG_FI}
    quick_reservation.Get Booking Number

User Checks The Paid Reservation Info Is Right After Checkout
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    reservation_unit_reservation_receipt.Check The Reservation Status Message    ${RESERVATION_STATUS_MSG_FI}
    quick_reservation.Check The Price Of Quick Reservation    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    quick_reservation.Check Booking Number    ${BOOKING_NUM_ONLY}

User Checks The Reservation Info Is Right Before Submit
    reservation_unit_reservation_receipt.Check Reservation User Info
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms
    #

User Checks The Reservation Info Is Right After Submit
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    reservation_unit_reservation_receipt.Check The Reservation Status Message    ${RESERVATION_STATUS_MSG_FI}
    quick_reservation.Get Booking Number

User Checks The Reservation Info Is Right Before Submit With Access Code
    reservation_unit_reservation_receipt.Check Reservation User Info
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms

User Checks The Reservation Info Is Right After Submit With Access Code
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    reservation_unit_reservation_receipt.Check The Reservation Status Message    ${RESERVATION_STATUS_MSG_FI}
    quick_reservation.Get Booking Number
    quick_reservation.Get Access Code

User Checks The Noncancelable Reservation Info Is Right Before Submit
    reservation_unit_reservation_receipt.Check Reservation User Info
    reservation_unit_reservation_receipt.Check Noncancelable Booking Info
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms

User Checks The Noncancelable Reservation Info Is Right After Submit
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    reservation_unit_reservation_receipt.Check The Reservation Status Message    ${RESERVATION_STATUS_MSG_FI}
    quick_reservation.Get Booking Number

User Checks The Modified Reservation Info Is Right And Clicks Continue
    reservation_unit_reservation_receipt.Click The Checkbox Accepted Terms
    reservation_unit_reservation_receipt.Click The Checkbox Generic Terms
    #
    Log    ${TIME_OF_QUICK_RESERVATION_MODIFIED}
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION_MODIFIED}
    # TODO: Separate the submit and the next page check into their own keywords
    reservation_lownav.Click Submit Button Continue
    # Wait for page to load
    Sleep    2s

    Log    This check is done in reservations page
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION_MODIFIED}

User Cancel Booking In Reservations And Checks It Got Cancelled
    mybookings.User Cancel Booking
    mybookings.Click Reason For Cancellation
    mybookings.Select Reason For Cancellation    ${REASON_FOR_CANCELLATION}
    mybookings.Click Cancel Button
    #
    mybookings.Check Reservation Status    ${IN_RESERVATIONS_STATUS_CANCELED}
    quick_reservation.Check Booking Number    ${BOOKING_NUM_ONLY}

User Modifies Booking And Verifies The Changes
    mybookings.User Click Change Time
    # This opens calendar controls
    # TODO change this to reservation_calendar
    mybookings.User Click Reservation Calendar Toggle Button

    reservation_calendar.Select Duration Calendar    ${QUICK_RESERVATION_DURATION}

    # This sets ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}
    reservation_calendar.Click And Store Free Reservation Time

    ${date_value_from_calendar}=    reservation_calendar.Get Current Date From Datepicker

    # Formats modified date from variables like 15.30 and 15.6.2024. formatting uses 1h duration
    ${formatted_date}    ${formatted_date_minus_t}=    data_modification.Set Info Card Duration Time Info
    ...    ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}
    ...    ${date_value_from_calendar}

    Store Test Data Variable    TIME_OF_QUICK_RESERVATION_MODIFIED    ${formatted_date}
    Store Test Data Variable    TIME_OF_QUICK_RESERVATION_MINUS_T_MODIFIED    ${formatted_date_minus_t}
    Set Test Variable    ${TIME_OF_QUICK_RESERVATION_MODIFIED}    ${formatted_date}
    Set Test Variable    ${TIME_OF_QUICK_RESERVATION_MINUS_T_MODIFIED}    ${formatted_date_minus_t}

    # Log    ${returned_formatted_values}
    Log    ${TIME_OF_QUICK_RESERVATION_MODIFIED}
    Log    ${TIME_OF_QUICK_RESERVATION_MINUS_T_MODIFIED}

    Log    If the continue button is not enabled, verify that the reservation time was actually modified
    Wait For Elements State    [data-testid="reservation__button--continue"]    enabled    timeout=3s
    reservation_calendar.Click Continue Button

User Checks Cancelled Booking Is Found
    [Arguments]    ${unitname_mybookings}    ${time_of_quick_reservation_minusT}

    Log    This checks the canceled booking is not found in upcoming reservations

    mybookings.Check Unitname And Reservation Are Not Found
    ...    ${unitname_mybookings}
    ...    ${time_of_quick_reservation_minusT}

    # Wait for load
    Sleep    3s
    mybookings.Navigate To Cancelled Bookings

    # Wait for load
    Sleep    2s
    mybookings.Check Unitname And Reservation Time And Click Show
    ...    ${unitname_mybookings}
    ...    ${time_of_quick_reservation_minusT}

User Can See Upcoming Booking In List And Clicks It
    [Arguments]    ${unitname}    ${reservationtime}
    Sleep    1s
    Log    ${unitname}
    Log    ${reservationtime}
    mybookings.Check Unitname And Reservation Time And Click Show
    ...    ${unitname}
    ...    ${reservationtime}
    Sleep    1s
    Wait For Load State    load    timeout=15s

User Can See Upcoming Noncancelable Booking In List And Clicks It
    [Arguments]    ${unitname}    ${reservationtime}
    Sleep    2s
    Log    ${unitname}
    Log    ${reservationtime}
    mybookings.Check My Bookings H1    ${MYBOOKINGS_FI}
    mybookings.Check Unitname And Reservation Time And Verify No Cancel Button    ${unitname}    ${reservationtime}
    mybookings.Check Unitname And Reservation Time And Click Show
    ...    ${unitname}
    ...    ${reservationtime}

User Navigates To Unit From Bookings List
    topnav.Navigate To My Bookings

###
# Reservations
###

User Checks The Paid Reservation Info Is Right In Reservations
    [Arguments]
    ...    ${booking_status}
    ...    ${payment_status}
    ...    ${booking_price}
    ...    ${time_in_quickreservations}
    ...    ${reservation_number}

    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    #
    quick_reservation.Check The Quick Reservation Time    ${time_in_quickreservations}
    quick_reservation.Check The Price Of Quick Reservation    ${booking_price}
    mybookings.Check Reservation Status    ${booking_status}
    mybookings.Check Reservations Payment Status    ${payment_status}
    mybookings.Check Reservation Booker Email    ${CURRENT_USER_EMAIL}
    mybookings.Check Reservation Booker First Name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check Reservation Booker Last Name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check Reservation Booker Phone    ${CURRENT_USER_PHONE}
    mybookings.Check Reservation Description    ${SINGLEBOOKING_DESCRIPTION}
    mybookings.Check Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check Reservation Purpose    ${PURPOSE_OF_THE_BOOKING}
    mybookings.Check Reservation Number From H1 Text    ${reservation_number}

User Checks Booking Info In Reservations With Number Of Participants And Description And Purpose
    [Arguments]    ${booking_status}    ${booking_price}    ${time_in_quickreservations}

    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    #
    quick_reservation.Check The Quick Reservation Time    ${time_in_quickreservations}
    quick_reservation.Check Booking Number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check The Price Of Quick Reservation    ${booking_price}

    mybookings.Check Reservation Number From H1 Text    ${BOOKING_NUM_ONLY}
    mybookings.Check Reservation Status    ${booking_status}
    mybookings.Check Reservation Booker Email    ${CURRENT_USER_EMAIL}
    mybookings.Check Reservation Booker First Name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check Reservation Booker Last Name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check Reservation Booker Phone    ${CURRENT_USER_PHONE}
    mybookings.Check Reservation Description    ${SINGLEBOOKING_DESCRIPTION}
    mybookings.Check Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check Reservation Purpose    ${PURPOSE_OF_THE_BOOKING}

User Checks Booking Info In Reservations
    [Arguments]    ${booking_status}    ${booking_price}    ${time_in_quickreservations}

    Wait For Elements State    [data-testid="reservation__reservation-info-card__content"]    visible
    #
    quick_reservation.Check The Quick Reservation Time    ${time_in_quickreservations}
    quick_reservation.Check Booking Number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check The Price Of Quick Reservation    ${booking_price}

    mybookings.Check Reservation Number From H1 Text    ${BOOKING_NUM_ONLY}
    mybookings.Check Reservation Status    ${booking_status}
    mybookings.Check Reservation Booker Email    ${CURRENT_USER_EMAIL}
    mybookings.Check Reservation Booker First Name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check Reservation Booker Last Name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check Reservation Booker Phone    ${CURRENT_USER_PHONE}

User Checks Booking Info In Reservations With Access Code
    [Arguments]    ${booking_status}    ${booking_price}    ${time_in_quickreservations}    ${access_code}

    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    #
    quick_reservation.Check The Quick Reservation Time    ${time_in_quickreservations}
    quick_reservation.Check Booking Number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check The Price Of Quick Reservation    ${booking_price}

    mybookings.Check Reservation Number From H1 Text    ${BOOKING_NUM_ONLY}
    mybookings.Check Reservation Status    ${booking_status}
    mybookings.Check Reservation Booker Email    ${CURRENT_USER_EMAIL}
    mybookings.Check Reservation Booker First Name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check Reservation Booker Last Name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check Reservation Booker Phone    ${CURRENT_USER_PHONE}
    mybookings.Check Reservation Access Code    ${access_code}

User Checks Booking Info In Reservations With All Reservation Info
    [Arguments]    ${booking_status}    ${booking_price}    ${time_in_quickreservations}

    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    #
    quick_reservation.Check The Quick Reservation Time    ${time_in_quickreservations}
    quick_reservation.Check Booking Number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check The Price Of Quick Reservation    ${booking_price}

    mybookings.Check Reservation Number From H1 Text    ${BOOKING_NUM_ONLY}
    mybookings.Check Reservation Status    ${booking_status}
    mybookings.Check Reservation Number From H1 Text    ${BOOKING_NUM_ONLY}
    mybookings.Check Reservation Booker Email    ${CURRENT_USER_EMAIL}
    mybookings.Check Reservation Booker First Name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check Reservation Booker Last Name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check Reservation Booker Phone    ${CURRENT_USER_PHONE}
    mybookings.Check Reservation Description    ${SINGLEBOOKING_DESCRIPTION}
    mybookings.Check Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check Reservation Purpose    ${PURPOSE_OF_THE_BOOKING}
    mybookings.Check Reservation Age Group    ${AGEGROUP_OF_PERSONS}

User Checks Booking Info In Reservations For Noncancelable Booking
    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible

    mybookings.Check Reservation Number From H1 Text    ${BOOKING_NUM_ONLY}
    mybookings.Check Reservation Status    ${MYBOOKINGS_STATUS_CONFIRMED}
    mybookings.Check Reservation Booker Email    ${CURRENT_USER_EMAIL}
    mybookings.Check Reservation Booker First Name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check Reservation Booker Last Name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check Reservation Booker Phone    ${CURRENT_USER_PHONE}
    mybookings.Check Reservation Description    ${SINGLEBOOKING_DESCRIPTION}
    mybookings.Check Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check Cancel Button Is Not Found In Reservations
    quick_reservation.Check The Price Of Quick Reservation    ${SINGLEBOOKING_NO_PAYMENT}

User Verifies Details Of Subvented Reservation After Admin Approval Without Payment
    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    Log
    ...    If the booking number comparison fails, verify that there are no duplicate times in the upcoming bookings list.

    quick_reservation.Check Booking Number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check The Quick Reservation Time    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD}
    quick_reservation.Check The Price Of Quick Reservation    ${SINGLEBOOKING_NO_PAYMENT}
    mybookings.Check Reservation Status    ${MYBOOKINGS_STATUS_CONFIRMED}
    #
    mybookings.Check Reservation Number From H1 Text    ${BOOKING_NUM_ONLY}
    mybookings.Check Reservation Purpose    ${PURPOSE_OF_THE_BOOKING}
    mybookings.Check Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check Reservation Age Group    ${AGEGROUP_OF_PERSONS}
    mybookings.Check Reservation Description    ${SINGLEBOOKING_DESCRIPTION}
    #
    mybookings.Check Reservation Booker First Name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check Reservation Booker Last Name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check Reservation Booker Phone    ${CURRENT_USER_PHONE}
    mybookings.Check Reservation Booker Email    ${CURRENT_USER_EMAIL}

User Checks The Rejected Reservation Info Is Right After Admin Handling
    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    Log
    ...    If the booking number comparison fails, verify that there are no duplicate times in the upcoming bookings list.

    quick_reservation.Check Booking Number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check The Quick Reservation Time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check The Price Of Quick Reservation    ${ALWAYS_REQUESTED_UNIT_PAID_PRICE_VAT_INCL}
    mybookings.Check Reservation Status    ${MYBOOKINGS_STATUS_REJECTED}
    #
    mybookings.Check Reservation Number From H1 Text    ${BOOKING_NUM_ONLY}
    mybookings.Check Reservation Purpose    ${PURPOSE_OF_THE_BOOKING}
    mybookings.Check Number Of Participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check Reservation Description    ${SINGLEBOOKING_DESCRIPTION}
    #
    mybookings.Check Reservation Booker First Name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check Reservation Booker Last Name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check Reservation Booker Phone    ${CURRENT_USER_PHONE}
    mybookings.Check Reservation Booker Email    ${CURRENT_USER_EMAIL}

###
# Calendar usage
###

User Saves File And Formats Booking Time To ICS
    [Documentation]    This formats example like Ti 1.10.2024 klo 10:30–11:30
    ...    to DTSTART;TZID=Europe/Helsinki:20241001T103000, DTEND;TZID=Europe/Helsinki:20241001T113000
    [Arguments]    ${file_path}
    Sleep    1s

    # Ensure the directory exists
    Create Directory    ${file_path}
    Sleep    1s
    Directory Should Exist    ${file_path}

    custom_keywords.Convert Booking Time To ICS Format    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

    # Create a promise that waits for the download to complete, using the specified file path
    ${download_promise}=    Promise To Wait For Download    wait_for_finished=True

    # Saves the calendar file
    Click    [data-testid="reservation__button--calendar-link"]

    # Wait for the file to be fully downloaded and retrieve file information
    ${file_obj}=    Wait For    ${download_promise}

    # Confirm that the file exists and is not empty
    File Should Exist    ${file_obj}[saveAs]

    # Retrieves text content from the downloaded file and sets it as a suite variable
    ${content}=    Get File    ${file_obj}[saveAs]
    ${ICS_TEXT}=    Set Variable    ${content}
    Set Suite Variable    ${ICS_TEXT_FROM_FILE}    ${ICS_TEXT}

    # Extracts the DTSTART and DTEND timestamps from an ICS file's text
    # example --> DTSTART;TZID=Europe/Helsinki:20241003T083000 and DTEND;TZID=Europe/Helsinki:20241003T093000
    custom_keywords.Extract Start And End Time From ICS File    ${ICS_TEXT_FROM_FILE}
    Log    ${ICS_TEXT}

User Checks That Calendar File Matches Booking Time
    # Log for verification
    Log    Checking if ICS times match with booking times...
    Log    ICS Start Time: ${FORMATTED_START_TO_ICS}
    Log    ICS End Time: ${FORMATTED_END_TO_ICS}
    Log    Extracted Start Time: ${START_TIME_FROM_ICS}
    Log    Extracted End Time: ${END_TIME_FROM_ICS}

    # Comparisons
    # Assert Start Times
    ${start_times_equal}=    Run Keyword And Return Status
    ...    Should Be Equal
    ...    ${START_TIME_FROM_ICS}
    ...    ${FORMATTED_START_TO_ICS}
    IF    not ${start_times_equal}
        Fail
        ...    The start times do not match: Expected ${START_TIME_FROM_ICS}, but got ${FORMATTED_START_TO_ICS}.
        ...    Additional info: Check custom_keywords.Convert booking time to ICS format if variables don't match
    END

    # Assert End Times
    ${end_times_equal}=    Run Keyword And Return Status
    ...    Should Be Equal
    ...    ${END_TIME_FROM_ICS}
    ...    ${FORMATTED_END_TO_ICS}
    IF    not ${end_times_equal}
        Fail
        ...    The end times do not match: Expected ${END_TIME_FROM_ICS}, but got ${FORMATTED_END_TO_ICS}.
        ...    Additional info: Check custom_keywords.Convert booking time to ICS format if variables don't match
    END

#

###
# Recurring
###

User Fills In The Application Details For Recurring Application
    recurring_applications.User Selects The Default Time Period For The Recurring Reservation
    #
    recurring_applications.User Fills The Recurring Reservation Name
    ...    ${RECURRING_BOOKING_NAME}
    recurring_applications.User Fills The Number Of People In The Recurring Reservation
    ...    ${RECURRING_BOOKING_SIZE_OF_GROUP}
    recurring_applications.User Fills The Age Group In The Recurring Reservation
    ...    ${RECURRING_BOOKING_AGE_GROUP_TEXT}
    recurring_applications.User Chooses The Purpose Of The Recurring Reservation
    ...    ${RECURRING_BOOKING_PURPOSE_TEXT}
    #
    recurring_applications.User Selects The Minimum Length For The Recurring Reservation
    ...    ${RECURRING_BOOKING_MIN_LENGTH_TEXT}
    recurring_applications.User Selects The Maximum Length For The Recurring Reservation
    ...    ${RECURRING_BOOKING_MAX_LENGTH_TEXT}
    recurring_applications.User Selects The Amount Of Reservations Per Week
    ...    ${RECURRING_BOOKING_RESERVATION_PER_WEEK}
    #
    recurring_applications.User Clicks Continue Button

User Selects Times For Recurring Application
    recurring_applications_page2.User Selects Type Of The Booking Request
    ...    ${RECURRING_BOOKING_TYPE_OF_BOOKING_REQUEST_PRIMARY}
    #
    recurring_applications_page2.User Clicks Available Seasonal Booking Times For
    ...    ${RECURRING_BOOKING_UNIT_NAME_KESKUSTA}
    #
    recurring_applications_page2.User Selects The Times For Recurring Application
    ...    ${RECURRING_THU_22_23_OTHER}
    recurring_applications_page2.User Selects The Times For Recurring Application
    ...    ${RECURRING_THU_23_24_OTHER}
    #
    recurring_applications_page2.User Clicks Available Seasonal Booking Times For
    ...    ${RECURRING_BOOKING_UNIT_NAME_MALMI}
    #
    recurring_applications_page2.User Selects Type Of The Booking Request
    ...    ${RECURRING_BOOKING_TYPE_OF_BOOKING_REQUEST_SECONDARY}
    #
    recurring_applications_page2.User Selects The Times For Recurring Application
    ...    ${RECURRING_THU_09_10_PREFERRED}
    recurring_applications_page2.User Selects The Times For Recurring Application
    ...    ${RECURRING_THU_10_11_PREFERRED}
    #
    recurring_applications_page2.User Clicks Continue Button

User Fills In The Application User Info Details
    recurring_applications_page3.User Selects Who Is The Application Created For    INDIVIDUAL
    #
    recurring_applications_page3.User Types First Name    ${RECURRING_BOOKING_FIRST_NAME}
    recurring_applications_page3.User Types Last Name    ${RECURRING_BOOKING_LAST_NAME}
    recurring_applications_page3.User Types Street Address    ${RECURRING_BOOKING_STREET_ADDRESS}
    recurring_applications_page3.User Types Post Code    ${RECURRING_BOOKING_POST_CODE}
    recurring_applications_page3.User Types City    ${RECURRING_BOOKING_CITY}
    recurring_applications_page3.User Types Phone Number    ${RECURRING_BOOKING_PHONE_NUMBER}
    recurring_applications_page3.User Types Email    ${RECURRING_BOOKING_EMAIL}
    recurring_applications_page3.User Types Additional Information    ${RECURRING_BOOKING_ADDITIONAL_INFO}
    recurring_applications_page2.User Clicks Continue Button

User Accepts Terms Of Use And Clicks Submit
    recurring_applications_page_preview.User Clicks The Accept Terms Of Use Checkbox
    recurring_applications_page_preview.User Clicks The Specific Terms Of Use Checkbox
    recurring_applications_page_preview.User Clicks The Submit Button

User Checks The Sent Page
    recurring_applications_page_sent.User Checks H1 Of The Sent Page

User Checks The Recurring Reservation Is Sent State And Cancels It
    [Documentation]    This is a workaround to cancel the recurring reservation with given name in
    ...    [data-testid="card__heading"]
    ...    it cancels the last reservation in the list so they won't pile up
    custom_keywords.Find And Click Button In Group With Matching Conditions
    ...    [data-testid="applications__group--wrapper"]
    ...    Vastaanotettu
    ...    [class*="Card__CardContent"]
    ...    [data-testid="card__heading"]
    ...    Kausivaraus (AUTOMAATIO TESTI ÄLÄ POISTA)
    ...    [data-testid="card__tags"]
    ...    Lähetetty
    ...    Peru

    # Wait for animation
    Sleep    1s
    custom_keywords.Find And Click Element With Text    id=application-card-modal >> span    Kyllä

User Verifies The Recurring Reservation Is Cancelled
    [Documentation]    Verifies that the recurring reservation with the given name is no longer found
    ...    in the applications list. Fails if the reservation is still present.
    custom_keywords.Verify Card Not Found In Group With Matching Conditions
    ...    ${EMPTY_STATE_MESSAGE_RECURRING_APPLICATIONS}

###
### MOBILE
###

User Navigates To Single Booking Page Mobile
    topnav.Navigate To Single Booking Page Mobile

User Checks Cancelled Booking Is Found Mobile
    [Arguments]    ${unitname_mybookings}    ${time_of_quick_reservation_minusT}
    topnav.Click Tablist Scroll Button To Right Mobile
    mybookings.Check Unitname And Reservation Are Not Found
    ...    ${unitname_mybookings}
    ...    ${time_of_quick_reservation_minusT}
    mybookings.Navigate To Cancelled Bookings
    mybookings.Check Unitname And Reservation Time And Click Show
    ...    ${unitname_mybookings}
    ...    ${time_of_quick_reservation_minusT}

###
# Misc
###

User Checks That Reservation Unit Picture Is Loaded
    [Arguments]    ${unit_name}
    # Target the image by its alt text - this is the most reliable selector
    ${img_selector}=    Set Variable    img[alt*="${unit_name}"]
    
    # Wait for the image element to be attached
    Wait For Elements State    ${img_selector} >> nth=0    attached    timeout=5s
    ...    message=Reservation unit picture for ${unit_name} is not present
    
    # Verify the src attribute is present
    ${src}=    Get Attribute    ${img_selector} >> nth=0    src
    Should Not Be Empty    ${src}    msg=Image src attribute is empty
    
    # Verify the image has actually loaded (not broken)
    # Check that image.complete is true, naturalWidth > 0, and naturalHeight > 0
    ${complete}=    Get Property    ${img_selector} >> nth=0    complete
    Should Be True    ${complete}    msg=Image is not fully loaded (complete property is false)
    
    ${natural_width}=    Get Property    ${img_selector} >> nth=0    naturalWidth
    Should Be True    ${natural_width} > 0    msg=Image naturalWidth is 0 - image failed to load
    
    ${natural_height}=    Get Property    ${img_selector} >> nth=0    naturalHeight
    Should Be True    ${natural_height} > 0    msg=Image naturalHeight is 0 - image failed to load
    
    # Get and log the image dimensions for debugging
    ${width}=    Get Property    ${img_selector} >> nth=0    naturalWidth
    ${height}=    Get Property    ${img_selector} >> nth=0    naturalHeight
    Log    Image loaded successfully with dimensions: ${width}x${height}
