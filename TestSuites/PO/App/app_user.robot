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
Resource    ../Common/topNav.robot
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

User navigates to single booking page
    topNav.Navigate to single booking page

User navigates to my bookings
    topNav.Navigate to my bookings

User navigates to recurring booking page
    topNav.Navigate to recurring booking page
    Wait For Load State    load    timeout=15s

###

###
# Payment notification banner
###

User accepts payment to checkout
    Log    This clicks approve button from notification banner
    Sleep    1.5s    # Wait for banner to load
    user_landingpage.Approve interrupted payment

###

###
# Checkout
###

User checks info in paid checkout and confirms booking
    Log    This step gets the reservation number
    checkout.Check the info in checkout

User interrupts paid checkout
    [Arguments]    ${input_URL}
    checkout.Interrupted checkout    ${input_URL}
    Sleep    1s
    user_landingpage.Check the user landing page h1    ${USER_LANDING_PAGE_H1_TEXT}
###

###
# Singlebooking
###

User uses search to find right unit
    [Arguments]    ${nameoftheunit}

    # This checks if the search element is visible; if it isn’t, it clicks the "advanced search" toggle button to make it visible.
    singlebooking.Click advanced search if search not visible
    singlebooking.Search units by name    ${nameoftheunit}

    # Waiting results to load
    Sleep    2s
    Wait For Load State    load    timeout=10s

    custom_keywords.Find and click element with text
    ...    [data-testid="list-with-pagination__list--container"] >> [data-testid="card__heading"]
    ...    ${nameoftheunit}

    # Waiting results to load
    Sleep    2s
    Wait For Load State    load    timeout=10s

User selects the time with quick reservation
    [Documentation]    here is keyword --> data_modification.Set info card duration time info
    ...    that sets $TIME_OF_QUICK_RESERVATION and $TIME_OF_QUICK_RESERVATION_MINUS_T

    Sleep    1s
    Wait For Elements State    id=quick-reservation    visible
    quick_reservation.Select duration    ${QUICK_RESERVATION_DURATION}

    # Checks that calendar opens and has all the buttons inside
    quick_reservation.Confirms date picker opens from quick reservation

    ${quick_reservation_current_date_value}=    quick_reservation.Get the value from date input

    # This sets ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    quick_reservation.Select the free slot and submits

    # Wait for load
    Sleep    1.5s
    Wait For Load State    load    timeout=50s
    Log    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}

    ${formatted_date}    ${formatted_date_minus_t}=    data_modification.Set info card duration time info
    ...    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    ...    ${quick_reservation_current_date_value}

    Store Test Data Variable    TIME_OF_QUICK_RESERVATION    ${formatted_date}
    Store Test Data Variable    TIME_OF_QUICK_RESERVATION_MINUS_T    ${formatted_date_minus_t}
    Set Test Variable    ${TIME_OF_QUICK_RESERVATION}    ${formatted_date}
    Set Test Variable    ${TIME_OF_QUICK_RESERVATION_MINUS_T}    ${formatted_date_minus_t}

    Log    ${TIME_OF_QUICK_RESERVATION}
    Log    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

User checks that quick reservation does not have reserved time
    [Arguments]    ${reservationtime}
    Wait For Load State    load    timeout=15s
    Log    ${reservationtime}
    quick_reservation.Verify time slot not available    ${reservationtime}

User checks that reservation calendar does not have reserved time slot available
    [Documentation]    This keyword uses data_modification.Convert finnish short day to english and
    ...    data_modification.Compute reservation timeslot to set variables

    Log    This keyword sets the variable '${ENGLISH_DAY}'
    data_modification.Convert finnish short day to english    ${TIME_OF_QUICK_RESERVATION}

    Log    This keyword sets the variable '${CALENDAR_TIMESLOT}'
    data_modification.Compute reservation time slot
    ...    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    ...    ${QUICK_RESERVATION_DURATION}

    custom_keywords.Verify reservation slot exists    ${CALENDAR_TIMESLOT}    ${ENGLISH_DAY}

User fills the reservation info for always free unit
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_reserver_info.Enter first name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter last name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${CURRENT_USER_PHONE}
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click submit button continue

