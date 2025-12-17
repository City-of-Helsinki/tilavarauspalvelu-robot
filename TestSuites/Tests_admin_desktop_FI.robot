*** Settings ***
Documentation       Desktop browser tests for Admin functionality

Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot
Resource            ${CURDIR}/PO/Admin/admin_my_units.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/login.robot
Resource            ${CURDIR}/PO/Admin/django_admin.robot

Suite Setup         Run Only Once    create_data.Create Robot Test Data
Test Setup          Admin Opens Desktop Browser To Landing Page
Test Teardown       Complete Test Teardown


*** Test Cases ***
Admin logs in with suomi_fi
    [Tags]    admin-test-data-set-0    admin-suite    smoke
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.Admin Logs In With Suomi Fi
    app_common.Admin Logs Out

Admin verifies all reservation types and verifies no unavailable reservations exist
    [Tags]    admin-test-data-set-1    admin-suite
    common_setups_teardowns.Complete Test Setup From Tags
    Admin Logs In With Suomi Fi
    app_admin.Admin Navigates To Own Units And Selects Unit Group    ${UNIT_LOCATION}
    app_admin.Admin Opens Make Reservation Modal And Selects Unit    ${CURRENT_UNAVAILABLE_UNIT}

    app_admin.Admin Makes Reservation For Behalf
    app_admin.Admin Opens Make Reservation Modal And Selects Unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin Attempts To Make An Unavailable Reservation
    app_admin.Admin Opens Make Reservation Modal And Selects Unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin Makes Reservation For Closed
    app_admin.Admin Opens Make Reservation Modal And Selects Unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin Attempts To Make An Unavailable Reservation
    app_admin.Admin Opens Make Reservation Modal And Selects Unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin Makes Reservation For Staff
    app_admin.Admin Opens Make Reservation Modal And Selects Unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin Attempts To Make An Unavailable Reservation

Admin checks permissions
    [Tags]    admin-test-data-set-2    admin-suite    general-permissions-test
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.Open Django Admin In Firefox And App Admin In Chromium    ${URL_DJANGO_ADMIN}    ${URL_ADMIN}
    # Now in Chromium, so switch to Firefox for Django admin operations
    Switch Browser    ${BROWSER_ADMIN_SIDE}

    login.Login Django Admin    ${DJANGO_ADMIN_DJANGO_USERNAME}

    Log    Django admin changes permissions for admin user to notification manager
    django_admin.Admin Navigates To General Role Page
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_NOTIFICATION_MANAGER}
    django_admin.Admin Saves Changes

    # Switch to Chromium browser for app admin checks
    Switch Browser    ${BROWSER_USER_SIDE}
    Log    Checking permissions
    app_common.Permission Target Admin Logs In With Suomi Fi
    app_admin.Admin Checks Top Navigation For Notification Manager

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #

    Log    Django admin changes permissions to viewer
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_VIEWER}
    django_admin.Admin Saves Changes
    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Viewer
    app_admin.Admin Navigates To Own Units And Selects Unit Group    ${UNIT_LOCATION}
    app_admin.Admin Checks That Reservation Cannot Be Made

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #

    Log    Django admin changes permissions to reserver
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_RESERVER}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Reserver
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #
    Log    Django admin changes permissions to handler
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_HANDLER}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Handler
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #
    Log    Django admin changes permissions to admin
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_ADMIN}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Admin
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal

Admin checks unit permissions
    [Tags]    admin-test-data-set-3    admin-suite    unit-permissions-test
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.Open Django Admin In Firefox And App Admin In Chromium    ${URL_DJANGO_ADMIN}    ${URL_ADMIN}

    # Now in Chromium, so switch to Firefox for Django admin operations
    Switch Browser    ${BROWSER_ADMIN_SIDE}

    login.Login Django Admin    ${DJANGO_ADMIN_DJANGO_USERNAME}

    Log    Django admin checks that notification manager permission is not present
    django_admin.Admin Navigates To Unit Role Page
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Checks Permission Is Not Present    ${ADMIN_ROLE_NOTIFICATION_MANAGER}

    Log    Django admin changes permissions to viewer
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_VIEWER}
    django_admin.Admin Saves Changes
    #
    # Switch to Chromium browser for app admin checks
    Switch Browser    ${BROWSER_USER_SIDE}

    Log    Checking permissions for viewer
    app_common.Permission Target Admin Logs In With Suomi Fi
    #
    app_admin.Admin Checks Top Navigation For Viewer With Unit Permissions
    app_admin.Admin Navigates To Own Units And Selects Unit Group    ${UNIT_LOCATION}
    app_admin.Admin Checks That Reservation Cannot Be Made

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #

    Log    Django admin changes permissions to reserver
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_RESERVER}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Reserver With Unit Permissions
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #
    Log    Django admin changes permissions to handler
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_HANDLER}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Handler With Unit Permissions
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #
    Log    Django admin changes permissions to admin
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_ADMIN}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Admin With Unit Permissions
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal

Admin checks group unit permissions
    [Tags]    admin-test-data-set-4    admin-suite    unit-group-permissions-test
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.Open Django Admin In Firefox And App Admin In Chromium    ${URL_DJANGO_ADMIN}    ${URL_ADMIN}

    # Now in Chromium, so switch to Firefox for Django admin operations
    Switch Browser    ${BROWSER_ADMIN_SIDE}

    login.Login Django Admin    ${DJANGO_ADMIN_DJANGO_USERNAME}

    Log    Django admin checks that notification manager permission is not present
    django_admin.Admin Navigates To Unit Role Page
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Checks Permission Is Not Present    ${ADMIN_ROLE_NOTIFICATION_MANAGER}

    # Switch to Chromium browser for app admin checks
    Log    Django admin changes permissions to viewer
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_VIEWER}
    django_admin.Admin Saves Changes
    #
    # Switch to Chromium browser for app admin checks
    Switch Browser    ${BROWSER_USER_SIDE}

    Log    Checking permissions for viewer
    app_common.Permission Target Admin Logs In With Suomi Fi
    #
    app_admin.Admin Checks Top Navigation For Viewer With Group Unit Permissions
    app_admin.Admin Navigates To Own Units And Selects Unit Group    ${UNIT_LOCATION}
    app_admin.Admin Checks That Reservation Cannot Be Made

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #

    Log    Django admin changes permissions to reserver
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_RESERVER}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Reserver With Group Unit Permissions
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #
    Log    Django admin changes permissions to handler
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_HANDLER}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Handler With Group Unit Permissions
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #
    Log    Django admin changes permissions to admin
    django_admin.Admin Searches The User By Email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin Clicks First User
    django_admin.Admin Changes Permissions    ${ADMIN_ROLE_ADMIN}
    django_admin.Admin Saves Changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload Page
    #
    Log    Checking permissions
    app_admin.Admin Checks Top Navigation For Admin With Group Unit Permissions
    app_admin.Admin Clicks Make Reservation And Checks Dialog Opens
    admin_reservations.Admin Closes Dialog Modal
