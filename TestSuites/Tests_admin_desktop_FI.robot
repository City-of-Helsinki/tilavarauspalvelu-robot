*** Settings ***
Documentation       Desktop browser tests for Admin functionality

Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot
Resource            ${CURDIR}/PO/Admin/admin_my_units.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/login.robot
Resource            ${CURDIR}/PO/Admin/django_admin.robot

Suite Setup         Run Only Once    create_data.Create robot test data
Test Setup          Admin opens desktop browser to landing page
Test Teardown       Complete Test Teardown


*** Test Cases ***
Admin logs in with suomi_fi
    [Tags]    admin-test-data-set-0    admin-suite    smoke
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.Admin logs in with suomi_fi
    app_common.Admin logs out

Admin verifies all reservation types and verifies no unavailable reservations exist
    [Tags]    admin-test-data-set-1    admin-suite    verification
    common_setups_teardowns.Complete Test Setup From Tags
    Admin logs in with suomi_fi
    app_admin.Admin navigates to own units and selects unit group    ${UNIT_LOCATION}
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}

    app_admin.Admin makes reservation for behalf
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for closed
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for staff
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation

Admin checks permissions
    [Tags]    admin-test-data-set-2    admin-suite    permissions
    common_setups_teardowns.Complete Test Setup From Tags
    app_common.Open django admin in firefox and app admin in chromium    ${URL_DJANGO_ADMIN}    ${URL_ADMIN}
    # Now in Chromium, so switch to Firefox for Django admin operations
    Switch Browser    ${BROWSER_ADMIN_SIDE}

    login.Login django admin
    ...    ${DJANGO_ADMIN_FIRST_NAME}
    ...    ${DJANGO_ADMIN_PASSWORD}

    Log    Django admin changes permissions for admin user to notification manager
    django_admin.Admin navigates to general role page
    django_admin.Admin searches the user by email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin clicks first user
    django_admin.Admin changes permissions    ${ADMIN_ROLE_NOTIFICATION_MANAGER}
    django_admin.Admin saves changes

    # Switch to Chromium browser for app admin checks
    Switch Browser    ${BROWSER_USER_SIDE}
    Log    Checking permissions
    app_common.Permission target admin logs in with suomi_fi
    app_admin.Admin checks top navigation for notification manager

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #

    Log    Django admin changes permissions to viewer
    django_admin.Admin searches the user by email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin clicks first user
    django_admin.Admin changes permissions    ${ADMIN_ROLE_VIEWER}
    django_admin.Admin saves changes
    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload page
    #
    Log    Checking permissions
    app_admin.Admin checks top navigation for viewer
    app_admin.Admin navigates to own units and selects unit group    ${UNIT_LOCATION}
    app_admin.Admin checks that reservation cannot be made

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #

    Log    Django admin changes permissions to reserver
    django_admin.Admin searches the user by email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin clicks first user
    django_admin.Admin changes permissions    ${ADMIN_ROLE_RESERVER}
    django_admin.Admin saves changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload page
    #
    Log    Checking permissions
    app_admin.Admin checks top navigation for reserver
    app_admin.Admin clicks make reservation and checks dialog opens
    admin_reservations.Admin closes dialog modal

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #
    Log    Django admin changes permissions to handler
    django_admin.Admin searches the user by email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin clicks first user
    django_admin.Admin changes permissions    ${ADMIN_ROLE_HANDLER}
    django_admin.Admin saves changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload page
    #
    Log    Checking permissions
    app_admin.Admin checks top navigation for handler
    app_admin.Admin clicks make reservation and checks dialog opens
    admin_reservations.Admin closes dialog modal

    #
    Switch Browser    ${BROWSER_ADMIN_SIDE}
    #
    Log    Django admin changes permissions to admin
    django_admin.Admin searches the user by email    ${PERMISSION_TARGET_ADMIN_EMAIL}
    django_admin.Admin clicks first user
    django_admin.Admin changes permissions    ${ADMIN_ROLE_ADMIN}
    django_admin.Admin saves changes

    #
    Switch Browser    ${BROWSER_USER_SIDE}
    app_common.Reload page
    #
    Log    Checking permissions
    app_admin.Admin checks top navigation for admin
    app_admin.Admin clicks make reservation and checks dialog opens
    admin_reservations.Admin closes dialog modal