User fills the reservation info for unit with payment
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Type the name of the booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select the purpose of the booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select the number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Type the description of the booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_reserver_types.Select reserver type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter first name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter last name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${CURRENT_USER_PHONE}
    reservation_unit_reserver_info.Select home city    ${HOME_CITY}
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click submit button continue

User fills subvented booking details as individual
    [Arguments]    ${justification_for_not_paying}

    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Type the name of the booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select the purpose of the booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select the number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Click and select AgeGroup Button    ${AGEGROUP_OF_PERSONS}
    reservation_unit_booking_details.Type the description of the booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_booking_details.Click to apply for a free booking
    reservation_unit_booking_details.Type justification for free of charge    ${justification_for_not_paying}
    reservation_unit_reserver_types.Select reserver type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter first name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter last name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${CURRENT_USER_PHONE}
    reservation_unit_reserver_info.Select home city    ${HOME_CITY}
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click submit button continue

User fills noncancelable booking details as individual
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Select the number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Type the description of the booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_reserver_types.Select reserver type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter first name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter last name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${CURRENT_USER_PHONE}
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click submit button continue

User fills info for unit that is always handled as individual
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Type the name of the booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select the purpose of the booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select the number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Type the description of the booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_reserver_types.Select reserver type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter first name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter last name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${CURRENT_USER_PHONE}
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click submit button continue

User fills booking details as individual for reservation with access code
    # Checks that "jatka" button has been loaded
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    #
    reservation_unit_booking_details.Type the name of the booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select the purpose of the booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select the number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Click and select AgeGroup Button    ${AGEGROUP_OF_PERSONS}
    reservation_unit_booking_details.Type the description of the booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_reserver_types.Select reserver type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter first name    ${CURRENT_USER_FIRST_NAME}
    reservation_unit_reserver_info.Enter last name    ${CURRENT_USER_LAST_NAME}
    reservation_unit_reserver_info.Enter email    ${CURRENT_USER_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${CURRENT_USER_PHONE}
    reservation_unit_reserver_info.Select home city    ${HOME_CITY}
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click submit button continue

User checks unit that is always handled details are right
    reservation_unit_reservation_receipt.Check single booking info
    reservation_unit_reservation_receipt.Check reservation user info
    quick_reservation.Check the price of quick reservation    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    #
    reservation_lownav.Click submit button continue
    #
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check the price of quick reservation    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    quick_reservation.Get booking number
    reservation_unit_reservation_receipt.Check the reservation status message
    ...    ${RESERVATION_STATUS_REQUIRESHANDLING_MSG_FI}

User checks the free single booking details are right
    reservation_unit_reservation_receipt.Check free single booking info
    reservation_unit_reservation_receipt.Check reservation user info
    quick_reservation.Check the price of quick reservation    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    reservation_lownav.Click submit button continue
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check the price of quick reservation    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    quick_reservation.Get booking number
    reservation_unit_reservation_receipt.Check the reservation status message
    ...    ${RESERVATION_STATUS_REQUIRESHANDLING_MSG_FI}

User checks the paid reservation info is right and submits
    reservation_unit_reservation_receipt.Check reservation user info
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click submit button continue

User checks the subvented reservation info is right and submits
    reservation_unit_reservation_receipt.Check reservation user info
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check the price of quick reservation
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    #
    reservation_lownav.Click submit button continue

User checks the subvented reservation info is right after submitting
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check the price of quick reservation
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    quick_reservation.Get booking number

User checks the paid reservation that requires handling info is right and submits
    reservation_unit_reservation_receipt.Check reservation user info
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    #
    reservation_lownav.Click submit button continue
    reservation_unit_reservation_receipt.Check the reservation status message
    ...    ${RESERVATION_STATUS_REQUIRESHANDLING_MSG_FI}
    quick_reservation.Get booking number

User checks the paid reservation info is right after checkout
    # devnote confirmation page is different than review page
    # TODO fix the paging
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    reservation_unit_reservation_receipt.Check the reservation status message    ${RESERVATION_STATUS_MSG_FI}
    quick_reservation.Check the price of quick reservation    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    quick_reservation.Check booking number    ${BOOKING_NUM_ONLY}

User checks the reservation info is right
    reservation_unit_reservation_receipt.Check reservation user info
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    #
    reservation_lownav.Click submit button continue
    # TODO Let's split these checks by different pages and move submit to a higher level
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    reservation_unit_reservation_receipt.Check the reservation status message    ${RESERVATION_STATUS_MSG_FI}
    quick_reservation.Get booking number

User checks the reservation info is right with access code
    reservation_unit_reservation_receipt.Check reservation user info
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    #
    reservation_lownav.Click submit button continue
    # TODO Let's split these checks by different pages and move submit to a higher level
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    reservation_unit_reservation_receipt.Check the reservation status message    ${RESERVATION_STATUS_MSG_FI}
    quick_reservation.Get booking number
    quick_reservation.Get access code

User checks the noncancelable reservation info is right
    reservation_unit_reservation_receipt.Check reservation user info
    reservation_unit_reservation_receipt.Check noncancelable booking info
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    #
    reservation_lownav.Click submit button continue
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    reservation_unit_reservation_receipt.Check the reservation status message    ${RESERVATION_STATUS_MSG_FI}
    quick_reservation.Get booking number

User checks the modified reservation info is right
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    #
    Log    ${TIME_OF_QUICK_RESERVATION_MODIFIED}
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION_MODIFIED}
    # TODO: Separate the submit and the next page check into their own keywords
    reservation_lownav.Click submit button continue
    # Wait for page to load
    Sleep    2s

    Log    This check is done in reservations page
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION_MODIFIED}

