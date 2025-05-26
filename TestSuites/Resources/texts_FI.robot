*** Settings ***
Documentation       A resource file with all the finnish texts

Resource            users.robot


*** Variables ***
# TODO add placeholders for EMPTY

###
# USER LANDING PAGE
###

${USER_LANDING_PAGE_H1_TEXT}                                        Varaa tiloja ja laitteita
${LOGIN_TEXT}                                                       Kirjaudu
${SELECTED_LANGUAGE}                                                Suomeksi

###
#
###

###
# USER LOG OUT PAGE
###

${USER_LOGOUT_TEXT}                                                 You have been logged out of City of Helsinki services.

###
#
###

###
# ADMIN LANDING PAGE
###

${ADMIN_LANDING_PAGE_H1_TEXT_NOT_LOGGED_IN}                         Tilavarauskäsittely
${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN}                             Tervetuloa!
${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN_WITH_USER_INFO}              Tervetuloa, ${ADMIN_ALL_MALE_FIRSTNAME}
${LOGIN_TEXT_ADMIN}                                                 Kirjaudu sisään

###
#
###

###
# PAYMENT NOTIFICATION BANNER
###

${PAYMENT_NOTIFICATION_BANNER_TITLE}                                Varauksesi odottaa maksua

###
#
###

###
# NOTIFICATION BANNER
###

${NOTIFICATION_BANNER_MESSAGE_NORMAL}                               Normaali (sininen)
${NOTIFICATION_BANNER_MESSAGE_ERROR}                                Poikkeus (punainen)
${NOTIFICATION_BANNER_MESSAGE_WARNING}                              Varoitus (keltainen)

###
# NOTIFICATION BANNER TARGET GROUP
###

${NOTIFICATION_BANNER_TARGET_GROUP_ALL}                             Kaikki
${NOTIFICATION_BANNER_TARGET_GROUP_ADMIN}                           Henkilökunta
${NOTIFICATION_BANNER_TARGET_GROUP_USER}                            Asiakkaat
#
${DELETE_NOTIFICATION_BUTTON_TEXT}                                  Poista

###
#
###

###
# RESERVATION PAGE
###

${RESERVATION_STATUS_MSG_FI}                                        Varaus tehty!
${RESERVATION_STATUS_REQUIRESHANDLING_MSG_FI}                       Varaus käsittelyssä

###
# TOPNAV
###

${SINGLEBOOKING_BUTTON_TEXT}                                        Tilan varaus
${MYBOOKINGS_FI}                                                    Omat varaukset
${SINGLEBOOKING_FI}                                                 Tilan varaus

###
# SINGLE BOOKING
###

${SINGLEBOOKING_NAME}                                               Yksittäisvaraaja123
${SINGLEBOOKING_DESCRIPTION}                                        Yksittäisvaraaja varailee
${PURPOSE_OF_THE_BOOKING}                                           Muu toiminta
${JUSTIFICATION_FOR_FREE_OF_CHARGE}                                 En halua maksaa
${JUSTIFICATION_FOR_SUBVENTION}                                     Haluan alennusta -20
${HOME_CITY}                                                        Helsinki
${SINGLEBOOKING_NUMBER_OF_PERSONS}                                  1
${AGEGROUP_OF_PERSONS}                                              18 - 24
${SINGLEBOOKING_PAID_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}            Hinta: 40,00 € (sis. alv 25,5%)
${SINGLEBOOKING_PAID_PRICE_VAT_INCL}                                Hinta: 40,00 € (sis. alv 25,5%)
${SINGLEBOOKING_SUBVENTED_PRICE_NEEDS_TO_BE_HANDLED_VAT_INCL}       Hinta: 0 - 30,00 € (sis. alv 25,5%)
${ALWAYS_REQUESTED_UNIT_PAID_PRICE_VAT_INCL}                        Hinta: 40,00 € (sis. alv 25,5%)
${SINGLEBOOKING_NO_PAYMENT}                                         Hinta: Maksuton
${SINGLEBOOKING_PAID_PRICE_CHECKOUT}                                40€
${NUM_FROM_TXT}                                                     ${EMPTY}
${BOOKING_NUM_ONLY}                                                 ${EMPTY}
${RESERVATION_NUMBER_ADMINSIDE}                                     ${EMPTY}
${PAID_BOOKINGNUMBER_FOR_MAIL}                                      ${EMPTY}
${REASON_FOR_CANCELLATION}                                          En tarvitse varausta enää
${ACCESS_CODE_TXT_BY_CODE}                                          Pääsy tilaan: Ovikoodi

