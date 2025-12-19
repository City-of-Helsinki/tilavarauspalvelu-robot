*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot
Resource            ${CURDIR}/Resources/data_modification.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/topnav.robot
Resource            ${CURDIR}/PO/Admin/admin_notifications.robot
Resource            ${CURDIR}/PO/Admin/admin_notifications_create_page.robot

Suite Setup         Run Only Once    create_data.Create Robot Test Data
Test Setup          User Opens Desktop Browser To Landing Page
Test Teardown       Complete Test Teardown


*** Test Cases ***
User creates and Admin accepts single booking that requires handling
    [Tags]    combined-test-data-set-0    combined-suite    accept-booking
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    Log    User creates subvented reservation
    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}
    app_user.User Selects The Time With Quick Reservation And Sets Time Variables
    quick_reservation.User Clicks Submit Button In Quick Reservation
    app_user.User Fills Subvented Booking Details As Individual And Submits    ${JUSTIFICATION_FOR_SUBVENTION}
    app_user.User Checks The Subvented Reservation Info Is Right And Submits
    app_user.User Checks The Subvented Reservation Info Is Right After Submitting
#
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks Booking Info In Reservations With All Reservation Info
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}

    Log    Formats info of subvented reservation to admin side
    data_modification.Formats Reservation Number And Name For Admin Side
    data_modification.Formats Tagline For Admin Side
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
#
    app_common.User Logs Out

    Log    Admin logs in and approves reservation
    app_common.Admin Goes To Landing Page
    app_common.Admin Logs In With Suomi Fi
    admin_navigation_menu.Admin Navigates To Requested Reservations
    admin_reservations.Admin Searches Reservation With Id Number And Clicks It From Name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${CURRENT_USER_FULLNAME}
    app_admin.Admin Checks The Info And Sets Reservation Free And Approves It
    app_admin.Admin Edits Reservation Time
#
    app_common.Admin Logs Out

    Log    User logs in and verifies approved reservation
    app_common.User Goes To Landing Page
    app_common.User Logs In With Suomi Fi
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD_MINUS_T}
    app_user.User Verifies Details Of Subvented Reservation After Admin Approval Without Payment

User creates and Admin declines single booking that requires handling
    [Tags]    combined-test-data-set-1    combined-suite    decline-booking
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    Log    User creates reservation that requires handling
    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING}
    app_user.User Selects The Time With Quick Reservation And Sets Time Variables
    quick_reservation.User Clicks Submit Button In Quick Reservation
    app_user.User Fills Info For Unit That Is Always Handled As Individual And Submits
    app_user.User Checks Unit That Is Always Handled Details Are Right Before Submit
    reservation_lownav.Click Submit Button Continue
    app_user.User Checks Unit That Is Always Handled Details Are Right After Submit
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks Booking Info In Reservations With Number Of Participants And Description And Purpose
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}

    Log    Formats info of subvented reservation to admin side
    data_modification.Formats Reservation Number And Name For Admin Side
    data_modification.Formats Tagline For Admin Side
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
#
    app_common.User Logs Out

    Log    Admin logs in and rejects reservation
    app_common.Admin Goes To Landing Page
    app_common.Admin Logs In With Suomi Fi
    admin_navigation_menu.Admin Navigates To Requested Reservations
    admin_reservations.Admin Searches Reservation With Id Number And Clicks It From Name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${CURRENT_USER_FULLNAME}
    app_admin.Admin Checks The Info And Cancels Reservation
    app_admin.Admin Returns Reservation To Handling State From Rejected State
    app_admin.Admin Rejects Reservation And Checks The Status
#
    app_common.Admin Logs Out

    Log    User logs in and verifies rejected reservation
    app_common.User Goes To Landing Page
    app_common.User Logs In With Suomi Fi
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User Checks The Rejected Reservation Info Is Right After Admin Handling

User can make reservation with access code and admin changes the code
    [Tags]    combined-test-data-set-2    combined-suite    access-code
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User Logs In With Suomi Fi

    Log    User creates reservation
    app_user.User Navigates To Single Booking Page
    app_user.User Uses Search To Find Right Unit    ${CURRENT_UNIT_WITH_ACCESS_CODE}
    app_user.User Selects The Time With Quick Reservation And Sets Time Variables
    quick_reservation.User Clicks Submit Button In Quick Reservation
    app_user.User Fills Booking Details As Individual For Reservation With Access Code And Submits
    app_user.User Checks The Reservation Info Is Right Before Submit With Access Code
    reservation_lownav.Click Submit Button Continue
    app_user.User Checks The Reservation Info Is Right After Submit With Access Code
#
    app_common.User Logs Out

    Log    Admin logs in and changes access code
    app_common.Admin Goes To Landing Page
    app_common.Admin Logs In With Suomi Fi
    admin_navigation_menu.Admin Navigates To Requested Reservations
    admin_reservations.Admin Searches Reservation With Id Number And Clicks It From Name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${CURRENT_USER_FULLNAME}

    Log    Changing access code
    app_admin.Admin Opens Access Code Modal
    app_admin.Admin Checks Access Code Matches    ${ACCESS_CODE}
    app_admin.Admin Changes Access Code
    app_admin.Admin Checks Access Code Does Not Match    ${ACCESS_CODE}
    app_admin.Admin Saves Access Code
#
    app_common.Admin Logs Out

    Log    User logs in and checks access code was changed
    app_common.User Goes To Landing Page
    app_common.User Logs In With Suomi Fi
    topnav.Navigate To My Bookings
    app_user.User Can See Upcoming Booking In List And Clicks It
    ...    ${CURRENT_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
#
    app_user.User Checks Booking Info In Reservations With Access Code
    ...    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${SINGLEBOOKING_NO_PAYMENT}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${ACCESS_CODE_ADMINSIDE}
