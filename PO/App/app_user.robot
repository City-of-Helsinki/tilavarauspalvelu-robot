*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../Common/topNav.robot
Resource    ../../Resources/texts_FI.robot
Resource    ../User/reservation_unit.robot
Resource    ../User/reservation_unit_reserver_info.robot
Resource    ../User/singlebooking.robot
Library     Dialogs


*** Keywords ***
User navigates to single booking page
    topNav.Navigate to single booking page    ${SINGLEBOOKING_BUTTON_TEXT}

User uses search to find right unit
    singlebooking.Search units by name    ${ALLWAYS_FREE_UNIT}
    singlebooking.Click searched unit    ${ALLWAYS_FREE_UNIT}

User selects the time and fills the reservation info
    reservation_unit.Quick reservation select duration    ${QUICK_RESERVATION_DURATION}
    reservation_unit.Quick reservation click the second free slot
    reservation_unit_reserver_info.Enter first name    ${BASIC_USER_MALE_FIRSTNAME}
    reservation_unit_reserver_info.Enter last name    ${BASIC_USER_MALE_LASTNAME}
    reservation_unit_reserver_info.Enter email    ${BASIC_USER_MALE_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${BASIC_USER_MALE_PHONE}
    reservation_unit_reserver_info.Check the quick reservation time
    reservation_unit_reserver_info.Click submit button continue
    reservation_unit_reserver_info.Click the checkbox accepted terms
    reservation_unit_reserver_info.Click the checkbox generic terms
    reservation_unit_reserver_info.Click submit button reservation

User checks the reservation info is right
    reservation_unit_reserver_info.Check the quick reservation time
    reservation_unit_reserver_info.Check the reservation status message    ${RESERVATION_STATUS_MSG_FI}

###
### MOBILE
###

User navigates to single booking page mobile
    topNav.Navigate to single booking page mobile
