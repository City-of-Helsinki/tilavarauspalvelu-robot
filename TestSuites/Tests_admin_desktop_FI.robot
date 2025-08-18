*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_common.robot
Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_navigation_menu.robot

Test Setup          Admin opens desktop browser to landing page
Test Teardown       Run Keyword If Test Failed    Take Screenshot


*** Test Cases ***
Admin logs in with suomi_fi
    [Tags]    smoke
    app_common.Admin logs in with suomi_fi
    app_common.Admin logs out

Admin verifies all reservation types and verifies no unavailable reservations exist
    Admin logs in with suomi_fi
    app_admin.Admin navigates to own units and selects unit    ${UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for behalf
    app_admin.Admin opens make reservation modal and selects unit    ${UNAVAILABLE_UNIT}
    # TODO: old version for using calendar UI
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    app_admin.Admin opens make reservation modal and selects unit    ${UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for closed
    app_admin.Admin opens make reservation modal and selects unit    ${UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    app_admin.Admin opens make reservation modal and selects unit    ${UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for staff
    app_admin.Admin opens make reservation modal and selects unit    ${UNAVAILABLE_UNIT}
    # admin_my_units.Admin clicks calendar open in own units    ${CURRENT_UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    # TODO remove reservations part
