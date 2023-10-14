*** Settings ***
Documentation       Desktop browser tests

Resource            ${CURDIR}/PO/App/app_common.robot
Resource            ${CURDIR}/PO/App/app_user.robot

Test Setup          User opens desktop browser to landing Page
Test Teardown       Run Keyword If Test Failed    Take Screenshot


*** Test Cases ***
User logs in with suomi_fi
    app_common.User logs in with suomi_fi

# User can make free single booking
 #    app_common.User logs in with suomi_fi
    #    app_user.User navigates to single booking page
    # app_user.User uses search to find right unit    ${ALLWAYS_FREE_UNIT}
    # app_user.User selects the time with quick reservation
    # app_user.User fills the reservation info
    # app_user.User checks the reservation info is right

# User can make free single booking that requires handling
 #    app_common.User logs in with suomi_fi
    #    app_user.User navigates to single booking page
    # app_user.User uses search to find right unit    ${ALLWAYS_FREE_UNIT_REQUIRES_HANDLING}
    # app_user.User selects the time with quick reservation
    # app_user.User fills free booking details as indivual
    # app_user.User checks the free single booking details are right
