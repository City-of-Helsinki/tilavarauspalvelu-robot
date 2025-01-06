*** Settings ***
Documentation       A resource file with Users.


*** Variables ***
###
# USERS #
# ASIAKKAAT #
###

${BASIC_USER_MALE_EMAIL}        qfaksi+ande@gmail.com
${BASIC_USER_MALE_HETU}         180674-907T
${BASIC_USER_MALE_PHONE}        +358 40 1236542
${BASIC_USER_MALE_FIRSTNAME}    Ande
${BASIC_USER_MALE_LASTNAME}     AutomaatioTesteri
${BASIC_USER_MALE_FULLNAME}=    ${BASIC_USER_MALE_FIRSTNAME} ${BASIC_USER_MALE_LASTNAME}

# DEVNOTE: Registered user information
# Ande AutomaatioTesteri
# Sex: Male
# Date of birth: 18.06.1974
# Age: 49

${BASIC_USER_FEM_EMAIL}         qfaksi+tabitah@gmail.com
${BASIC_USER_FEM_HETU}          090481-9386
${BASIC_USER_FEM_FIRSTNAME}     Tabitah
${BASIC_USER_FEM_LASTNAME}      Testitar
${BASIC_USER_FEM_FULLNAME}      ${BASIC_USER_FEM_FIRSTNAME} ${BASIC_USER_FEM_LASTNAME}

# DEVNOTE: Registered user information
# Tabitah Testitar
# Sex: Female
# Date of birth: 09.04.1981
# Age: 42

###
#
###

# ADMINS #
# KÄSITTELIJÄT #
###

# Admin with all the permits
# PÄÄKÄYTTÄJÄ
${ADMIN_ALL_MALE_EMAIL}         qfaksi+totterstrom@gmail.com
${ADMIN_ALL_MALE_HETU}          120869-9333
${ADMIN_ALL_MALE_FIRSTNAME}     TirehtööriPääkäytäjä
${ADMIN_ALL_MALE_LASTNAME}      Tötterstrom
${ADMIN_ALL_MALE_FULLNAME}      ${ADMIN_ALL_MALE_FIRSTNAME} ${ADMIN_ALL_MALE_LASTNAME}

# DEVNOTE: Registered user information
# Tirehtööri-Pääkäyttäjä Tötterström
# Sex: Male
# Date of birth: 12.08.1969
# Age: 54

###
#
###

# Email client info
${USERMAIL_EMAIL}               qfaksi@gmail.com
