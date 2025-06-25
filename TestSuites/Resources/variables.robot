*** Settings ***
Documentation       A resource file with variables.

Library             Browser
# TODO add examples to EMPTY


*** Variables ***
###
# DEV ENVIRONMENTS
###
${URL_TEST}                                             https://varaamo.test.hel.ninja/
${URL_STAGE}                                            https://varaamo.test.hel.ninja/kasittely
${URL_PROD}                                             https://tilavaraus.hel.fi/
${URL_ADMIN}                                            https://tilavaraus.test.hel.ninja/kasittely
${URL_MAIL}                                             https://www.google.com/intl/fi/gmail/about/

# System
${DOWNLOAD_DIR}                                         ${CURDIR}${/}downloads
${EMAIL_FILE_PATH}                                      ${CURDIR}${/}downloads${/}cleaned_emails.json
###
#
###

###
# CALENDAR
###

# Calendar ICS info
${DOWNLOAD_ICS_FILE}                                    ${CURDIR}${/}downloads
${ICS_TEXT}                                             ${EMPTY}
${START_TIME_FROM_ICS}                                  ${EMPTY}
${END_TIME_FROM_ICS}                                    ${EMPTY}
${ICS_TEXT_FROM_FILE}                                   ${EMPTY}
#
${ENGLISH_DAY}                                          ${EMPTY}    # Monday
${CALENDAR_TIMESLOT}                                    ${EMPTY}    # 17:30-18:30

###
#
###

###
# UNITS
##
${ALWAYS_FREE_UNIT}                                     Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA)
${ALWAYS_FREE_UNIT_WITH_UNIT_LOCATION}                  Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

${UNIT_REQUIRES_ALWAYS_HANDLING}                        Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA)
${UNIT_REQUIRES_ALWAYS_HANDLING_WITH_UNIT_LOCATION}     Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

${UNIT_WITH_ACCESS_CODE}                                Ovikoodi maksuton käsiteltävä (AUTOMAATIOTESTI ÄLÄ POISTA)
${UNIT_WITH_ACCESS_CODE_WITH_UNIT_LOCATION}             Ovikoodi maksuton käsiteltävä (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

${FREE_UNIT_NO_CANCEL}                                  Perumiskelvoton parveke, maksuton (AUTOMAATIOTESTI ÄLÄ POISTA)
${FREE_UNIT_NO_CANCEL_WITH_UNIT_LOCATION}               Perumiskelvoton parveke, maksuton (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

${ALWAYS_PAID_UNIT}                                     Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA)
${ALWAYS_PAID_UNIT_WITH_UNIT_LOCATION}                  Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju
${ALWAYS_PAID_UNIT_SUBVENTED}                           Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA)
${ALWAYS_PAID_UNIT_SUBVENTED_WITH_UNIT_LOCATION}        Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

