*** Settings ***
Documentation       Shared fallback user data for serial/sequential execution.
...
...                 WHEN THESE USERS ARE USED:
...
...                 1. SEQUENTIAL/SERIAL EXECUTION (docker-test sequential mode):
...                 Command: robot --variable FORCE_SINGLE_USER:True TestSuites/Tests_*.robot
...                 Behavior: All tests share these hardcoded users
...
...                 2. AUTOMATIC FALLBACK:
...                 When pabot_users.dat value sets fail or PabotLib is unavailable
...                 Behavior: System automatically uses these shared users
...                 Use case: Error recovery, safety net
...
...                 NOTE: docker-test script implements TWO execution modes:
...                 - PARALLEL (pabot): Uses pabot_users.dat → unique users per test
...                 - SEQUENTIAL (robot): Uses THIS file → shared users for all tests


*** Variables ***
###############################################################################
#    DYNAMIC CURRENT USER VARIABLES (set during test execution)    #
###############################################################################

# Regular user variables (set by Select Unique User For Test)
${CURRENT_USER_EMAIL}                           ${EMPTY}
${CURRENT_USER_HETU}                            ${EMPTY}
${CURRENT_USER_PHONE}                           ${EMPTY}
${CURRENT_USER_FIRST_NAME}                      ${EMPTY}
${CURRENT_USER_LAST_NAME}                       ${EMPTY}
${CURRENT_PASSWORD}                             ${EMPTY}

# Admin user variables (set by Select Suite Specific Admin User)
${ADMIN_CURRENT_USER_EMAIL}                     ${EMPTY}
${ADMIN_CURRENT_USER_HETU}                      ${EMPTY}
${ADMIN_CURRENT_USER_FIRST_NAME}                ${EMPTY}
${ADMIN_CURRENT_USER_LAST_NAME}                 ${EMPTY}

# Permission test target admin variables (the admin whose permissions are being modified)
${PERMISSION_TARGET_ADMIN_EMAIL}                ${EMPTY}
${PERMISSION_TARGET_ADMIN_HETU}                 ${EMPTY}
${PERMISSION_TARGET_ADMIN_FIRST_NAME}           ${EMPTY}
${PERMISSION_TARGET_ADMIN_LAST_NAME}            ${EMPTY}
${PERMISSION_TARGET_ADMIN_FULLNAME}             ${EMPTY}

###############################################################################
#    DESKTOP USERS    #
#    tests_user_desktop_fi.robot    #
###############################################################################

# USER 0 (Index 0): Ande AutomaatioTesteri - Male
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User logs in and out with suomi_fi"
${BASIC_USER_MALE_EMAIL}                        django_email_robot@mailiposti.com    #qfaksi+ande@gmail.com
${BASIC_USER_MALE_HETU}                         180674-907T
${BASIC_USER_MALE_PHONE}                        +35840123654
${BASIC_USER_MALE_FIRSTNAME}                    Ande
${BASIC_USER_MALE_LASTNAME}                     AutomaatioTesteri
${BASIC_USER_MALE_FULLNAME}                     ${BASIC_USER_MALE_FIRSTNAME} ${BASIC_USER_MALE_LASTNAME}
${BASIC_USER_MALE_PASSWORD}                     AutomaatioTesteri

# DEVNOTE: Registered user information
# Ande AutomaatioTesteri (User 0 in parallel testing)
# Sex: Male
# Date of birth: 18.06.1974
# Age: 49

###############################################################################
#    ADMIN USERS    #
#    KÄSITTELIJÄT    #
###############################################################################

# ADMIN USER 1: TirehtööriPääkäytäjä Tötterstrom - Primary Admin
# ASSIGNED TESTS: "Admin logs in with suomi_fi", All notification tests, Fallback for unknown admin tests
# PÄÄKÄYTTÄJÄ
${BASIC_ADMIN_MALE_EMAIL}                       qfaksi+tirehtoori@gmail.com
${BASIC_ADMIN_MALE_HETU}                        120869-9332
${BASIC_ADMIN_MALE_FIRSTNAME}                   Tirehtoori
${BASIC_ADMIN_MALE_LASTNAME}                    Tötterstrom
${BASIC_ADMIN_MALE_FULLNAME}                    ${BASIC_ADMIN_MALE_FIRSTNAME} ${BASIC_ADMIN_MALE_LASTNAME}
${BASIC_ADMIN_MALE_PASSWORD}                    Tötterstrom

# DEVNOTE: Registered user information
# Tirehtööri-Pääkäyttäjä Tötterström
# Sex: Male
# Date of birth: 12.08.1969
# Age: 54

# DJANGO ADMIN USER: Kari Kekkonen - Django Admin for Permission Tests
# ASSIGNED TESTS: "Admin checks permissions", Single user mode fallback
# DJANGO PÄÄKÄYTTÄJÄ
# NOTE: Actual password is read from DJANGO_ADMIN_PASSWORD environment variable
${BASIC_DJANGO_ADMIN_EMAIL}                     qfaksi+kari@gmail.com
${BASIC_DJANGO_ADMIN_HETU}                      150875-9345
${BASIC_DJANGO_ADMIN_FIRSTNAME}                 Kari
${BASIC_DJANGO_ADMIN_LASTNAME}                  Kekkonen
${BASIC_DJANGO_ADMIN_FULLNAME}                  ${BASIC_DJANGO_ADMIN_FIRSTNAME} ${BASIC_DJANGO_ADMIN_LASTNAME}
${BASIC_DJANGO_ADMIN_PASSWORD}                  Kekkonen
${BASIC_DJANGO_ADMIN_DJANGO_USERNAME}           u-synoynteknhu5f4oky5komlxz4

# DEVNOTE: Registered user information
# Kari Kekkonen (Django Admin User)
# Sex: Male
# Date of birth: 15.08.1975
# Age: 48

# ADMIN USER: Marika Salminen - Permission Test Admin
# ASSIGNED TEST: "Admin checks permissions" - Admin whose permissions are being modified
# PÄÄKÄYTTÄJÄ
${BASIC_PERMISSION_TARGET_ADMIN_EMAIL}          qfaksi+marika@gmail.com
${BASIC_PERMISSION_TARGET_ADMIN_HETU}           140785-932R
${BASIC_PERMISSION_TARGET_ADMIN_PHONE}          +35840123669
${BASIC_PERMISSION_TARGET_ADMIN_FIRSTNAME}      Marika
${BASIC_PERMISSION_TARGET_ADMIN_LASTNAME}       Salminen
${BASIC_PERMISSION_TARGET_ADMIN_FULLNAME}       ${BASIC_PERMISSION_TARGET_ADMIN_FIRSTNAME} ${BASIC_PERMISSION_TARGET_ADMIN_LASTNAME}

# DEVNOTE: Registered user information
# Marika Salminen (Permission Test Admin)
# Sex: Female
# Date of birth: 14.07.1985
# Age: 38

###
#
###

###############################################################################
#    EMAIL CONFIG    #
###############################################################################

# Email client info
${USERMAIL_EMAIL}                               qfaksi@gmail.com

###############################################################################
#    END OF FILE    #
###############################################################################
