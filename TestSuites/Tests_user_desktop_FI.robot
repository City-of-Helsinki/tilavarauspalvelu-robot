*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_common.robot
Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/Resources/variables.robot
Resource            ${CURDIR}/Resources/texts_FI.robot
Resource            ${CURDIR}/PO/App/mail.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/Resources/parallel_test_data.robot
Resource            ${CURDIR}/PO/Common/topnav.robot
Resource            ${CURDIR}/PO/Common/login.robot
Resource            ${CURDIR}/PO/User/user_landingpage.robot
Resource            ${CURDIR}/PO/Common/popups.robot

Suite Setup         Run Only Once    create_data.Create Robot Test Data
Test Setup          User Opens Desktop Browser To Landing Page
Test Teardown       Complete Test Teardown


*** Test Cases ***
User logs in and out with suomi_fi
    [Tags]    desktop-test-data-set-0    desktop-suite    smoke
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    app_common.User Logs Out
    app_common.User Confirms Log Out

User can make free single booking and modifies it
    [Tags]    desktop-test-data-set-1    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    Log    User creates reservation
    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_FREE_UNIT}
    app_user.User Selects The Time With Quick Reservation
    app_user.User Fills The Reservation Info For Always Free Unit
    app_user.User Checks The Reservation Info Is Right    # TODO add submit here in the middle
    #
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

    Log    User modifies reservation
    app_user.User Modifies Booking And Verifies The Changes
    app_user.User Checks The Modified Reservation Info Is Right

    Log    User cancels reservation
    app_user.User Cancel Booking In Reservations And Checks It Got Cancelled
    topnav.Navigate To My Bookings
    app_user.User Checks Cancelled Booking Is Found
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T_MODIFIED}
    app_user.User Checks Booking Info In Reservations
    ...    ${IN_RESERVATIONS_STATUS_CANCELED}
    ...    ${SINGLEBOOKING_NO_PAYMENT}
    ...    ${TIME_OF_QUICK_RESERVATION_MODIFIED}

User can create non-cancelable booking
    [Tags]    desktop-test-data-set-2    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    topnav.Click Login
    login.Login Suomi Fi    ${CURRENT_USER_HETU}
    user_landingpage.Check The User Landing Page H1    ${USER_LANDING_PAGE_H1_TEXT}
    popups.User Accepts Cookies If Dialog Is Visible    ${COOKIETEXT}

    Log    User creates reservation
    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_FREE_UNIT_NO_CANCEL}
    app_user.User Selects The Time With Quick Reservation
    app_user.User Fills Noncancelable Booking Details As Individual
    app_user.User Checks The Noncancelable Reservation Info Is Right    # TODO add submit here in the middle

    Log    User checks reservation cannot be canceled
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Noncancelable Booking In List And Clicks It
    ...    ${CURRENT_FREE_UNIT_NO_CANCEL_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks Booking Info In Reservations For Noncancelable Booking

User can make paid single booking with interrupted checkout
    [Tags]    desktop-test-data-set-3    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    Log    User creates reservation
    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_PAID_UNIT}
    app_user.User Selects The Time With Quick Reservation
    app_user.User Fills The Reservation Info For Unit With Payment
    app_user.User Checks The Paid Reservation Info Is Right And Submits

    Log    User pays the reservation
    app_user.User Interrupts Paid Checkout    ${URL_TEST}
    app_user.User Accepts Payment To Checkout
    app_user.User Checks Info In Paid Checkout And Confirms Booking
    app_user.User Checks The Paid Reservation Info Is Right After Checkout

    Log    User checks that paid reservation is found
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks The Paid Reservation Info Is Right In Reservations
    ...    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${MYBOOKINGS_STATUS_PAID_CONFIRMED}
    ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${BOOKING_NUM_ONLY}

    Log    User cancel booking
    app_user.User Cancel Booking In Reservations And Checks It Got Cancelled

    Log    waiting for the status payment to change
    Sleep    10s

    topnav.Navigate To My Bookings
    app_user.User Checks Cancelled Booking Is Found
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