User cancel booking in reservations and checks it got cancelled
    mybookings.User cancel booking
    mybookings.Click reason for cancellation
    mybookings.Select reason for cancellation    ${REASON_FOR_CANCELLATION}
    mybookings.Click cancel button
    #
    mybookings.Check reservation status    ${IN_RESERVATIONS_STATUS_CANCELED}
    quick_reservation.Check booking number    ${BOOKING_NUM_ONLY}

User modifies booking and verifies the changes
    mybookings.User click change time
    # This opens calendar controls
    # TODO change this to reservation_calendar
    mybookings.User click reservation calendar toggle button

    reservation_calendar.Select duration calendar    ${QUICK_RESERVATION_DURATION}

    # This sets ${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}
    reservation_calendar.Click and store free reservation time

    ${date_value_from_calendar}=    reservation_calendar.Get current date from datepicker

    # Formats modified date from variables like 15.30 and 15.6.2024. formatting uses 1h duration
    ${formatted_date}    ${formatted_date_minus_t}=    data_modification.Set info card duration time info
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
    reservation_calendar.Click continue button

User checks cancelled booking is found
    [Arguments]    ${unitname_mybookings}    ${time_of_quick_reservation_minusT}

    Log    This checks the canceled booking is not found in upcoming reservations

    mybookings.Check unitname and reservation are not found
    ...    ${unitname_mybookings}
    ...    ${time_of_quick_reservation_minusT}

    # Wait for load
    Sleep    3s
    mybookings.Navigate to cancelled bookings

    # Wait for load
    Sleep    2s
    mybookings.Check unitname and reservation time and click show
    ...    ${unitname_mybookings}
    ...    ${time_of_quick_reservation_minusT}

User can see upcoming booking in list and clicks it
    [Arguments]    ${unitname}    ${reservationtime}
    Sleep    1s
    Log    ${unitname}
    Log    ${reservationtime}
    mybookings.Check unitname and reservation time and click show
    ...    ${unitname}
    ...    ${reservationtime}
    Sleep    1s
    Wait For Load State    load    timeout=15s

User can see upcoming noncancelable booking in list and clicks it
    [Arguments]    ${unitname}    ${reservationtime}
    Sleep    2s
    Log    ${unitname}
    Log    ${reservationtime}
    mybookings.Check my bookings h1    ${MYBOOKINGS_FI}
    # TODO lets split these two checks to their own keywords, matching the keywords better
    mybookings.Check unitname and reservation time and verify no cancel button    ${unitname}    ${reservationtime}
    mybookings.Check unitname and reservation time and click show
    ...    ${unitname}
    ...    ${reservationtime}

User Navigates to unit from bookings list
    topNav.Navigate to my bookings

###
# Reservations
###

