*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_common.robot
Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/Resources/variables.robot
Resource            ${CURDIR}/Resources/texts_FI.robot
Resource            ${CURDIR}/PO/App/mail.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/topNav.robot
Resource            ${CURDIR}/PO/Common/login.robot
Resource            ${CURDIR}/PO/User/user_landingpage.robot
Resource            ${CURDIR}/PO/Common/popups.robot

Test Setup          User opens desktop browser to landing page
Test Teardown       Complete Test Teardown


*** Test Cases ***
User logs in and out with suomi_fi
    [Tags]    smoke
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    app_common.User logs out
    app_common.User confirms log out

User can make free single booking and modifies it
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    Log    User creates reservation
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_FREE_UNIT}
    app_user.User selects the time with quick reservation
    app_user.User fills the reservation info for always free unit
    app_user.User checks the reservation info is right    # TODO add submit here in the middle
    #
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

    Log    User modifies reservation
    app_user.User modifies booking and verifies the changes
    app_user.User checks the modified reservation info is right

    Log    User cancels reservation
    app_user.User cancel booking in reservations and checks it got cancelled
    topNav.Navigate to my bookings
    app_user.User checks cancelled booking is found
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T_MODIFIED}
    app_user.User checks booking info in reservations
    ...    ${IN_RESERVATIONS_STATUS_CANCELED}
    ...    ${SINGLEBOOKING_NO_PAYMENT}
    ...    ${TIME_OF_QUICK_RESERVATION_MODIFIED}

User can create non-cancelable booking
    common_setups_teardowns.Complete Desktop User Test Setup
    topNav.Click login
    login.Login Suomi_fi    ${CURRENT_USER_HETU}
    user_landingpage.Check the user landing page h1    ${USER_LANDING_PAGE_H1_TEXT}
    popups.User accepts cookies if dialog is visible    ${COOKIETEXT}

    Log    User creates reservation
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_FREE_UNIT_NO_CANCEL}
    app_user.User selects the time with quick reservation
    app_user.User fills noncancelable booking details as individual
    app_user.User checks the noncancelable reservation info is right    # TODO add submit here in the middle

    Log    User checks reservation cannot be canceled
    topNav.Navigate to my bookings
    app_user.User can see upcoming noncancelable booking in list and clicks it
    ...    ${CURRENT_FREE_UNIT_NO_CANCEL_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations for noncancelable booking

User can make paid single booking with interrupted checkout
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    Log    User creates reservation
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_PAID_UNIT}
    app_user.User selects the time with quick reservation
    app_user.User fills the reservation info for unit with payment
    app_user.User checks the paid reservation info is right and submits

    Log    User pays the reservation
    app_user.User interrupts paid checkout    ${URL_TEST}
    app_user.User accepts payment to checkout
    app_user.User checks info in paid checkout and confirms booking
    app_user.User checks the paid reservation info is right after checkout

    Log    User checks that paid reservation is found
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks the paid reservation info is right in reservations
    ...    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${MYBOOKINGS_STATUS_PAID_CONFIRMED}
    ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${BOOKING_NUM_ONLY}

    Log    User cancel booking
    app_user.User cancel booking in reservations and checks it got cancelled

    Log    waiting for the status payment to change
    Sleep    10s

    topNav.Navigate to my bookings
    app_user.User checks cancelled booking is found
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

User can make paid single booking
    # Acquire lock to ensure email test waits for this test to complete
    Acquire Lock    PAID_BOOKING_EMAIL_SEQUENCE

    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_PAID_UNIT}
    app_user.User selects the time with quick reservation
    app_user.User fills the reservation info for unit with payment
    app_user.User checks the paid reservation info is right and submits
    app_user.User checks info in paid checkout and confirms booking
    app_user.User checks the paid reservation info is right after checkout
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks the paid reservation info is right in reservations
    ...    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${MYBOOKINGS_STATUS_PAID_CONFIRMED}
    ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${BOOKING_NUM_ONLY}
    app_user.User cancel booking in reservations and checks it got cancelled
    Sleep    10s    # Waiting for the status payment to change
    topNav.Navigate to my bookings
    app_user.User checks cancelled booking is found
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks the paid reservation info is right in reservations
    ...    ${IN_RESERVATIONS_STATUS_CANCELED}
    ...    ${MYBOOKINGS_STATUS_REFUNDED}
    ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${BOOKING_NUM_ONLY}
#
    # If this is set to true mail test will be skipped. By default it is set to true
    Store Test Data Variable    MAIL_TEST_TRIGGER    False

    # Store all mail-related data in one consolidated call
    parallel_test_data.Store Mail Test Data
    ...    ${BOOKING_NUM_ONLY}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    ...    ${CURRENT_ALWAYS_PAID_UNIT}
    ...    ${EMPTY}
    ...    ${EMPTY}

    # Release lock to allow email test to proceed
    Release Lock    PAID_BOOKING_EMAIL_SEQUENCE

