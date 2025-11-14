*** Settings ***
Documentation       Android chrome tests

Resource            ${CURDIR}/PO/App/app_common.robot
Resource            ${CURDIR}/PO/App/app_user.robot
# Resource    ${CURDIR}/PO/Common/popups.robot
# Resource    ${CURDIR}/Resources/texts_FI.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/topNav.robot

Suite Setup         Run Only Once    create_data.Create robot test data
Test Setup          User opens android chrome to landing page
Test Teardown       Complete Test Teardown


*** Test Cases ***
User logs in and out with suomi_fi mobile
    [Tags]    mobile-android-data-set-0    android-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User logs in with suomi_fi mobile
    app_common.User logs out mobile
    app_common.User confirms log out mobile

User can make a free single booking and modifies it mobile
    [Tags]    mobile-android-data-set-1    android-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User logs in with suomi_fi mobile
    app_user.User navigates to single booking page mobile
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_FREE_UNIT}
    app_user.User selects the time with quick reservation
    app_user.User fills the reservation info for always free unit
    app_user.User checks the reservation info is right
    topNav.Navigate to my bookings mobile
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User modifies booking and verifies the changes
    app_user.User checks the modified reservation info is right
    app_user.User cancel booking in reservations and checks it got cancelled
    topNav.Navigate to my bookings mobile
    app_user.User checks cancelled booking is found mobile
    ...    ${CURRENT_ALWAYS_FREE_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T_MODIFIED}
    app_user.User checks booking info in reservations
    ...    ${IN_RESERVATIONS_STATUS_CANCELED}
    ...    ${SINGLEBOOKING_NO_PAYMENT}
    ...    ${TIME_OF_QUICK_RESERVATION_MODIFIED}

User can make paid single booking mobile
    [Tags]    mobile-android-data-set-2    android-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User logs in with suomi_fi mobile
    app_user.User navigates to single booking page mobile
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_PAID_UNIT}
    app_user.User selects the time with quick reservation
    app_user.User fills the reservation info for unit with payment
    app_user.User checks the paid reservation info is right and submits
    app_user.User checks info in paid checkout and confirms booking
    app_user.User checks the paid reservation info is right after checkout
    topNav.Navigate to my bookings mobile
    popups.User accepts cookies if dialog is visible    ${COOKIETEXT}
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
    topNav.Navigate to my bookings mobile
    app_user.User checks cancelled booking is found mobile
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks the paid reservation info is right in reservations
    ...    ${IN_RESERVATIONS_STATUS_CANCELED}
    ...    ${MYBOOKINGS_STATUS_REFUNDED}
    ...    ${SINGLEBOOKING_PAID_PRICE_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${BOOKING_NUM_ONLY}

User can make paid single booking with interrupted checkout mobile
    [Tags]    mobile-android-data-set-3    android-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User logs in with suomi_fi mobile
    app_user.User navigates to single booking page mobile
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_PAID_UNIT}
    app_user.User selects the time with quick reservation
    app_user.User fills the reservation info for unit with payment
    app_user.User checks the paid reservation info is right and submits
    app_user.User interrupts paid checkout    ${URL_TEST}
    app_user.User accepts payment to checkout
    app_user.User checks info in paid checkout and confirms booking
    app_user.User checks the paid reservation info is right after checkout
    topNav.Navigate to my bookings mobile
    popups.User accepts cookies if dialog is visible    ${COOKIETEXT}
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
    topNav.Navigate to my bookings mobile
    app_user.User checks cancelled booking is found mobile
    ...    ${CURRENT_ALWAYS_PAID_UNIT_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}

User can make single booking that requires handling mobile
    [Tags]    mobile-android-data-set-4    android-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User logs in with suomi_fi mobile
    app_user.User navigates to single booking page mobile
    app_user.User uses search to find right unit    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING}
    app_user.User selects the time with quick reservation
    app_user.User fills info for unit that is always handled as individual
    app_user.User checks unit that is always handled details are right
    topNav.Navigate to my bookings mobile
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations with number of participants and description and purpose
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}

User can make subvented single booking that requires handling mobile
    [Tags]    mobile-android-data-set-5    android-suite
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.User logs in with suomi_fi mobile
    app_user.User navigates to single booking page mobile
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}
    app_user.User selects the time with quick reservation
    app_user.User fills subvented booking details as individual    ${JUSTIFICATION_FOR_SUBVENTION}
    app_user.User checks the paid reservation that requires handling info is right and submits
    topNav.Navigate to my bookings mobile
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations with all reservation info
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