${UNAVAILABLE_UNIT}                                     Aina varattu yksikkö (AUTOMAATIOTESTI ÄLÄ POISTA)
${UNAVAILABLE_UNIT_WITH_UNIT_LOCATION}                  Aina varattu yksikkö (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

${RECURRING_UNIT_MALMI}                                 KAUSIVARAUS yksikkö Malmi (AUTOMAATIOTESTI ÄLÄ POISTA)
${RECURRING_UNIT_KESKUSTA}                              KAUSIVARAUS yksikkö Keskusta (AUTOMAATIOTESTI ÄLÄ POISTA)

${UNIT_LOCATION}                                        Harakka, piilokoju

###
# RECURRING RESERVATIONS
###

# Recurring reservation time slot selectors
${RECURRING_THU_22_23_OTHER}                            css=[aria-label="Ei merkitty kausivarattavaksi: To 22 - 23"]
${RECURRING_THU_23_24_OTHER}                            css=[aria-label="Ei merkitty kausivarattavaksi: To 23 - 24"]
${RECURRING_THU_09_10_PREFERRED}                        css=[aria-label="Varattavissa: To 9 - 10"]
${RECURRING_THU_10_11_PREFERRED}                        css=[aria-label="Varattavissa: To 10 - 11"]

###
#
###

###
# RESERVATIONS INFO
##

${QUICK_RESERVATION_DURATION}                           60 min
${TIME_OF_QUICK_RESERVATION_FREE_SLOT}                  ${EMPTY}
${TIME_OF_QUICK_RESERVATION}                            ${EMPTY}
${TIME_OF_QUICK_RESERVATION_MINUS_T}                    ${EMPTY}
${TIME_OF_QUICK_RESERVATION_MODIFIED}                   ${EMPTY}
${TIME_OF_RESERVATION_FOR_MAIL_TEST}                    ${EMPTY}
${TIME_OF_QUICK_RESERVATION_MINUS_T_MODIFIED}           ${EMPTY}
${ADMIN_MODIFIES_TIME_OF_INFO_CARD}                     ${EMPTY}
${ADMIN_MODIFIES_TIME_OF_INFO_CARD_MINUS_T}             ${EMPTY}
${CALENDAR_CONTROL_TIME_OF_FREE_SLOT}                   ${EMPTY}
${FORMATTED_ICS_START}                                  ${EMPTY}
${FORMATTED_ICS_END}                                    ${EMPTY}
${RESERVATION_TIME_EMAIL_RECEIPT}                       ${EMPTY}

# This is formatted with keyword, Formats info of subvented reservation to admin side
${RESERVATION_TAGLINE}                                  ${EMPTY}    # Ke 10.4.2024 klo 17:15-18:15, 1 t Alennuskelpoinen aula, Caisa

# Admin side
${MODIFIED_DATE_SUBVENTED_RESERVATION}                  ${EMPTY}
${MODIFIED_HOUR_STARTTIME_SUBVENTED_RESERVATION}        ${EMPTY}
${MODIFIED_HOUR_ENDTIME_SUBVENTED_RESERVATION}          ${EMPTY}

# These are used in - Admin creates all types of reservations and verifies no unavailable reservations exist
${UNAVAILABLE_RESERVATION_DATE}                         ${EMPTY}
${UNAVAILABLE_RESERVATION_HOUR_STARTTIME}               ${EMPTY}
${UNAVAILABLE_RESERVATION_HOUR_ENDTIME}                 ${EMPTY}

${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}              ${EMPTY}
${BOOKING_NUM_ONLY}                                     ${EMPTY}
${NUMBER_OF_RESERVATION_FOR_MAIL_TEST}                  ${EMPTY}

###
#
###

###
# RESERVATIONS TYPE INFO
###

${RESERVATION_INDIVIDUAL}                               id=reserveeType__individual
${RESERVATION_NONPROFIT}                                id=reserveeType__nonprofit
${RESERVATION_BUSINESS}                                 id=reserveeType__business

###
#
###

###
# BOOKINGS LIST
##

${RESERVATION_CARD}                                     [data-testid="reservation-card__container"]
${RESERVATION_CARDNAME}                                 [data-testid="reservation-card__name"]

###
#
###

###
# NOTIFICATIONS
###
${NOTIFICATION_ACTIVE_UNTIL}                            ${EMPTY}    # 12.2.2024
${NOTIFICATION_TYPE_NORMAL}                             [class*="Notification-module_notification__"]
${NOTIFICATION_TYPE_ERROR}                              [class*="Notification-module_error___"]
${NOTIFICATION_TYPE_WARNING}                            [class*="Notification-module_alert__"]
#
${NOTIFICATION_BANNER_MESSAGE_NAME}                     ${EMPTY}    # Normaali (sininen) + random value h5
${NOTIFICATION_BANNER_MESSAGE_TEXT_FI}                  ${EMPTY}    # Normaali (sininen) + random value Z6

###
#
###

###
# PAGES
##
${PAGE1}                                                ${EMPTY}
${PAGE_ADMIN_SIDE}                                      ${EMPTY}
${PAGE_USER_SIDE}                                       ${EMPTY}
###
#
###

###
# MAIL
###

# DEVNOTE If True, skips email verification during automated tests.
# This is set in the end of test --> User can make paid single booking
${MAIL_TEST_TRIGGER}                                    True

${ATTACHMENT_FILENAME}                                  asiointipalvelun-ehdot.pdf
${FORMATTED_STARTTIME_EMAIL}                            ${EMPTY}    # Alkamisaika: ${day}.${month}.${year} klo ${start_time}
${FORMATTED_ENDTIME_EMAIL}                              ${EMPTY}    # Päättymisaika: ${day}.${month}.${year} klo ${end_time}
${DOWNLOAD_TERMS_OF_USE_FILE}                           ${CURDIR}${/}downloads/asiointipalvelun-ehdot.pdf
${EXPECTED_ATTACHMENT_STATUS}                           ${True}

###
#
###