User can make subvented single booking that requires handling
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}
    app_user.User selects the time with quick reservation
    app_user.User fills subvented booking details as individual    ${JUSTIFICATION_FOR_SUBVENTION}
    app_user.User checks the paid reservation that requires handling info is right and submits
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations with all reservation info
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}

User can make reservation with access code
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    Log    User creates reservation
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_UNIT_WITH_ACCESS_CODE}
    app_user.User selects the time with quick reservation
    app_user.User fills booking details as individual for reservation with access code
    app_user.User checks the reservation info is right with access code    # TODO add submit here in the middle
    #
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User cancel booking in reservations and checks it got cancelled
    topNav.Navigate to my bookings
    app_user.User checks cancelled booking is found
    ...    ${CURRENT_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations with access code
    ...    ${IN_RESERVATIONS_STATUS_CANCELED}
    ...    ${SINGLEBOOKING_NO_PAYMENT}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${ACCESS_CODE_TXT_BY_CODE}

User checks that reserved time is not available anymore
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_user.User selects the time with quick reservation
    app_user.User fills the reservation info for always free unit
    app_user.User checks the reservation info is right
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_user.User checks that quick reservation does not have reserved time    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    app_user.User checks that reservation calendar does not have reserved time slot available
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_UNAVAILABLE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    Log    User cancels reservation
    app_user.User cancel booking in reservations and checks it got cancelled
    Log    No further checks are needed here

User checks that there are not current dates in the past bookings
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    topNav.Navigate to my bookings
    mybookings.Navigate to past bookings
    mybookings.Validate reservations are not for today or later

User can make free single booking and check info from downloaded calendar file
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_FREE_UNIT}
    app_user.User selects the time with quick reservation
    app_user.User fills the reservation info for always free unit
    app_user.User checks the reservation info is right
    app_user.User saves file and formats booking time to ICS    ${DOWNLOAD_ICS_FILE}
    app_user.User checks that calendar file matches booking time
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User cancel booking in reservations and checks it got cancelled
    topNav.Navigate to my bookings
    app_user.User checks cancelled booking is found
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

Check emails from reservations
    [Documentation]    Waits for paid booking test to complete, then verifies reservation emails.
    ...    This test depends on 'User can make paid single booking' completing successfully first.
    ...    ###
    ...    Without pabot run -->
    ...    ###
    ...    If test - User can make paid single booking didnt set 'MAIL_TEST_TRIGGER' value to False this test is skipped.
    ...    Default value true skips this test
    ...    'NUMBER_OF_RESERVATION_FOR_MAIL_TEST' and 'TIME_OF_RESERVATION_FOR_MAIL_TEST' are set in test --> 'User can make paid single booking'

    ${skip_message}=    Catenate
    ...    Test is being skipped because 'User can make paid single booking' test either failed or did not complete successfully.
    ...    Without a successful test, there may not be valid emails to verify.

    # Wait automatically for paid booking test to complete and release the lock
    Log    Waiting for paid booking test to complete before checking emails...
    Acquire Lock    PAID_BOOKING_EMAIL_SEQUENCE

    ${mail_test_trigger}=    Get Test Data Variable    MAIL_TEST_TRIGGER    True
    IF    "${mail_test_trigger}" == "True"    Skip    ${skip_message}

    # Get all mail-related data in one consolidated call
    ${booking_num_for_mail}
    ...    ${time_for_mail}
    ...    ${unit_name_for_mail}
    ...    ${formatted_start_time}
    ...    ${formatted_end_time}=
    ...    parallel_test_data.Get Mail Test Data

    mail.Check emails from reservations    ${booking_num_for_mail}
    mail.Format reservation time for email texts and receipts    ${time_for_mail}
    mail.Verify reservation confirmation email    ${booking_num_for_mail}
    mail.Verify reservation cancellation email    ${booking_num_for_mail}
    mail.Verify refund email for paid reservation    ${booking_num_for_mail}
    mail.Verify payment receipt email    ${booking_num_for_mail}

    # Release lock after email verification is complete
    Release Lock    PAID_BOOKING_EMAIL_SEQUENCE

User makes recurring reservation
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    app_user.User navigates to recurring booking page

    Log    User selects a recurring booking and units
    recurring.User selects a recurring booking round    ${RECURRING_BOOKING_NAME}
    recurring.User selects the units for recurring reservation    ${RECURRING_UNIT_MALMI}
    recurring.User selects the units for recurring reservation    ${RECURRING_UNIT_KESKUSTA}
    recurring.User checks the count of selected units    ${RECURRING_BOOKING_UNIT_COUNT_TEXT}
    recurring.User clicks continue button

    Log    User fills the reservation info for recurring reservation
    app_user.User fills in the application details for recurring application
    app_user.User selects times for recurring application
    app_user.User fills in the application user info details
    app_user.User accepts terms of use and clicks submit
    app_user.User checks the sent page

    Log    User checks the reservation info is right
    app_user.User checks the sent page

    Log    User cancels the recurring reservation
    topNav.Navigate to my applications
    app_user.User checks the recurring reservation is sent state and cancels it