User checks the paid reservation info is right in reservations
    [Arguments]
    ...    ${booking_status}
    ...    ${payment_status}
    ...    ${booking_price}
    ...    ${time_in_quickreservations}
    ...    ${reservation_number}

    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    #
    quick_reservation.Check the quick reservation time    ${time_in_quickreservations}
    quick_reservation.Check the price of quick reservation    ${booking_price}
    mybookings.Check reservation status    ${booking_status}
    mybookings.Check reservations payment status    ${payment_status}
    mybookings.Check reservation booker email    ${CURRENT_USER_EMAIL}
    mybookings.Check reservation booker first name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check reservation booker last name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check reservation booker phone    ${CURRENT_USER_PHONE}
    mybookings.Check reservation description    ${SINGLEBOOKING_DESCRIPTION}
    mybookings.Check number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check reservation purpose    ${PURPOSE_OF_THE_BOOKING}
    mybookings.Check reservation number from h1 text    ${reservation_number}

User checks booking info in reservations with number of participants and description and purpose
    [Arguments]    ${booking_status}    ${booking_price}    ${time_in_quickreservations}

    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    #
    quick_reservation.Check the quick reservation time    ${time_in_quickreservations}
    quick_reservation.Check booking number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check the price of quick reservation    ${booking_price}

    mybookings.Check reservation number from h1 text    ${BOOKING_NUM_ONLY}
    mybookings.Check reservation status    ${booking_status}
    mybookings.Check reservation booker email    ${CURRENT_USER_EMAIL}
    mybookings.Check reservation booker first name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check reservation booker last name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check reservation booker phone    ${CURRENT_USER_PHONE}
    mybookings.Check reservation description    ${SINGLEBOOKING_DESCRIPTION}
    mybookings.Check number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check reservation purpose    ${PURPOSE_OF_THE_BOOKING}

User checks booking info in reservations
    [Arguments]    ${booking_status}    ${booking_price}    ${time_in_quickreservations}

    Wait For Elements State    [data-testid="reservation__reservation-info-card__content"]    visible
    #
    quick_reservation.Check the quick reservation time    ${time_in_quickreservations}
    quick_reservation.Check booking number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check the price of quick reservation    ${booking_price}

    mybookings.Check reservation number from h1 text    ${BOOKING_NUM_ONLY}
    mybookings.Check reservation status    ${booking_status}
    mybookings.Check reservation booker email    ${CURRENT_USER_EMAIL}
    mybookings.Check reservation booker first name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check reservation booker last name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check reservation booker phone    ${CURRENT_USER_PHONE}

User checks booking info in reservations with access code
    [Arguments]    ${booking_status}    ${booking_price}    ${time_in_quickreservations}    ${access_code}

    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    #
    quick_reservation.Check the quick reservation time    ${time_in_quickreservations}
    quick_reservation.Check booking number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check the price of quick reservation    ${booking_price}

    mybookings.Check reservation number from h1 text    ${BOOKING_NUM_ONLY}
    mybookings.Check reservation status    ${booking_status}
    mybookings.Check reservation booker email    ${CURRENT_USER_EMAIL}
    mybookings.Check reservation booker first name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check reservation booker last name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check reservation booker phone    ${CURRENT_USER_PHONE}
    mybookings.Check reservation access code    ${access_code}

User checks booking info in reservations with all reservation info
    [Arguments]    ${booking_status}    ${booking_price}    ${time_in_quickreservations}

    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    #
    quick_reservation.Check the quick reservation time    ${time_in_quickreservations}
    quick_reservation.Check booking number    ${BOOKING_NUM_ONLY}

    mybookings.Check reservation number from h1 text    ${BOOKING_NUM_ONLY}
    mybookings.Check reservation status    ${MYBOOKINGS_STATUS_PROCESSED}
    mybookings.Check reservation number from h1 text    ${BOOKING_NUM_ONLY}
    mybookings.Check reservation booker email    ${CURRENT_USER_EMAIL}
    mybookings.Check reservation booker first name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check reservation booker last name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check reservation booker phone    ${CURRENT_USER_PHONE}
    mybookings.Check reservation description    ${SINGLEBOOKING_DESCRIPTION}
    mybookings.Check number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check reservation purpose    ${PURPOSE_OF_THE_BOOKING}
    mybookings.Check reservation age group    ${AGEGROUP_OF_PERSONS}

