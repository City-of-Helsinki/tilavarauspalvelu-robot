*** Settings ***
Documentation       A resource file with Users.


*** Variables ***
###
# USERS #
# Asiakkaat #
###
# ${VALID_USER_EMAIL}    anna-liisa.sallinen@vrk.fi
# ${VALID_USER_HETU}    010675-9981
# ${VALID_USER_PASSWORD}    eiolevielä
# ${INVALID_USER}    in.valid@q-factory.fi
# ${INVALID_PASSWORD}    invalid12345
# ${INVALID_USER_HETU}    123321-1211

${BASIC_USER_MALE_EMAIL}        qfaksi+ande@gmail.com
${BASIC_USER_MALE_HETU}         180674-907T
${BASIC_USER_MALE_PHONE}        +358 40 1236542
# ${BASIC_USER_MALE_PASSWORD}    ${EMPTY}
# ${BASIC_USER_ID}    ${EMPTY}
${BASIC_USER_MALE_FIRSTNAME}    Ande
${BASIC_USER_MALE_LASTNAME}     AutomaatioTesteri
${BASIC_USER_MALE_FULLNAME}=    ${BASIC_USER_MALE_FIRSTNAME} ${BASIC_USER_MALE_LASTNAME}

# Ande AutomaatioTesteri
# Sukupuoli: Mies
# Syntymäaika: 18.06.1974
# Ikä: 49
# Hetu 180674-907T

${BASIC_USER_FEM_EMAIL}         qfaksi+tabitah@gmail.com
${BASIC_USER_FEM_HETU}          090481-9386
# ${BASIC_USER_FEM_PASSWORD}    ${EMPTY}
# ${BASIC_USER_FEM_ID}    ${EMPTY}
${BASIC_USER_FEM_FIRSTNAME}     Tabitah
${BASIC_USER_FEM_LASTNAME}      Testitar
${BASIC_USER_FEM_FULLNAME}=     Catenate    SEPARATOR=    ${BASIC_USER_FEM_FIRSTNAME}    ${BASIC_USER_FEM_LASTNAME}

# Tabitah Testitar
# Henkilötunnus: 090481-9386
# Sukupuoli: Nainen
# Syntymäaika: 09.04.1981
# Ikä: 42
# qfaksi+tabitah@gmail.com
