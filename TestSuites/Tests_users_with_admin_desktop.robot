*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_common.robot
Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/Resources/data_modification.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_mainmenu.robot

Test Setup          User opens desktop browser to landing page
Test Teardown       Run Keyword If Test Failed    Take Screenshot


*** Test Cases ***
User creates and Admin accepts single booking that requires handling
    app_common.User logs in with suomi_fi
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${ALWAYS_PAID_UNIT_SUBVENTED}
    app_user.User selects the time with quick reservation
    app_user.User fills subvented booking details as individual    ${JUSTIFICATION_FOR_SUBVENTION}
    # app_user.User checks the paid reservation info is right and submits
    app_user.User checks the subvented reservation info is right and submits
    app_user.User checks the subvented reservation info is right after submitting
#
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${ALWAYS_PAID_UNIT_SUBVENTED_WITH_UNIT_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations with all reservation info
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
# Formats info of subvented reservation to admin side
    data_modification.Formats reservation number and name for admin side
    data_modification.Formats tagline for admin side
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${ALWAYS_PAID_UNIT_SUBVENTED_WITH_UNIT_LOCATION}
    app_common.User logs out
# Admin part
    app_common.Admin goes to landing Page
    app_common.Admin logs in with suomi_fi
    admin_mainmenu.Admin navigates to requested reservations
    admin_reservations.Admin searches reservation with id number and clicks it from name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${BASIC_USER_MALE_FULLNAME}
    app_admin.Admin checks the info and sets reservation free and approves it
    app_admin.Admin edits reservation time
    app_common.Admin logs out
# User part
    app_common.User goes to landing Page
    app_common.User logs in with suomi_fi
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${ALWAYS_PAID_UNIT_SUBVENTED_WITH_UNIT_LOCATION}
    ...    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD_MINUS_T}
    app_user.User verifies details of subvented reservation after admin approval without payment

User creates and Admin declines single booking that requires handling
    app_common.User logs in with suomi_fi
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${UNIT_REQUIRES_ALWAYS_HANDLING}
    app_user.User selects the time with quick reservation
    app_user.User fills info for unit that is always handled as individual
    app_user.User checks unit that is always handled details are right
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${UNIT_REQUIRES_ALWAYS_HANDLING_WITH_UNIT_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations with number of participants and description and purpose
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}
# Formats info of subvented reservation to admin side
    data_modification.Formats reservation number and name for admin side
    data_modification.Formats tagline for admin side
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${UNIT_REQUIRES_ALWAYS_HANDLING_WITH_UNIT_LOCATION}
    app_common.User logs out
# Admin part
    app_common.Admin goes to landing Page
    app_common.Admin logs in with suomi_fi
    admin_mainmenu.Admin navigates to requested reservations
    admin_reservations.Admin searches reservation with id number and clicks it from name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${BASIC_USER_MALE_FULLNAME}
    app_admin.Admin checks the info and cancels reservation
    app_admin.Admin returns reservation to handling state from rejected state
    app_admin.Admin rejects reservation and checks the status
    app_common.Admin logs out
# User part
    app_common.User goes to landing Page
    app_common.User logs in with suomi_fi
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${UNIT_REQUIRES_ALWAYS_HANDLING_WITH_UNIT_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks the rejected reservation info is right after admin handling