User checks booking info in reservations for noncancelable booking
    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible

    mybookings.Check reservation number from h1 text    ${BOOKING_NUM_ONLY}
    mybookings.Check reservation status    ${MYBOOKINGS_STATUS_CONFIRMED}
    mybookings.Check reservation booker email    ${CURRENT_USER_EMAIL}
    mybookings.Check reservation booker first name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check reservation booker last name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check reservation booker phone    ${CURRENT_USER_PHONE}
    mybookings.Check reservation description    ${SINGLEBOOKING_DESCRIPTION}
    mybookings.Check number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check cancel button is not found in reservations
    quick_reservation.Check the price of quick reservation    ${SINGLEBOOKING_NO_PAYMENT}

User verifies details of subvented reservation after admin approval without payment
    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    Log
    ...    If the booking number comparison fails, verify that there are no duplicate times in the upcoming bookings list.

    quick_reservation.Check booking number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check the quick reservation time    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD}
    quick_reservation.Check the price of quick reservation    ${SINGLEBOOKING_NO_PAYMENT}
    mybookings.Check reservation status    ${MYBOOKINGS_STATUS_CONFIRMED}
    #
    mybookings.Check reservation number from h1 text    ${BOOKING_NUM_ONLY}
    mybookings.Check reservation purpose    ${PURPOSE_OF_THE_BOOKING}
    mybookings.Check number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check reservation age group    ${AGEGROUP_OF_PERSONS}
    mybookings.Check reservation description    ${SINGLEBOOKING_DESCRIPTION}
    #
    mybookings.Check reservation booker first name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check reservation booker last name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check reservation booker phone    ${CURRENT_USER_PHONE}
    mybookings.Check reservation booker email    ${CURRENT_USER_EMAIL}

User checks the rejected reservation info is right after admin handling
    Wait For Elements State    [data-testid="reservation__terms-of-use"]    visible
    Log
    ...    If the booking number comparison fails, verify that there are no duplicate times in the upcoming bookings list.

    quick_reservation.Check booking number    ${BOOKING_NUM_ONLY}
    quick_reservation.Check the quick reservation time    ${TIME_OF_QUICK_RESERVATION}
    quick_reservation.Check the price of quick reservation    ${ALWAYS_REQUESTED_UNIT_PAID_PRICE_VAT_INCL}
    mybookings.Check reservation status    ${MYBOOKINGS_STATUS_REJECTED}
    #
    mybookings.Check reservation number from h1 text    ${BOOKING_NUM_ONLY}
    mybookings.Check reservation purpose    ${PURPOSE_OF_THE_BOOKING}
    mybookings.Check number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    mybookings.Check reservation description    ${SINGLEBOOKING_DESCRIPTION}
    #
    mybookings.Check reservation booker first name    ${CURRENT_USER_FIRST_NAME}
    mybookings.Check reservation booker last name    ${CURRENT_USER_LAST_NAME}
    mybookings.Check reservation booker phone    ${CURRENT_USER_PHONE}
    mybookings.Check reservation booker email    ${CURRENT_USER_EMAIL}

###
# Calendar usage
###

User saves file and formats booking time to ICS
    [Documentation]    This formats example like Ti 1.10.2024 klo 10:30–11:30
    ...    to DTSTART;TZID=Europe/Helsinki:20241001T103000, DTEND;TZID=Europe/Helsinki:20241001T113000
    [Arguments]    ${file_path}
    Sleep    1s

    # Ensure the directory exists
    Create Directory    ${file_path}
    Sleep    1s
    Directory Should Exist    ${file_path}

    custom_keywords.Convert booking time to ICS format    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

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
    custom_keywords.Extract start and end time from ICS file    ${ICS_TEXT_FROM_FILE}
    Log    ${ICS_TEXT}

User checks that calendar file matches booking time
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

User fills in the application details for recurring application
    recurring_applications.User selects the default time period for the recurring reservation
    #
    recurring_applications.User fills the recurring reservation name
    ...    ${RECURRING_BOOKING_NAME}
    recurring_applications.User fills the number of people in the recurring reservation
    ...    ${RECURRING_BOOKING_SIZE_OF_GROUP}
    recurring_applications.User fills the age group in the recurring reservation
    ...    ${RECURRING_BOOKING_AGE_GROUP_TEXT}
    recurring_applications.User chooses the purpose of the recurring reservation
    ...    ${RECURRING_BOOKING_PURPOSE_TEXT}
    #
    recurring_applications.User selects the minimum length for the recurring reservation
    ...    ${RECURRING_BOOKING_MIN_LENGTH_TEXT}
    recurring_applications.User selects the maximum length for the recurring reservation
    ...    ${RECURRING_BOOKING_MAX_LENGTH_TEXT}
    recurring_applications.User selects the amount of reservations per week
    ...    ${RECURRING_BOOKING_RESERVATION_PER_WEEK}
    #
    recurring_applications.User clicks continue button

