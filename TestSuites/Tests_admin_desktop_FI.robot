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
    [Tags]    smoke
    common_setups_teardowns.Complete Admin Desktop Test Setup
    app_common.Admin logs in with suomi_fi
    app_common.Admin logs out

Admin verifies all reservation types and verifies no unavailable reservations exist
    common_setups_teardowns.Complete Admin Desktop Test Setup
    Admin logs in with suomi_fi
    app_admin.Admin navigates to own units and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for behalf
    # TODO: old version for using calendar UI
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for closed
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for staff
    app_admin.Admin opens make reservation modal and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    # TODO remove reservations part

Admin checks permissions
    # TODO make variable about john.actor, also backend changes to create data
    app_common.Admin navigates to django admin
    login.Login django admin
    ...    ${ADMIN_CURRENT_USER_USERNAME}
    ...    ${ADMIN_CURRENT_USER_PASSWORD}

    Log    Admin changes permissions to notification manager
    django_admin.Admin searches the user by email    ${CURRENT_USER_EMAIL}
    django_admin.Admin clicks user link by partial email    john.actor
    django_admin.Admin changes permissions    ${ADMIN_ROLE_NOTIFICATION_MANAGER}
    django_admin.Admin saves changes

    #
    app_common.open new window from admin side to user side and saves both windows    ${URL_ADMIN}

    Log    Checking permissions
    app_admin.Admin checks top navigation for notification manager

    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #

    Log    Admin changes permissions to viewer
    django_admin.Admin searches the user by email    ${CURRENT_USER_EMAIL}
    django_admin.Admin clicks user link by partial email    john.actor
    django_admin.Admin changes permissions    ${ADMIN_ROLE_VIEWER}
    django_admin.Admin saves changes

    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload page
    #
    Log    Checking permissions
    app_admin.Admin checks top navigation for viewer
    app_admin.Admin navigates to own units and selects unit    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin checks that reservation cannot be made
    # TODO check that harakka calendar does not open by clicking it
    # also that "tee varaus button is not shown

    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #

    Log    Admin changes permissions to reserver
    django_admin.Admin searches the user by email    ${CURRENT_USER_EMAIL}
    django_admin.Admin clicks user link by partial email    john.actor
    django_admin.Admin changes permissions    ${ADMIN_ROLE_RESERVER}
    django_admin.Admin saves changes

    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload page
    #
    Log    Checking permissions
    app_admin.Admin checks top navigation for reserver
    app_admin.Admin clicks make reservation and checks dialog opens
    admin_reservations.Admin closes dialog modal
    # TODO to check that all toimipisteet are visible.
    # This needs more back end changes to create data

    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes permissions to handler
    django_admin.Admin searches the user by email    ${CURRENT_USER_EMAIL}
    django_admin.Admin clicks user link by partial email    john.actor
    django_admin.Admin changes permissions    ${ADMIN_ROLE_HANDLER}
    django_admin.Admin saves changes

    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload page
    #
    Log    Checking permissions
    app_admin.Admin checks top navigation for handler
    app_admin.Admin clicks make reservation and checks dialog opens
    admin_reservations.Admin closes dialog modal
    # TODO check that harakka calendar opens by clicking it
    # also that "tee varaus button is shown
    #

    #
    Switch Page    ${PAGE_ADMIN_SIDE}
    #
    Log    Admin changes permissions to admin
    django_admin.Admin searches the user by email    ${CURRENT_USER_EMAIL}
    django_admin.Admin clicks user link by partial email    john.actor
    django_admin.Admin changes permissions    ${ADMIN_ROLE_ADMIN}
    django_admin.Admin saves changes

    #
    Switch Page    ${PAGE_USER_SIDE}
    app_common.Reload page
    #
    Log    Checking permissions
    app_admin.Admin checks top navigation for admin
    app_admin.Admin clicks make reservation and checks dialog opens
    admin_reservations.Admin closes dialog modal
    # TODO check that harakka calendar opens by clicking it
    # also that "tee varaus button is shown
