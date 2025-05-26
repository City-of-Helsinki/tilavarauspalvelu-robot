*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_common.robot
Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot
Resource            ${CURDIR}/PO/Common/popups.robot
Resource            ${CURDIR}/Resources/data_modification.robot

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
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi
    admin_navigation_menu.Admin navigates to requested reservations
    admin_reservations.Admin searches reservation with id number and clicks it from name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${BASIC_USER_MALE_FULLNAME}
    app_admin.Admin checks the info and sets reservation free and approves it
    app_admin.Admin edits reservation time
    app_common.Admin logs out
# User part
    app_common.User goes to landing page
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
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi
    admin_navigation_menu.Admin navigates to requested reservations
    admin_reservations.Admin searches reservation with id number and clicks it from name
    ...    ${BOOKING_NUM_ONLY}
    ...    ${BASIC_USER_MALE_FULLNAME}
    app_admin.Admin checks the info and cancels reservation
    app_admin.Admin returns reservation to handling state from rejected state
    app_admin.Admin rejects reservation and checks the status
    app_common.Admin logs out
# User part
    app_common.User goes to landing page
    app_common.User logs in with suomi_fi
    topNav.Navigate to my bookings
    app_user.User can see upcoming booking in list and clicks it
    ...    ${UNIT_REQUIRES_ALWAYS_HANDLING_WITH_UNIT_LOCATION}
    ...    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    app_user.User checks the rejected reservation info is right after admin handling

Admin creates normal notifications for both sides
    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    Log    Admin creates normal notification for both sides
    admin_navigation_menu.Admin navigates to notifications
    app_admin.Admin creates normal notification for user and admin side
    app_common.Reload page

    Log    Admin verifies notification banner is created
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    #
    app_common.Open new window from admin side to user side and saves both windows
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes notification target group to only user
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin selects target group user
    admin_notifications_create_page.Admin publishes notification
    app_common.Reload page

    Log    Admin verifies notification banner is only visible on user side
    app_common.Verify notification banner message is not visible
    #
    Switch page    ${PAGE_USER_SIDE}
    app_common.Reload page
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    #
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes notification target group to only admin
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin selects target group admin
    admin_notifications_create_page.Admin publishes notification
    app_common.Reload page

    Log    Admin verifies notification banner is only visible on admin side
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    #
    Switch page    ${PAGE_USER_SIDE}
    app_common.Reload page
    app_common.Verify notification banner message is not visible
    #
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin deletes notification
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin deletes notification
    app_common.Reload page
    app_common.Verify notification banner message is not visible

Admin creates warning notifications for both sides
    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    Log    Admin creates warning notification for both sides
    admin_navigation_menu.Admin navigates to notifications
    app_admin.Admin creates warning notification for user and admin side
    app_common.Reload page

    Log    Admin verifies warning notification banner is created
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_WARNING}
    #
    app_common.Open new window from admin side to user side and saves both windows
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_WARNING}
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes warning notification target group to only user
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    admin_notifications_create_page.Admin selects target group user
    admin_notifications_create_page.Admin publishes notification
    app_common.Reload page

    Log    Admin verifies warning notification banner is only visible on user side
    app_common.Verify notification banner message is not visible
    #
    Switch page    ${PAGE_USER_SIDE}
    app_common.Reload page
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_WARNING}
    #
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes warning notification target group to only admin
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    admin_notifications_create_page.Admin selects target group admin
    admin_notifications_create_page.Admin publishes notification
    app_common.Reload page

    Log    Admin verifies warning notification banner is only visible on admin side
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_WARNING}
    #
    Switch page    ${PAGE_USER_SIDE}
    app_common.Reload page
    app_common.Verify notification banner message is not visible
    #
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin deletes warning notification
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    admin_notifications_create_page.Admin deletes notification
    app_common.Reload page
    app_common.Verify notification banner message is not visible

Admin creates error notifications for both sides
    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    Log    Admin creates error notification for both sides
    admin_navigation_menu.Admin navigates to notifications
    app_admin.Admin creates error notification for user and admin side
    app_common.Reload page

    Log    Admin verifies error notification banner is created
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_ERROR}
    #
    app_common.Open new window from admin side to user side and saves both windows
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_ERROR}
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes error notification target group to only user
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    admin_notifications_create_page.Admin selects target group user
    admin_notifications_create_page.Admin publishes notification
    app_common.Reload page

    Log    Admin verifies error notification banner is only visible on user side
    app_common.Verify notification banner message is not visible
    #
    Switch page    ${PAGE_USER_SIDE}
    app_common.Reload page
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_ERROR}
    #
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes error notification target group to only admin
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    admin_notifications_create_page.Admin selects target group admin
    admin_notifications_create_page.Admin publishes notification
    app_common.Reload page

    Log    Admin verifies error notification banner is only visible on admin side
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_ERROR}
    #
    Switch page    ${PAGE_USER_SIDE}
    app_common.Reload page
    app_common.Verify notification banner message is not visible
    #
    Switch page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin deletes error notification
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    admin_notifications_create_page.Admin deletes notification
    app_common.Reload page
    app_common.Verify notification banner message is not visible

Admin creates notification and archive and deletes notification for both sides
    [Documentation]    In this test we dont check every step of the notification creation process.
    ...    We avoid double checking the same parts as in "Admin creates normal notifications for both sides" test.

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    app_common.Admin goes to landing page
    app_common.Admin logs in with suomi_fi

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    Log    Admin creates normal notification
    admin_navigation_menu.Admin navigates to notifications
    #
    app_admin.Admin creates normal notification for user and admin side

    Log    Admin verifies notification banner is created
    app_common.Reload page
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    #
    Log    Admin drafts notification
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin drafts notification
    app_common.Reload page

    Log    Admin verifies notification banner is drafted and not visible
    app_common.Verify notification banner message is not visible

    app_common.Open new window from admin side to user side and saves both windows
    Switch page    ${PAGE_USER_SIDE}
    app_common.Verify notification banner message is not visible
    Switch page    ${PAGE_ADMIN_SIDE}

    Log    Admin checks notification is published from drafted state
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin publishes notification
    app_common.Reload page
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    Switch page    ${PAGE_USER_SIDE}
    app_common.Reload page
    app_common.Verify notification banner message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    Switch page    ${PAGE_ADMIN_SIDE}

    Log    Admin deletes notification
    admin_notifications.Admin clicks notification name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin deletes notification
    app_common.Reload page
    app_common.Verify notification banner message is not visible