User selects times for recurring application
    recurring_applications_page2.User selects type of the booking request
    ...    ${RECURRING_BOOKING_TYPE_OF_BOOKING_REQUEST_PRIMARY}
    #
    recurring_applications_page2.User clicks available seasonal booking times for
    ...    ${RECURRING_BOOKING_UNIT_NAME_KESKUSTA}
    #
    recurring_applications_page2.User selects the times for recurring application
    ...    ${RECURRING_THU_22_23_OTHER}
    recurring_applications_page2.User selects the times for recurring application
    ...    ${RECURRING_THU_23_24_OTHER}
    #
    recurring_applications_page2.User clicks available seasonal booking times for
    ...    ${RECURRING_BOOKING_UNIT_NAME_MALMI}
    #
    recurring_applications_page2.User selects type of the booking request
    ...    ${RECURRING_BOOKING_TYPE_OF_BOOKING_REQUEST_SECONDARY}
    #
    recurring_applications_page2.User selects the times for recurring application
    ...    ${RECURRING_THU_09_10_PREFERRED}
    recurring_applications_page2.User selects the times for recurring application
    ...    ${RECURRING_THU_10_11_PREFERRED}
    #
    recurring_applications_page2.User clicks continue button

User fills in the application user info details
    recurring_applications_page3.User selects who is the application created for    INDIVIDUAL
    #
    recurring_applications_page3.User types first name    ${RECURRING_BOOKING_FIRST_NAME}
    recurring_applications_page3.User types last name    ${RECURRING_BOOKING_LAST_NAME}
    recurring_applications_page3.User types street address    ${RECURRING_BOOKING_STREET_ADDRESS}
    recurring_applications_page3.User types post code    ${RECURRING_BOOKING_POST_CODE}
    recurring_applications_page3.User types city    ${RECURRING_BOOKING_CITY}
    recurring_applications_page3.User types phone number    ${RECURRING_BOOKING_PHONE_NUMBER}
    recurring_applications_page3.User types email    ${RECURRING_BOOKING_EMAIL}
    recurring_applications_page3.User types additional information    ${RECURRING_BOOKING_ADDITIONAL_INFO}
    recurring_applications_page2.User clicks continue button

User accepts terms of use and clicks submit
    recurring_applications_page_preview.User clicks the accept terms of use checkbox
    recurring_applications_page_preview.User clicks the specific terms of use checkbox
    recurring_applications_page_preview.User clicks the submit button

User checks the sent page
    recurring_applications_page_sent.User checks h1 of the sent page

User checks the recurring reservation is sent state and cancels it
    [Documentation]    This is a workaround to cancel the recurring reservation with given name in
    ...    [data-testid="card__heading"]
    ...    it cancels the last reservation in the list so they won't pile up
    custom_keywords.Find and click button in group with matching conditions
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
    custom_keywords.Find and click element with text    id=application-card-modal >> span    Kyllä

User verifies the recurring reservation is cancelled
    [Documentation]    Verifies that the recurring reservation with the given name is no longer found
    ...    in the applications list. Fails if the reservation is still present.
    custom_keywords.Verify card not found in group with matching conditions
    ...    ${EMPTY_STATE_MESSAGE_RECURRING_APPLICATIONS}

###
### MOBILE
###

User navigates to single booking page mobile
    topNav.Navigate to single booking page mobile

User checks cancelled booking is found mobile
    [Arguments]    ${unitname_mybookings}    ${time_of_quick_reservation_minusT}
    topNav.Click tablist scroll button to right mobile
    mybookings.Check unitname and reservation are not found
    ...    ${unitname_mybookings}
    ...    ${time_of_quick_reservation_minusT}
    mybookings.Navigate to cancelled bookings
    mybookings.Check unitname and reservation time and click show
    ...    ${unitname_mybookings}
    ...    ${time_of_quick_reservation_minusT}