###
#
###

###
# SINGLE BOOKING STATUS
###

${MYBOOKINGS_H1}                                                    Omat varaukset
${MYBOOKINGS_STATUS_CONFIRMED}                                      Hyväksytty
${MYBOOKINGS_STATUS_REJECTED}                                       Hylätty
${MYBOOKINGS_STATUS_REFUNDED}                                       Maksu palautettu
${MYBOOKINGS_STATUS_PROCESSED}                                      Käsiteltävänä
${MYBOOKINGS_STATUS_CANCELED}                                       Varauksesi on peruttu!
${IN_RESERVATIONS_STATUS_CANCELED}                                  Peruttu
${MYBOOKINGS_STATUS_PAID_CONFIRMED}                                 Maksettu
${ADMIN_STATUS_PROCESSED}                                           Käsittelyssä

###
#
###

###
# ADMIN MAIN MENU
###
${REQUESTED_RESERVATIONS_FI}                                        Varaustoiveet

####
# ADMIN REQUESTED RESERVATION INFO
###

${SINGLEBOOKING_SUBVENTED_PRICE_ADMIN_SIDE}                         30,00 €, hakee subventiota
${SINGLEBOOKING_NO_PAYMENT_ADMIN_SIDE}                              maksuton, hakee subventiota
${SINGLEBOOKING_SUBVENTED_ADMIN_SIDE_AGE_GROUP}                     18-24 vuotiaat
${DEFAULT_PRICE_ALWAYS_REQUESTED_UNIT}                              40,00 €

###
#
###

###
# ADMIN RESERVATION PAGE
###

${CALENDAR_CHANGE_TIME_FI}                                          Muuta aikaa
${RESERVATIONS_BY_UNITS_FI}                                         Varausyksiköittäin
${PREFIX_RESERVATIONS_BY_ADMIN_BEHALF_FI}                           Puolesta|

# This is set in Admin fills reservation details behalf
${ADMIN_BEHALF_LASTNAME_FI}                                         ${EMPTY}
${ADMIN_BEHALF_FIRSTNAME_FI}                                        Puolesta
${ADMIN_BEHALF_PHONE_FI}                                            9876543210

# This is set in Admin fills reservation details behalf
${CALENDAR_EVENT_NAME}                                              ${EMPTY}

###
#
###

###
# ADMIN RESERVATION REJECTS RESERVATION
###

${ADMIN_REASON_REJECTED}                                            Varaus on peruttu pyynnöstäsi

###
#
###

###
# ADMIN INFO DIALOG
###
${RESERVATION_TIME_NOT_FREE}                                        Valitsemasi aika ei ole enää vapaana. Ole hyvä ja valitse uusi aika.
${RESERVATION_STATUS_DIALOG}                                        Palauta käsiteltäväksi

###
#
###

###
# EMAIL
###

${CONFIRMATION_AND_RECEIPT_TEXT_IN_MAIL}                            Tilausvahvistus ja kuitti
${CONFIRMATION_TEXT_IN_MAIL}                                        Olet tehnyt uuden varauksen.
${CANCELLATION_TEXT_IN_MAIL}                                        Varauksesi on peruttu
${CANCELLATION_AND_REFUND_TEXT_IN_MAIL}                             Vahvistus ja kuitti maksun palautuksesta

###
#
###

###
# COOKIES
###
${COOKIETEXT}                                                       Hyväksy vain välttämättömät evästeet
