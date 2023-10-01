*** Settings ***
Documentation       A resource file with variables.


*** Variables ***
###
# DEV ENVIROMENTS #
###
${URL_TEST}                         https://tilavaraus.test.hel.ninja/
${URL_STAGE}                        https://tilavaraus.stage.hel.ninja/
${URL_PROD}                         https://tilavaraus.hel.fi/
# uuskirjautumisdummy    https://example-ui.dev.hel.ninja/

# Elements
${MENU_ELEMENT_MOBILE}              NavigationUserMenuUserCard
${TIME_OF_SECOND_FREE_SLOT}         ${EMPTY}

###
# UNITS
##
${ALLWAYS_FREE_UNIT}                Maksuton Mankeli (Automaatiotestit ÄLÄ POISTA)

###
# RESERVATION UNIT
##
${QUICK_RESERVATION_DURATION}       1:00
${TIME_OF_QUICK_RESERVATION}        ${EMPTY}
