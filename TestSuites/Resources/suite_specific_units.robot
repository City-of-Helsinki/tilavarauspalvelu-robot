*** Settings ***
Documentation       Suite-specific units for parallel test execution


*** Variables ***
###
# DESKTOP USER SUITE UNITS
###
${DESKTOP_ALWAYS_FREE_UNIT}                                 Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA)
${DESKTOP_ALWAYS_FREE_UNIT_WITH_LOCATION}                   Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju
${DESKTOP_ALWAYS_PAID_UNIT}                                 Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA)
${DESKTOP_ALWAYS_PAID_UNIT_WITH_LOCATION}                   Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju
${DESKTOP_ALWAYS_PAID_UNIT_SUBVENTED}                       Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA)
${DESKTOP_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}         Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju
${DESKTOP_FREE_UNIT_NO_CANCEL}                              Perumiskelvoton parveke, maksuton (AUTOMAATIOTESTI ÄLÄ POISTA)
${DESKTOP_FREE_UNIT_NO_CANCEL_WITH_LOCATION}                Perumiskelvoton parveke, maksuton (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju
${DESKTOP_UNIT_WITH_ACCESS_CODE}                            Ovikoodi maksuton käsiteltävä (AUTOMAATIOTESTI ÄLÄ POISTA)
${DESKTOP_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}              Ovikoodi maksuton käsiteltävä (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

###
# ADMIN SUITE UNITS
###
${DESKTOP_UNAVAILABLE_UNIT}                                 Aina varattu yksikkö (AUTOMAATIOTESTI ÄLÄ POISTA)
${DESKTOP_UNAVAILABLE_UNIT_WITH_LOCATION}                   Aina varattu yksikkö (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

###
# ADMIN SUITE UNITS
###
# ${ADMIN_UNIT_REQUIRES_ALWAYS_HANDLING}    Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA)
# ${ADMIN_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}    Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju
# ${ADMIN_ALWAYS_PAID_UNIT_SUBVENTED}    Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA)
# ${ADMIN_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}    Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

###
# USERS+ADMIN SUITE UNITS
###
${COMBINED_ALWAYS_PAID_UNIT_SUBVENTED}                      Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA)
${COMBINED_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}        Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju
${COMBINED_UNIT_REQUIRES_ALWAYS_HANDLING}                   Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA)
${COMBINED_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}     Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju

###
# MOBILE ANDROID SUITE UNITS
###
${ANDROID_ALWAYS_FREE_UNIT}                                 Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA) (android)
${ANDROID_ALWAYS_FREE_UNIT_WITH_LOCATION}                   Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA) (android), Harakka, piilokoju
${ANDROID_ALWAYS_PAID_UNIT}                                 Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA) (android)
${ANDROID_ALWAYS_PAID_UNIT_WITH_LOCATION}                   Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA) (android), Harakka, piilokoju
${ANDROID_UNIT_WITH_ACCESS_CODE}                            Ovikoodi maksuton käsiteltävä (AUTOMAATIOTESTI ÄLÄ POISTA) (android)
${ANDROID_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}              Ovikoodi maksuton käsiteltävä (AUTOMAATIOTESTI ÄLÄ POISTA) (android), Harakka, piilokoju
${ANDROID_ALWAYS_PAID_UNIT_SUBVENTED}                       Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA) (android)
${ANDROID_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}         Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA) (android), Harakka, piilokoju
${ANDROID_UNIT_REQUIRES_ALWAYS_HANDLING}                    Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA) (android)
${ANDROID_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}      Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA) (android), Harakka, piilokoju

###
# MOBILE IPHONE SUITE UNITS
###
${IPHONE_ALWAYS_FREE_UNIT}                                  Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone)
${IPHONE_ALWAYS_FREE_UNIT_WITH_LOCATION}                    Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone), Harakka, piilokoju
${IPHONE_ALWAYS_PAID_UNIT}                                  Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone)
${IPHONE_ALWAYS_PAID_UNIT_WITH_LOCATION}                    Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone), Harakka, piilokoju
${IPHONE_UNIT_WITH_ACCESS_CODE}                             Ovikoodi maksuton käsiteltävä (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone)
${IPHONE_UNIT_WITH_ACCESS_CODE_WITH_LOCATION}               Ovikoodi maksuton käsiteltävä (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone), Harakka, piilokoju
${IPHONE_ALWAYS_PAID_UNIT_SUBVENTED}                        Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone)
${IPHONE_ALWAYS_PAID_UNIT_SUBVENTED_WITH_LOCATION}          Alennuskelpoinen aula (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone), Harakka, piilokoju
${IPHONE_UNIT_REQUIRES_ALWAYS_HANDLING}                     Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone)
${IPHONE_UNIT_REQUIRES_ALWAYS_HANDLING_WITH_LOCATION}       Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA) (iphone), Harakka, piilokoju
