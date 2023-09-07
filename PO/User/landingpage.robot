*** Settings ***
Documentation       A resource file with variables.


*** Variables ***
###
# DEV ENVIROMENTS #
###

${URL_TEST}                 https://tilavaraus.test.hel.ninja/
${URL_STAGE}                https://tilavaraus.stage.hel.ninja/
${URL_PROD}                 https://tilavaraus.hel.fi/
###
# ${BROWSER}    chrome    #firefox    #ie

###
# USERS #
###
${DELAY}                    0
${VALID_USER_EMAIL}         anna-liisa.sallinen@vrk.fi
${VALID_USER_HETU}          010675-9981
${VALID_USER_PASSWORD}      eiolevielä
${INVALID_USER}             in.valid@q-factory.fi
${INVALID_PASSWORD}         invalid12345
${INVALID_USER_HETU}        123321-1211
###