User can make paid single booking
    [Tags]    desktop-test-data-set-4    desktop-suite
    Mark Paid Booking Test Started

    # Acquire lock to ensure email test waits
    Acquire Lock    PAID_BOOKING_EMAIL_SEQUENCE

    TRY
        common_setups_teardowns.Complete Test Setup From Tags
        app_common.User Logs In With Suomi Fi

        app_user.User Navigates To Single Booking Page
        app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_PAID_UNIT}
        app_user.User Selects The Time With Quick Reservation
        app_user.User Fills The Reservation Info For Unit With Payment
        app_user.User Checks The Paid Reservation Info Is Right And Submits
        app_user.User Checks Info In Paid Checkout And Confirms Booking
        app_user.User Checks The Paid Reservation Info Is Right After Checkout
        topnav.Navigate To My Bookings
        app_user.User Can See Upcoming Booking In List And Clicks It
        ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
        ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
        app_user.User Checks The Paid Reservation Info Is Right In Reservations
        ...    ${MYBOOKINGS_STATUS_CONFIRMED}
        ...    ${MYBOOKINGS_STATUS_PAID_CONFIRMED}
        ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
        ...    ${TIME_OF_QUICK_RESERVATION}
        ...    ${BOOKING_NUM_ONLY}
        app_user.User Cancel Booking In Reservations And Checks It Got Cancelled
        Sleep    10s    # Waiting for the status payment to change
        topnav.Navigate To My Bookings
        app_user.User Checks Cancelled Booking Is Found
        ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
        ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
        app_user.User Checks The Paid Reservation Info Is Right In Reservations
        ...    ${IN_RESERVATIONS_STATUS_CANCELED}
        ...    ${MYBOOKINGS_STATUS_REFUNDED}
        ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
        ...    ${TIME_OF_QUICK_RESERVATION}
        ...    ${BOOKING_NUM_ONLY}

        # Store mail data for email if test got this far successfully
        Store Test Data Variable    BOOKING_NUM_FOR_MAIL    ${BOOKING_NUM_ONLY}
        Store Test Data Variable    TIME_FOR_MAIL    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
        Store Test Data Variable    UNIT_NAME_FOR_MAIL    ${CURRENT_ALWAYS_PAID_UNIT}

        Mark Paid Booking Test Completed
    EXCEPT    AS    ${error}
        Log    Paid booking test failed: ${error}
        # Mark test as failed so email test doesn't run
        Mark Paid Booking Test Failed
        Fail    ${error}
    FINALLY
        # Always release lock
        Release Lock    PAID_BOOKING_EMAIL_SEQUENCE
    END

User can make subvented single booking that requires handling
    [Tags]    desktop-test-data-set-5    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}
    app_user.User Selects The Time With Quick Reservation
    app_user.User Fills Subvented Booking Details As Individual    ${JUSTIFICATION_FOR_SUBVENTION}
    app_user.User Checks The Paid Reservation That Requires Handling Info Is Right And Submits
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks Booking Info In Reservations With All Reservation Info
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}

User checks that reserved time is not available anymore
    [Tags]    desktop-test-data-set-7    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_user.User Selects The Time With Quick Reservation
    app_user.User Fills The Reservation Info For Always Free Unit
    app_user.User Checks The Reservation Info Is Right
    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_user.User Checks That Quick Reservation Does Not Have Reserved Time    ${TIME_OF_QUICK_RESERVATION_FREE_SLOT}
    app_user.User Checks That Reservation Calendar Does Not Have Reserved Time Slot Available
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_UNAVAILABLE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    Log    User cancels reservation
    app_user.User Cancel Booking In Reservations And Checks It Got Cancelled
    Log    No further checks are needed here

User checks that there are not current dates in the past bookings
    [Tags]    desktop-test-data-set-8    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    topnav.Navigate To My Bookings
    mybookings.Navigate To Past Bookings
    mybookings.Validate Reservations Are Not For Today Or Later

