*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_common.robot
Resource            ${CURDIR}/PO/App/app_user.robot
Resource            ${CURDIR}/PO/App/app_admin.robot
Resource            ${CURDIR}/PO/Admin/admin_reservations.robot
Resource            ${CURDIR}/PO/Admin/admin_mainmenu.robot

Test Setup          Admin opens desktop browser to landing page
Test Teardown       Run Keyword If Test Failed    Take Screenshot


*** Test Cases ***
Admin logs in with suomi_fi
    app_common.Admin logs in with suomi_fi
    app_common.Admin logs out

Admin verifies all reservation types and verifies no unavailable reservations exist
    app_common.Admin logs in with suomi_fi
    app_admin.Admin navigates to own units and selects unit    ${UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for behalf
    admin_my_units.Admin clicks calendar open in own units    ${UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    admin_my_units.Admin clicks calendar open in own units    ${UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for closed
    admin_my_units.Admin clicks calendar open in own units    ${UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    admin_my_units.Admin clicks calendar open in own units    ${UNAVAILABLE_UNIT}
    app_admin.Admin makes reservation for staff
    admin_my_units.Admin clicks calendar open in own units    ${UNAVAILABLE_UNIT}
    app_admin.Admin attempts to make an unavailable reservation
    # TODO remove reservations part
