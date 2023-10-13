*** Settings ***
Documentation       A resource file with variables.


*** Variables ***
###
# DEV ENVIROMENTS #
###
${URL_TEST}                                 https://tilavaraus.test.hel.ninja/
${URL_STAGE}                                https://tilavaraus.stage.hel.ninja/
${URL_PROD}                                 https://tilavaraus.hel.fi/
# uuskirjautumisdummy    https://example-ui.dev.hel.ninja/

# Elements
${TIME_OF_SECOND_FREE_SLOT}                 ${EMPTY}

###
# UNITS
##
${ALLWAYS_FREE_UNIT}                        Maksuton Mankeli (AUTOMAATIOTESTI ÄLÄ POISTA)
${ALLWAYS_FREE_UNIT_REQUIRES_HANDLING}      Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA)

###
# RESERVATION UNIT
##
${QUICK_RESERVATION_DURATION}               1:00
${TIME_OF_QUICK_RESERVATION}                ${EMPTY}
${RESERVATION_INDIVIDUAL}                   css=[for="INDIVIDUAL"]
${RESERVATION_NONPROFIT}                    css=[for="NONPROFIT"]
${RESERVATION_BUSINESS}                     css=[for="BUSINESS"]
