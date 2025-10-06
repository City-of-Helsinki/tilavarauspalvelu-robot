*** Settings ***
Documentation       Desktop browser tests for Admin functionality

Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot
Resource            ${CURDIR}/PO/Admin/admin_my_units.robot
Resource            ${CURDIR}/Resources/common_setups_teardowns.robot
Resource            ${CURDIR}/PO/Common/login.robot

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