User can make free single booking and check info from downloaded calendar file
    [Tags]    desktop-test-data-set-9    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_FREE_UNIT}
    app_user.User Selects The Time With Quick Reservation
    app_user.User Fills The Reservation Info For Always Free Unit
    app_user.User Checks The Reservation Info Is Right
    app_user.User Saves File And Formats Booking Time To ICS    ${DOWNLOAD_ICS_FILE}
    app_user.User Checks That Calendar File Matches Booking Time
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Cancel Booking In Reservations And Checks It Got Cancelled
    topnav.Navigate To My Bookings
    app_user.User Checks Cancelled Booking Is Found
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

Check emails from reservations
    [Documentation]    Waits for paid booking test to complete, then verifies reservation emails.
    ...    This test depends on 'User can make paid single booking' completing successfully first.
    ...    Uses synchronization with polling to ensure proper test ordering.
    [Tags]    desktop-test-data-set-10    desktop-suite

    ${skip_message}=    Catenate
    ...    Test is being skipped because 'User can make paid single booking' test either failed or did not complete successfully.
    ...    Without a successful test, there may not be valid emails to verify.

    # Wait for the paid booking test to complete first
    ${status}=    Wait For Paid Booking Completion    timeout=300

    IF    "${status}" == "NOT_STARTED"
        Skip    Paid booking test is not part of this test run
    ELSE IF    "${status}" == "TIMEOUT"
        Skip    Paid booking test did not complete within timeout
    END

    # Now check if the test succeeded by checking for required data
    ${booking_num}=    Get Test Data Variable    BOOKING_NUM_FOR_MAIL    ${EMPTY}
    ${has_booking_data}=    Run Keyword And Return Status    Should Not Be Empty    ${booking_num}

    IF    not ${has_booking_data}
        Log    No booking data found - paid booking test likely failed
        Skip    ${skip_message}
    END

    # Now acquire the lock (paid booking test has finished successfully)
    Log    Acquiring lock after paid booking test completion...
    Acquire Lock    PAID_BOOKING_EMAIL_SEQUENCE

    # Get data for mail test. This is set in the paid booking test.
    ${booking_num_for_mail}=    Get Test Data Variable    BOOKING_NUM_FOR_MAIL
    ${time_for_mail}=    Get Test Data Variable    TIME_FOR_MAIL
    ${unit_name_for_mail}=    Get Test Data Variable    UNIT_NAME_FOR_MAIL

    # Format reservation times for email verification
    mail.Format Reservation Time For Email Texts And Receipts    ${time_for_mail}

    # Verify all email types using the new API-based approach
    # Each verification will check if emails exist and contain required terms
    mail.Verify Reservation Confirmation Email    ${booking_num_for_mail}
    mail.Verify Reservation Cancellation Email    ${booking_num_for_mail}

    Release Lock    PAID_BOOKING_EMAIL_SEQUENCE

User makes recurring reservation
    [Tags]    desktop-test-data-set-11    desktop-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    app_user.User Navigates To Recurring Booking Page

    Log    User selects a recurring booking and units
    recurring.User Selects A Recurring Booking Round    ${RECURRING_BOOKING_NAME}
    recurring.User Selects The Units For Recurring Reservation    ${RECURRING_UNIT_MALMI}
    recurring.User Selects The Units For Recurring Reservation    ${RECURRING_UNIT_KESKUSTA}
    recurring.User Checks The Count Of Selected Units    ${RECURRING_BOOKING_UNIT_COUNT_TEXT}
    recurring.User Clicks Continue Button

    Log    User fills the reservation info for recurring reservation
    app_user.User Fills In The Application Details For Recurring Application
    app_user.User Selects Times For Recurring Application
    app_user.User Fills In The Application User Info Details
    app_user.User Accepts Terms Of Use And Clicks Submit
    app_user.User Checks The Sent Page

    Log    User checks the reservation info is right
    app_user.User Checks The Sent Page

    Log    User cancels the recurring reservation
    topnav.Navigate To My Applications
    app_user.User Checks The Recurring Reservation Is Sent State And Cancels It
    app_common.Reload Page
    app_user.User Verifies The Recurring Reservation Is Cancelled
