*** Settings ***
Documentation       Admin notification tests that must run serially

Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot
Resource            ${CURDIR}/PO/Common/popups.robot
Resource            ${CURDIR}/Resources/data_modification.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/topnav.robot
Resource            ${CURDIR}/PO/Admin/admin_notifications.robot
Resource            ${CURDIR}/PO/Admin/admin_notifications_create_page.robot

Suite Setup         Run Only Once    create_data.Create Robot Test Data
Test Setup          User Opens Desktop Browser To Landing Page
Test Teardown       Complete Test Teardown


*** Test Cases ***
Admin creates normal notifications for both sides
    [Tags]    combined-test-data-set-0    combined-suite    serialonly
    common_setups_teardowns.Complete Test Setup From Tags
    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close Notification Banner If Visible
    #
    app_common.Admin Goes To Landing Page
    # Select Suite Specific Admin User
    app_common.Admin Logs In With Suomi Fi

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close Notification Banner If Visible
    #
    Log    Admin creates normal notification for both sides
    admin_navigation_menu.Admin Navigates To Notifications
    app_admin.Admin Creates Normal Notification For User And Admin Side
    app_common.Reload Page

    Log    Admin verifies notification banner is created
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    #
    app_common.Open New Window From Admin Side To User Side And Saves Both Windows    ${URL_TEST}
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes notification target group to only user
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin Selects Target Group User
    admin_notifications_create_page.Admin Publishes Notification
    app_common.Reload Page

    Log    Admin verifies notification banner is only visible on user side
    app_common.Verify Notification Banner Message Is Not Visible
    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload Page
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes notification target group to only admin
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin Selects Target Group Admin
    admin_notifications_create_page.Admin Publishes Notification
    app_common.Reload Page

    Log    Admin verifies notification banner is only visible on admin side
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload Page
    app_common.Verify Notification Banner Message Is Not Visible
    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin deletes notification
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin Deletes Notification
    app_common.Reload Page
    app_common.Verify Notification Banner Message Is Not Visible

Admin creates warning notifications for both sides
    [Tags]    combined-test-data-set-0    combined-suite    serialonly
    common_setups_teardowns.Complete Test Setup From Tags
    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close Notification Banner If Visible
    #
    app_common.Admin Goes To Landing Page
    # Select Suite Specific Admin User
    app_common.Admin Logs In With Suomi Fi

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close Notification Banner If Visible
    #
    Log    Admin creates warning notification for both sides
    admin_navigation_menu.Admin Navigates To Notifications
    app_admin.Admin Creates Warning Notification For User And Admin Side
    app_common.Reload Page

    Log    Admin verifies warning notification banner is created
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_WARNING}
    #
    app_common.Open New Window From Admin Side To User Side And Saves Both Windows    ${URL_TEST}
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_WARNING}
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes warning notification target group to only user
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    admin_notifications_create_page.Admin Selects Target Group User
    admin_notifications_create_page.Admin Publishes Notification
    app_common.Reload Page

    Log    Admin verifies warning notification banner is only visible on user side
    app_common.Verify Notification Banner Message Is Not Visible
    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload Page
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_WARNING}
    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes warning notification target group to only admin
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    admin_notifications_create_page.Admin Selects Target Group Admin
    admin_notifications_create_page.Admin Publishes Notification
    app_common.Reload Page

    Log    Admin verifies warning notification banner is only visible on admin side
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_WARNING}
    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload Page
    app_common.Verify Notification Banner Message Is Not Visible
    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin deletes warning notification
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_WARNING}
    admin_notifications_create_page.Admin Deletes Notification
    app_common.Reload Page
    app_common.Verify Notification Banner Message Is Not Visible

Admin creates error notifications for both sides
    [Tags]    combined-test-data-set-0    combined-suite    serialonly
    common_setups_teardowns.Complete Test Setup From Tags
    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close Notification Banner If Visible
    #
    app_common.Admin Goes To Landing Page
    app_common.Admin Logs In With Suomi Fi

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close Notification Banner If Visible
    #
    Log    Admin creates error notification for both sides
    admin_navigation_menu.Admin Navigates To Notifications
    app_admin.Admin Creates Error Notification For User And Admin Side
    app_common.Reload Page

    Log    Admin verifies error notification banner is created
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_ERROR}
    #
    app_common.Open New Window From Admin Side To User Side And Saves Both Windows    ${URL_TEST}
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_ERROR}
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes error notification target group to only user
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    admin_notifications_create_page.Admin Selects Target Group User
    admin_notifications_create_page.Admin Publishes Notification
    app_common.Reload Page

    Log    Admin verifies error notification banner is only visible on user side
    app_common.Verify Notification Banner Message Is Not Visible
    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload Page
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_ERROR}
    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes error notification target group to only admin
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    admin_notifications_create_page.Admin Selects Target Group Admin
    admin_notifications_create_page.Admin Publishes Notification
    app_common.Reload Page

    Log    Admin verifies error notification banner is only visible on admin side
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_ERROR}
    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload Page
    app_common.Verify Notification Banner Message Is Not Visible
    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin deletes error notification
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME_ERROR}
    admin_notifications_create_page.Admin Deletes Notification
    app_common.Reload Page
    app_common.Verify Notification Banner Message Is Not Visible

Admin creates notification and archive and deletes notification for both sides
    [Documentation]    In this test we don't check every step of the notification creation process.
    ...    We avoid double checking the same parts as in "Admin creates normal notifications for both sides" test.
    [Tags]    combined-test-data-set-0    combined-suite    serialonly
    common_setups_teardowns.Complete Test Setup From Tags

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close Notification Banner If Visible
    #
    app_common.Admin Goes To Landing Page
    app_common.Admin Logs In With Suomi Fi

    Log    Test cleanup
    # This is for test cleanup if the last run failed
    popups.Close Notification Banner If Visible
    #
    Log    Admin creates normal notification
    admin_navigation_menu.Admin Navigates To Notifications
    #
    app_admin.Admin Creates Normal Notification For User And Admin Side

    Log    Admin verifies notification banner is created
    app_common.Reload Page
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    #
    Log    Admin drafts notification
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin Drafts Notification
    app_common.Reload Page

    Log    Admin verifies notification banner is drafted and not visible
    app_common.Verify Notification Banner Message Is Not Visible

    app_common.Open New Window From Admin Side To User Side And Saves Both Windows    ${URL_TEST}
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Verify Notification Banner Message Is Not Visible
    Switch Page    ${PAGE_ADMIN_SIDE}

    Log    Admin checks notification is published from drafted state
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin Publishes Notification
    app_common.Reload Page
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload Page
    app_common.Verify Notification Banner Message
    ...    ${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}
    ...    ${NOTIFICATION_TYPE_NORMAL}
    Switch Page    ${PAGE_ADMIN_SIDE}

    Log    Admin deletes notification
    admin_notifications.Admin Clicks Notification Name
    ...    ${NOTIFICATION_BANNER_MESSAGE_NAME}
    admin_notifications_create_page.Admin Deletes Notification
    app_common.Reload Page
    app_common.Verify Notification Banner Message Is Not Visible
    admin_notifications.Admin Verifies Notification Is Not Found    ${NOTIFICATION_BANNER_MESSAGE_NAME}
