*** Settings ***
Documentation       Iphone webkit tests

Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/topnav.robot
Resource            ${CURDIR}/PO/App/app_common.robot

Suite Setup         Run Only Once    create_data.Create Robot Test Data
Test Setup          User Opens Iphone Webkit To Landing Page
Test Teardown       Complete Test Teardown


*** Test Cases ***
User logs in and out with suomi_fi
    [Tags]    mobile-iphone-data-set-0    iphone-suite
    common_setups_teardowns.Complete Test Setup From Tags

    Log    User logs in with Suomi.fi
    app_common.User Logs In With Suomi Fi Mobile

    Log    User logs out
    app_common.User Logs Out Mobile
    app_common.User Confirms Log Out Mobile

User can make free single booking and modifies it
    [Tags]    mobile-iphone-data-set-1    iphone-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi Mobile

    Log    User creates reservation
    app_user.User Navigates To Single Booking Page Mobile
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_FREE_UNIT}
    app_user.User Selects The Time With Quick Reservation And Sets Time Variables
    quick_reservation.User Clicks Submit Button In Quick Reservation
    app_user.User Fills The Reservation Info For Always Free Unit
    app_user.User Checks The Reservation Info Is Right Before Submit
    reservation_lownav.Click Submit Button Continue
    app_user.User Checks The Reservation Info Is Right After Submit
    topnav.Navigate To My Bookings Mobile
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

    Log    User modifies reservation
    app_user.User Modifies Booking And Verifies The Changes
    app_user.User Checks The Modified Reservation Info Is Right And Clicks Continue

    Log    User cancels reservation
    app_user.User Cancel Booking In Reservations And Checks It Got Cancelled
    topnav.Navigate To My Bookings Mobile
    app_user.User Checks Cancelled Booking Is Found Mobile
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T_MODIFIED}
    app_user.User Checks Booking Info In Reservations
    ...    ${IN_RESERVATIONS_STATUS_CANCELED}
    ...    ${SINGLEBOOKING_NO_PAYMENT}
    ...    ${TIME_OF_QUICK_RESERVATION_MODIFIED}

User can make paid single booking
    [Tags]    mobile-iphone-data-set-2    iphone-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi Mobile

    Log    User creates paid reservation
    app_user.User Navigates To Single Booking Page Mobile
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_PAID_UNIT}
    app_user.User Selects The Time With Quick Reservation And Sets Time Variables
    quick_reservation.User Clicks Submit Button In Quick Reservation
    app_user.User Fills The Reservation Info For Unit With Payment
    app_user.User Checks The Paid Reservation Info Is Right And Submits

    Log    User pays the reservation
    app_user.User Checks Info In Paid Checkout And Confirms Booking
    app_user.User Checks The Paid Reservation Info Is Right After Checkout

    Log    User verifies paid reservation in my bookings and paid status
    topnav.Navigate To My Bookings Mobile
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks The Paid Reservation Info Is Right In Reservations
    ...    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${MYBOOKINGS_STATUS_PAID_CONFIRMED}
    ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${BOOKING_NUM_ONLY}

    Log    User cancels paid booking
    app_user.User Cancel Booking In Reservations And Checks It Got Cancelled

    Log    User verifies cancellation and refund status
    topnav.Navigate To My Bookings Mobile
    app_user.User Checks Cancelled Booking Is Found Mobile
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks The Paid Reservation Info Is Right In Reservations
    ...    ${IN_RESERVATIONS_STATUS_CANCELED}
    ...    ${MYBOOKINGS_STATUS_REFUNDED}
    ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${BOOKING_NUM_ONLY}

User can make paid single booking with interrupted checkout
    [Tags]    mobile-iphone-data-set-3    iphone-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi Mobile

    Log    User creates reservation
    app_user.User Navigates To Single Booking Page Mobile
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_PAID_UNIT}
    app_user.User Selects The Time With Quick Reservation And Sets Time Variables
    quick_reservation.User Clicks Submit Button In Quick Reservation
    app_user.User Fills The Reservation Info For Unit With Payment
    app_user.User Checks The Paid Reservation Info Is Right And Submits

    Log    User pays the reservation
    app_user.User Interrupts Paid Checkout    ${URL_TEST}
    app_user.User Accepts Payment To Checkout
    app_user.User Checks Info In Paid Checkout And Confirms Booking
    app_user.User Checks The Paid Reservation Info Is Right After Checkout

    Log    User verifies paid reservation in my bookings and paid status
    topnav.Navigate To My Bookings Mobile
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks The Paid Reservation Info Is Right In Reservations
    ...    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${MYBOOKINGS_STATUS_PAID_CONFIRMED}
    ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${BOOKING_NUM_ONLY}

    Log    User cancels paid booking
    app_user.User Cancel Booking In Reservations And Checks It Got Cancelled

    Log    User verifies cancelled booking is found
    topnav.Navigate To My Bookings Mobile
    app_user.User Checks Cancelled Booking Is Found Mobile
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

User can make booking that requires handling
    [Tags]    mobile-iphone-data-set-4    iphone-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi Mobile

    Log    User creates reservation that requires handling
    app_user.User Navigates To Single Booking Page Mobile
    app_user.User Uses Search To Find Right Unit    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING}
    app_user.User Selects The Time With Quick Reservation And Sets Time Variables
    quick_reservation.User Clicks Submit Button In Quick Reservation
    app_user.User Fills Info For Unit That Is Always Handled As Individual
    app_user.User Checks Unit That Is Always Handled Details Are Right Before Submit
    reservation_lownav.Click Submit Button Continue
    app_user.User Checks Unit That Is Always Handled Details Are Right After Submit

    Log    User verifies reservation in my bookings and reservation status
    topnav.Navigate To My Bookings Mobile
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks Booking Info In Reservations With Number Of Participants And Description And Purpose
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}

User can make subvented single booking that requires handling
    [Tags]    mobile-iphone-data-set-5    iphone-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi Mobile

    Log    User creates subvented reservation
    app_user.User Navigates To Single Booking Page Mobile
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}
    app_user.User Selects The Time With Quick Reservation And Sets Time Variables
    quick_reservation.User Clicks Submit Button In Quick Reservation
    app_user.User Fills Subvented Booking Details As Individual    ${JUSTIFICATION_FOR_SUBVENTION}
    app_user.User Checks The Paid Reservation That Requires Handling Info Is Right And Submits

    Log    User verifies reservation in my bookings and reservation status
    topnav.Navigate To My Bookings Mobile
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks Booking Info In Reservations With All Reservation Info
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
