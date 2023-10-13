*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../Common/topNav.robot
Resource    ../../Resources/texts_FI.robot
Resource    ../User/quick_reservation.robot
Resource    ../User/reservation_unit_reserver_info.robot
Resource    ../User/reservation_unit_reserver_types.robot
Resource    ../User/reservation_unit_booking_details.robot
Resource    ../User/reservation_unit_reservation_receipt.robot
Resource    ../User/reservation_lownav.robot
Resource    ../User/singlebooking.robot
Library     Dialogs


*** Keywords ***
User navigates to single booking page
    topNav.Navigate to single booking page    ${SINGLEBOOKING_BUTTON_TEXT}

User uses search to find right unit
    [Arguments]    ${nameoftheunit}
    singlebooking.Search units by name    ${nameoftheunit}
    singlebooking.Click searched unit    ${nameoftheunit}

User selects the time with quick reservation
    quick_reservation.Select duration    ${QUICK_RESERVATION_DURATION}
    quick_reservation.Click the second free slot

User fills the reservation info
    reservation_unit_reserver_info.Enter first name    ${BASIC_USER_MALE_FIRSTNAME}
    reservation_unit_reserver_info.Enter last name    ${BASIC_USER_MALE_LASTNAME}
    reservation_unit_reserver_info.Enter email    ${BASIC_USER_MALE_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${BASIC_USER_MALE_PHONE}
    quick_reservation.Check the quick reservation time
    reservation_lownav.Click submit button continue

User fills free booking details as indivual
    reservation_unit_booking_details.Type the name of the booking    ${SINGLEBOOKING_NAME}
    reservation_unit_booking_details.Select the purpose of the booking    ${PURPOSE_OF_THE_BOOKING}
    reservation_unit_booking_details.Select the number of participants    ${SINGLEBOOKING_NUMBER_OF_PERSONS}
    reservation_unit_booking_details.Type the description of the booking    ${SINGLEBOOKING_DESCRIPTION}
    reservation_unit_booking_details.Click the apply for free of charge
    reservation_unit_booking_details.Type justification for free of charge    ${JUSTIFICATION_FOR_FREE_OF_CHARGE}
    reservation_unit_reserver_types.Select reserver Type    ${RESERVATION_INDIVIDUAL}
    reservation_unit_reserver_info.Enter first name    ${BASIC_USER_MALE_FIRSTNAME}
    reservation_unit_reserver_info.Enter last name    ${BASIC_USER_MALE_LASTNAME}
    reservation_unit_reserver_info.Enter email    ${BASIC_USER_MALE_EMAIL}
    reservation_unit_reserver_info.Enter phone number    ${BASIC_USER_MALE_PHONE}
    reservation_unit_reserver_info.Select home city    ${HOME_CITY}
    quick_reservation.Check the quick reservation time
    reservation_lownav.Click submit button continue

User checks the free single booking details are right
    reservation_unit_reservation_receipt.Check single free booking info
    reservation_unit_reservation_receipt.Check users reservation info
    quick_reservation.Check the price of quick reservation
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    reservation_lownav.Click submit button continue
    quick_reservation.Check the quick reservation time
    quick_reservation.Check the price of quick reservation
    reservation_unit_reservation_receipt.Check the reservation status message
    ...    ${RESERVATION_STATUS_REQUIRESHANDLING_MSG_FI}

User checks the reservation info is right
    reservation_unit_reservation_receipt.Check users reservation info
    reservation_unit_reservation_receipt.Click the checkbox accepted terms
    reservation_unit_reservation_receipt.Click the checkbox generic terms
    reservation_lownav.Click submit button continue
    quick_reservation.Check the quick reservation time
    reservation_unit_reservation_receipt.Check the reservation status message    ${RESERVATION_STATUS_MSG_FI}

###
### MOBILE
###

User navigates to single booking page mobile
    topNav.Navigate to single booking page mobile

User uses search to find right unit mobile
    [Arguments]    ${nameoftheunit}
    singlebooking.Click show more filters mobile
    singlebooking.Search units by name mobile    ${nameoftheunit}
    singlebooking.Click searched unit mobile    ${nameoftheunit}

User selects the time with quick reservation mobile
    quick_reservation.Select duration mobile    ${QUICK_RESERVATION_DURATION}
    quick_reservation.Click the second free slot mobile
