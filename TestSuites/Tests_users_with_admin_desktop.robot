*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot
Resource            ${CURDIR}/Resources/data_modification.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/topNav.robot
Resource            ${CURDIR}/PO/Admin/admin_notifications.robot
Resource            ${CURDIR}/PO/Admin/admin_notifications_create_page.robot

Suite Setup         Run Only Once    create_data.Create robot test data
Test Setup          User opens desktop browser to landing page
Test Teardown       Complete Test Teardown


*** Test Cases ***
User creates and Admin accepts single booking that requires handling
    common_setups_teardowns.Complete Combined Test Setup
    app_common.User logs in with suomi_fi

    Log    User creates subvented reservation
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED}
    app_user.User selects the time with quick reservation
    app_user.User fills subvented booking details as individual    ${JUSTIFICATION_FOR_SUBVENTION}
    app_user.User checks the subvented reservation info is right and submits
    app_user.User checks the subvented reservation info is right after submitting
#
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations with all reservation info
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}

    Log    Formats info of subvented reservation to admin side
    data_modification.Formats reservation number and name for admin side
    data_modification.Formats tagline for admin side
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
#
    app_common.User logs out

    Log    Admin logs in and approves reservation
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi
    admin_navigation_menu.Admin navigates to requested reservations
    admin_reservations.Admin searches reservation with id number and clicks it from name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${CURRENT_USER_FULLNAME}
    app_admin.Admin checks the info and sets reservation free and approves it
    app_admin.Admin edits reservation time
#
    app_common.Admin logs out

    Log    User logs in and verifies approved reservation
    app_common.User goes to landing page
    app_common.User logs in with suomi_fi
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}
    ...    ${ADMIN_MODIFIES_TIME_OF_INFO_CARD_MINUS_T}
    app_user.User verifies details of subvented reservation after admin approval without payment

User creates and Admin declines single booking that requires handling
    common_setups_teardowns.Complete Combined Test Setup
    app_common.User logs in with suomi_fi

    Log    User creates reservation that requires handling
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING}
    app_user.User selects the time with quick reservation
    app_user.User fills info for unit that is always handled as individual
    app_user.User checks unit that is always handled details are right
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks booking info in reservations with number of participants and description and purpose
    ...    ${MYBOOKINGS_STATUS_PROCESSED}
    ...    ${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}
    ...    ${TIME_OF_QUICK_RESERVATION}

    Log    Formats info of subvented reservation to admin side
    data_modification.Formats reservation number and name for admin side
    data_modification.Formats tagline for admin side
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
#
    app_common.User logs out

    Log    Admin logs in and rejects reservation
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi
    admin_navigation_menu.Admin navigates to requested reservations
    admin_reservations.Admin searches reservation with id number and clicks it from name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${CURRENT_USER_FULLNAME}
    app_admin.Admin checks the info and cancels reservation
    app_admin.Admin returns reservation to handling state from rejected state
    app_admin.Admin rejects reservation and checks the status
#
    app_common.Admin logs out

    Log    User logs in and verifies rejected reservation
    app_common.User goes to landing page
    app_common.User logs in with suomi_fi
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks the rejected reservation info is right after admin handling

User can make reservation with access code and admin changes the code
    common_setups_teardowns.Complete Desktop User Test Setup
    app_common.User logs in with suomi_fi

    Log    User creates reservation
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit    ${CURRENT_UNIT_WITH_ACCESS_CODE}
    app_user.User selects the time with quick reservation
    app_user.User fills booking details as individual for reservation with access code
    app_user.User checks the reservation info is right with access code    # TODO add submit here in the middle
#
    app_common.User logs out

    Log    Admin logs in and changes access code
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi
    admin_navigation_menu.Admin navigates to requested reservations
    admin_reservations.Admin searches reservation with id number and clicks it from name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${CURRENT_USER_FULLNAME}

    Log    Changing access code
    app_admin.Admin opens access code modal
    app_admin.Admin checks access code matches    ${ACCESS_CODE}
    app_admin.Admin changes access code
    app_admin.Admin checks access code does not match    ${ACCESS_CODE}
    app_admin.Admin saves access code
#
    app_common.Admin logs out

    Log    User logs in and checks access code was changed
    app_common.User goes to landing page
    app_common.User logs in with suomi_fi
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${CURRENT_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
#
    app_user.User checks booking info in reservations with access code
    ...    ${MYBOOKINGS_STATUS_CONFIRMED}
    ...    ${SINGLEBOOKING_NO_PAYMENT}
    ...    ${TIME_OF_QUICK_RESERVATION}
    ...    ${ACCESS_CODE_ADMINSIDE}
