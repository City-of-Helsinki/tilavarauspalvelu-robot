*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/../PO/App/app_common.robot
Resource            ${CURDIR}/../PO/App/app_user.robot

Test Setup          User opens desktop browser to landing Page
Test Teardown       Run Keyword If Test Failed    Take Screenshot


*** Test Cases ***
# User logs in with suomi_fi
#    app_common.User logs in with suomi_fi

User can make a free single booking
    app_common.User logs in with suomi_fi
    app_user.User navigates to single booking page
    app_user.User uses search to find right unit
    app_user.User selects the time and fills the reservation info
    app_user.User checks the reservation info is right
