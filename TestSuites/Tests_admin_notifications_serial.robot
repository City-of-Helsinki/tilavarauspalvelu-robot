*** Settings ***
Documentation       Admin notification tests that must run serially

Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot
Resource            ${CURDIR}/PO/Common/popups.robot
Resource            ${CURDIR}/Resources/data_modification.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/topNav.robot
Resource            ${CURDIR}/PO/Admin/admin_notifications.robot
Resource            ${CURDIR}/PO/Admin/admin_notifications_create_page.robot

Test Setup          User opens desktop browser to landing page
Test Teardown       Complete Test Teardown


*** Test Cases ***
Admin creates normal notifications for both sides
    [Tags]    serialonly
    common_setups_teardowns.Complete Combined Test Setup
    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    app_common.Admin goes to landing page
    # Select Suite Specific Admin User
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
    [Tags]    serialonly
    common_setups_teardowns.Complete Combined Test Setup
    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close notification banner if visible
    #
    app_common.Admin goes to landing page
    # Select Suite Specific Admin User
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
    [Tags]    serialonly
    common_setups_teardowns.Complete Combined Test Setup
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
    [Tags]    serialonly
    common_setups_teardowns.Complete Combined Test Setup

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
    admin_notifications.Admin verifies notification is not found    ${NOTIFICATION_BANNER_MESSAGE_NAME}
