*** Settings ***
Documentation       A resource file with Users.


*** Variables ***
###############################################################################
#    DYNAMIC CURRENT USER VARIABLES (set during test execution)    #
###############################################################################

# Regular user variables (set by Select Unique User For Test)
${CURRENT_USER_EMAIL}                       ${EMPTY}
${CURRENT_USER_HETU}                        ${EMPTY}
${CURRENT_USER_PHONE}                       ${EMPTY}
${CURRENT_USER_FIRST_NAME}                  ${EMPTY}
${CURRENT_USER_LAST_NAME}                   ${EMPTY}
${CURRENT_PASSWORD}                         ${EMPTY}

# Admin user variables (set by Select Suite Specific Admin User)
${ADMIN_CURRENT_USER_EMAIL}                 ${EMPTY}
${ADMIN_CURRENT_USER_HETU}                  ${EMPTY}
${ADMIN_CURRENT_USER_FIRST_NAME}            ${EMPTY}
${ADMIN_CURRENT_USER_LAST_NAME}             ${EMPTY}

###############################################################################
#    USERS    #
#    ASIAKKAAT    #
#    #
#    USER DISTRIBUTION BY TEST SUITE:    #
#    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    #
#    🖥️    Desktop Users (0-11):    Tests_user_desktop_FI.robot    #
#    🔧 Admin Desktop Users (12-13): Tests_admin_desktop_FI.robot    #
#    👥 Combined Users (14-19):    Tests_users_with_admin_desktop.robot    #
#    📱 Android Users (20-24):    Tests_user_mobile_android_FI.robot    #
#    📱 iPhone Users (25-30):    Tests_user_mobile_iphone_FI.robot    #
#    👨‍💼 Admin Users:    All test suites (superusers)    #
###############################################################################

###############################################################################
#    DESKTOP USERS (0-11)    #
#    Tests_user_desktop_FI.robot    #
###############################################################################

# INFO
# qfaksi+tabitah@gmail.com alternative gmail

# USER 0 (Index 0): Ande AutomaatioTesteri - Male
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User logs in and out with suomi_fi"
${BASIC_USER_MALE_EMAIL}                    qfaksi+ande@gmail.com
${BASIC_USER_MALE_HETU}                     180674-907T
${BASIC_USER_MALE_PHONE}                    +35840123654
${BASIC_USER_MALE_FIRSTNAME}                Ande
${BASIC_USER_MALE_LASTNAME}                 AutomaatioTesteri
${BASIC_USER_MALE_FULLNAME}                 ${BASIC_USER_MALE_FIRSTNAME} ${BASIC_USER_MALE_LASTNAME}
${BASIC_USER_MALE_PASSWORD}                 AutomaatioTesteri

# DEVNOTE: Registered user information
# Ande AutomaatioTesteri (User 0 in parallel testing)
# Sex: Male
# Date of birth: 18.06.1974
# Age: 49

# USER 1 (Index 1): Mikael Virtanen - Male
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User can make free single booking and modifies it"
${DESKTOP_USER_MALE_EMAIL}                  qfaksi+mikael@gmail.com
${DESKTOP_USER_MALE_HETU}                   150382-901W
${DESKTOP_USER_MALE_PHONE}                  +35840123655
${DESKTOP_USER_MALE_FIRSTNAME}              Mikael
${DESKTOP_USER_MALE_LASTNAME}               Virtanen
${DESKTOP_USER_MALE_FULLNAME}               ${DESKTOP_USER_MALE_FIRSTNAME} ${DESKTOP_USER_MALE_LASTNAME}
${DESKTOP_USER_MALE_PASSWORD}               Virtanen

# USER 2 (Index 2): Jukka Korhonen - Male
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User can create non-cancelable booking"
${DESKTOP_USER_MALE2_EMAIL}                 qfaksi+jukka@gmail.com
${DESKTOP_USER_MALE2_HETU}                  220990-903Y
${DESKTOP_USER_MALE2_PHONE}                 +35840123656
${DESKTOP_USER_MALE2_FIRSTNAME}             Jukka
${DESKTOP_USER_MALE2_LASTNAME}              Korhonen
${DESKTOP_USER_MALE2_FULLNAME}              ${DESKTOP_USER_MALE2_FIRSTNAME} ${DESKTOP_USER_MALE2_LASTNAME}
${DESKTOP_USER_MALE2_PASSWORD}              Korhonen

# USER 3 (Index 3): Petri Mäkinen - Male
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User can make paid single booking with interrupted checkout"
${DESKTOP_USER_MALE3_EMAIL}                 qfaksi+petri@gmail.com
${DESKTOP_USER_MALE3_HETU}                  070785-905A
${DESKTOP_USER_MALE3_PHONE}                 +35840123657
${DESKTOP_USER_MALE3_FIRSTNAME}             Petri
${DESKTOP_USER_MALE3_LASTNAME}              Mäkinen
${DESKTOP_USER_MALE3_FULLNAME}              ${DESKTOP_USER_MALE3_FIRSTNAME} ${DESKTOP_USER_MALE3_LASTNAME}
${DESKTOP_USER_MALE3_PASSWORD}              Makinen

# USER 4 (Index 4): Antti Nieminen - Male
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User can make paid single booking"
${DESKTOP_USER_MALE4_EMAIL}                 qfaksi+antti@gmail.com
${DESKTOP_USER_MALE4_HETU}                  111276-907U
${DESKTOP_USER_MALE4_PHONE}                 +35840123658
${DESKTOP_USER_MALE4_FIRSTNAME}             Antti
${DESKTOP_USER_MALE4_LASTNAME}              Nieminen
${DESKTOP_USER_MALE4_FULLNAME}              ${DESKTOP_USER_MALE4_FIRSTNAME} ${DESKTOP_USER_MALE4_LASTNAME}
${DESKTOP_USER_MALE4_PASSWORD}              Nieminen

# USER 5 (Index 5): Matti Mäkelä - Male
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User can make subvented single booking that requires handling"
${DESKTOP_USER_MALE5_EMAIL}                 qfaksi+matti@gmail.com
${DESKTOP_USER_MALE5_HETU}                  040689-907H
${DESKTOP_USER_MALE5_PHONE}                 +35840123659
${DESKTOP_USER_MALE5_FIRSTNAME}             Matti
${DESKTOP_USER_MALE5_LASTNAME}              Mäkelä
${DESKTOP_USER_MALE5_FULLNAME}              ${DESKTOP_USER_MALE5_FIRSTNAME} ${DESKTOP_USER_MALE5_LASTNAME}
${DESKTOP_USER_MALE5_PASSWORD}              Mäkelä

# USER 6 (Index 6): Tabitah Testitar - Female
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User can make reservation with access code"
${DESKTOP_USER_FEM_EMAIL}                   qfaksi+tabitah@gmail.com
${DESKTOP_USER_FEM_HETU}                    090481-9386
${DESKTOP_USER_FEM_PHONE}                   +35840123653
${DESKTOP_USER_FEM_FIRSTNAME}               Tabitah
${DESKTOP_USER_FEM_LASTNAME}                Testitar
${DESKTOP_USER_FEM_FULLNAME}                ${DESKTOP_USER_FEM_FIRSTNAME} ${DESKTOP_USER_FEM_LASTNAME}
${DESKTOP_USER_FEM_PASSWORD}                Testitar

# DEVNOTE: Registered user information
# Tabitah Testitar (User 6 in parallel testing)
# Sex: Female
# Date of birth: 09.04.1981
# Age: 42

# USER 7 (Index 7): Sanna Hämäläinen - Female
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User checks that reserved time is not available anymore"
${DESKTOP_USER_FEM2_EMAIL}                  qfaksi+sanna@gmail.com
${DESKTOP_USER_FEM2_HETU}                   250592-934X
${DESKTOP_USER_FEM2_PHONE}                  +35840123660
${DESKTOP_USER_FEM2_FIRSTNAME}              Sanna
${DESKTOP_USER_FEM2_LASTNAME}               Hämäläinen
${DESKTOP_USER_FEM2_FULLNAME}               ${DESKTOP_USER_FEM2_FIRSTNAME} ${DESKTOP_USER_FEM2_LASTNAME}
${DESKTOP_USER_FEM2_PASSWORD}               Hämäläinen

# USER 8 (Index 8): Elina Laine - Female
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User checks that there are not current dates in the past bookings"
${DESKTOP_USER_FEM3_EMAIL}                  qfaksi+elina@gmail.com
${DESKTOP_USER_FEM3_HETU}                   131188-936A
${DESKTOP_USER_FEM3_PHONE}                  +35840123661
${DESKTOP_USER_FEM3_FIRSTNAME}              Elina
${DESKTOP_USER_FEM3_LASTNAME}               Laine
${DESKTOP_USER_FEM3_FULLNAME}               ${DESKTOP_USER_FEM3_FIRSTNAME} ${DESKTOP_USER_FEM3_LASTNAME}
${DESKTOP_USER_FEM3_PASSWORD}               Laine

# USER 9 (Index 9): Kirsi Heikkinen - Female
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User can make free single booking and check info from downloaded calendar file"
${DESKTOP_USER_FEM4_EMAIL}                  qfaksi+kirsi@gmail.com
${DESKTOP_USER_FEM4_HETU}                   030679-938F
${DESKTOP_USER_FEM4_PHONE}                  +35840123662
${DESKTOP_USER_FEM4_FIRSTNAME}              Kirsi
${DESKTOP_USER_FEM4_LASTNAME}               Heikkinen
${DESKTOP_USER_FEM4_FULLNAME}               ${DESKTOP_USER_FEM4_FIRSTNAME} ${DESKTOP_USER_FEM4_LASTNAME}
${DESKTOP_USER_FEM4_PASSWORD}               Heikkinen

# USER 10 (Index 10): Marja Koskinen - Female
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "Check emails from reservations"
${DESKTOP_USER_FEM5_EMAIL}                  qfaksi+marja@gmail.com
${DESKTOP_USER_FEM5_HETU}                   290384-932W
${DESKTOP_USER_FEM5_PHONE}                  +35840123663
${DESKTOP_USER_FEM5_FIRSTNAME}              Marja
${DESKTOP_USER_FEM5_LASTNAME}               Koskinen
${DESKTOP_USER_FEM5_FULLNAME}               ${DESKTOP_USER_FEM5_FIRSTNAME} ${DESKTOP_USER_FEM5_LASTNAME}
${DESKTOP_USER_FEM5_PASSWORD}               Koskinen

# USER 11 (Index 11): Tiina Järvinen - Female
# ASSIGNED TEST: Tests_user_desktop_FI.robot -> "User makes recurring reservation"
${DESKTOP_USER_FEM6_EMAIL}                  qfaksi+tiina@gmail.com
${DESKTOP_USER_FEM6_HETU}                   180293-934P
${DESKTOP_USER_FEM6_PHONE}                  +35840123664
${DESKTOP_USER_FEM6_FIRSTNAME}              Tiina
${DESKTOP_USER_FEM6_LASTNAME}               Järvinen
${DESKTOP_USER_FEM6_FULLNAME}               ${DESKTOP_USER_FEM6_FIRSTNAME} ${DESKTOP_USER_FEM6_LASTNAME}
${DESKTOP_USER_FEM6_PASSWORD}               Järvinen

###############################################################################
#    ADMIN DESKTOP USERS (12-13)    #
#    Tests_admin_desktop_FI.robot    #
###############################################################################

# USER 12 (Index 12): Ville Karjalainen - Male
# ASSIGNED TEST: Tests_admin_desktop_FI.robot -> "Admin user logs in"
${DESKTOP_USER_MALE12_EMAIL}                qfaksi+ville@gmail.com
${DESKTOP_USER_MALE12_HETU}                 150490-907R
${DESKTOP_USER_MALE12_PHONE}                +35840123665
${DESKTOP_USER_MALE12_FIRSTNAME}            Ville
${DESKTOP_USER_MALE12_LASTNAME}             Karjalainen
${DESKTOP_USER_MALE12_FULLNAME}             ${DESKTOP_USER_MALE12_FIRSTNAME} ${DESKTOP_USER_MALE12_LASTNAME}
${DESKTOP_USER_MALE12_PASSWORD}             Karjalainen

# USER 13 (Index 13): Seppo Lehtonen - Male
# ASSIGNED TEST: Tests_admin_desktop_FI.robot -> "Admin checks that manual handling booking is visible"
${DESKTOP_USER_MALE13_EMAIL}                qfaksi+seppo@gmail.com
${DESKTOP_USER_MALE13_HETU}                 280587-905K
${DESKTOP_USER_MALE13_PHONE}                +35840123666
${DESKTOP_USER_MALE13_FIRSTNAME}            Seppo
${DESKTOP_USER_MALE13_LASTNAME}             Lehtonen
${DESKTOP_USER_MALE13_FULLNAME}             ${DESKTOP_USER_MALE13_FIRSTNAME} ${DESKTOP_USER_MALE13_LASTNAME}
${DESKTOP_USER_MALE13_PASSWORD}             Lehtonen

###############################################################################
#    COMBINED USERS+ADMIN (14-19)    #
#    Tests_users_with_admin_desktop.robot    #
###############################################################################

# USER 14 (Index 14): Hannu Rantala - Male
# ASSIGNED TEST: Tests_users_with_admin_desktop.robot -> "User creates and Admin accepts single booking that requires handling"
${COMBINED_USER_MALE_EMAIL}                 qfaksi+hannu@gmail.com
${COMBINED_USER_MALE_HETU}                  101281-907D
${COMBINED_USER_MALE_PHONE}                 +35840123667
${COMBINED_USER_MALE_FIRSTNAME}             Hannu
${COMBINED_USER_MALE_LASTNAME}              Rantala
${COMBINED_USER_MALE_FULLNAME}              ${COMBINED_USER_MALE_FIRSTNAME} ${COMBINED_USER_MALE_LASTNAME}
${COMBINED_USER_MALE_PASSWORD}              Rantala

# USER 15 (Index 15): Risto Hakkarainen - Male
# ASSIGNED TEST: Tests_users_with_admin_desktop.robot -> "User creates and Admin declines single booking that requires handling"
${COMBINED_USER_MALE2_EMAIL}                qfaksi+risto@gmail.com
${COMBINED_USER_MALE2_HETU}                 051093-905L
${COMBINED_USER_MALE2_PHONE}                +35840123668
${COMBINED_USER_MALE2_FIRSTNAME}            Risto
${COMBINED_USER_MALE2_LASTNAME}             Hakkarainen
${COMBINED_USER_MALE2_FULLNAME}             ${COMBINED_USER_MALE2_FIRSTNAME} ${COMBINED_USER_MALE2_LASTNAME}
${COMBINED_USER_MALE2_PASSWORD}             Hakkarainen

# USER 16 (Index 16): Ari Laine - Male
# ASSIGNED TEST: Available for other tests
${COMBINED_USER_MALE3_EMAIL}                qfaksi+ari@gmail.com
${COMBINED_USER_MALE3_HETU}                 190684-907F
${COMBINED_USER_MALE3_PHONE}                +35840123669
${COMBINED_USER_MALE3_FIRSTNAME}            Ari
${COMBINED_USER_MALE3_LASTNAME}             Laine
${COMBINED_USER_MALE3_FULLNAME}             ${COMBINED_USER_MALE3_FIRSTNAME} ${COMBINED_USER_MALE3_LASTNAME}
${COMBINED_USER_MALE3_PASSWORD}             Laine

# USER 17 (Index 17): Timo Koivisto - Male
# ASSIGNED TEST: Available for other tests
${COMBINED_USER_MALE4_EMAIL}                qfaksi+timo@gmail.com
${COMBINED_USER_MALE4_HETU}                 220778-905M
${COMBINED_USER_MALE4_PHONE}                +35840123670
${COMBINED_USER_MALE4_FIRSTNAME}            Timo
${COMBINED_USER_MALE4_LASTNAME}             Koivisto
${COMBINED_USER_MALE4_FULLNAME}             ${COMBINED_USER_MALE4_FIRSTNAME} ${COMBINED_USER_MALE4_LASTNAME}
${COMBINED_USER_MALE4_PASSWORD}             Koivisto

# USER 18 (Index 18): Kari Salminen - Male
# ASSIGNED TEST: Available for other tests
${COMBINED_USER_MALE5_EMAIL}                qfaksi+kari@gmail.com
${COMBINED_USER_MALE5_HETU}                 091275-907P
${COMBINED_USER_MALE5_PHONE}                +35840123671
${COMBINED_USER_MALE5_FIRSTNAME}            Kari
${COMBINED_USER_MALE5_LASTNAME}             Salminen
${COMBINED_USER_MALE5_FULLNAME}             ${COMBINED_USER_MALE5_FIRSTNAME} ${COMBINED_USER_MALE5_LASTNAME}
${COMBINED_USER_MALE5_PASSWORD}             Salminen

# USER 19 (Index 19): Liisa Virtanen - Female
# ASSIGNED TEST: Available for other tests
${COMBINED_USER_FEM_EMAIL}                  qfaksi+liisa@gmail.com
${COMBINED_USER_FEM_HETU}                   130982-934K
${COMBINED_USER_FEM_PHONE}                  +35840123672
${COMBINED_USER_FEM_FIRSTNAME}              Liisa
${COMBINED_USER_FEM_LASTNAME}               Virtanen
${COMBINED_USER_FEM_FULLNAME}               ${COMBINED_USER_FEM_FIRSTNAME} ${COMBINED_USER_FEM_LASTNAME}
${COMBINED_USER_FEM_PASSWORD}               Virtanen

###############################################################################
#    ANDROID MOBILE USERS (20-24)    #
#    Tests_user_mobile_android_FI.robot    #
###############################################################################

# USER 20 (Index 20): Anna Korhonen - Female
# ASSIGNED TEST: Tests_user_mobile_android_FI.robot -> "User logs in and out with suomi_fi"
${ANDROID_USER_FEM_EMAIL}                   qfaksi+anna@gmail.com
${ANDROID_USER_FEM_HETU}                    050576-932R
${ANDROID_USER_FEM_PHONE}                   +35840123673
${ANDROID_USER_FEM_FIRSTNAME}               Anna
${ANDROID_USER_FEM_LASTNAME}                Korhonen
${ANDROID_USER_FEM_FULLNAME}                ${ANDROID_USER_FEM_FIRSTNAME} ${ANDROID_USER_FEM_LASTNAME}
${ANDROID_USER_FEM_PASSWORD}                Korhonen

# USER 21 (Index 21): Mari Leppänen - Female
# ASSIGNED TEST: Tests_user_mobile_android_FI.robot -> "User can make free single booking and modifies it"
${ANDROID_USER_FEM2_EMAIL}                  qfaksi+mari@gmail.com
${ANDROID_USER_FEM2_HETU}                   240189-938D
${ANDROID_USER_FEM2_PHONE}                  +35840123674
${ANDROID_USER_FEM2_FIRSTNAME}              Mari
${ANDROID_USER_FEM2_LASTNAME}               Leppänen
${ANDROID_USER_FEM2_FULLNAME}               ${ANDROID_USER_FEM2_FIRSTNAME} ${ANDROID_USER_FEM2_LASTNAME}
${ANDROID_USER_FEM2_PASSWORD}               Leppänen

# USER 22 (Index 22): Päivi Mustonen - Female
# ASSIGNED TEST: Tests_user_mobile_android_FI.robot -> "User can make paid single booking with interrupted checkout"
${ANDROID_USER_FEM3_EMAIL}                  qfaksi+paivi@gmail.com
${ANDROID_USER_FEM3_HETU}                   160691-936L
${ANDROID_USER_FEM3_PHONE}                  +35840123675
${ANDROID_USER_FEM3_FIRSTNAME}              Päivi
${ANDROID_USER_FEM3_LASTNAME}               Mustonen
${ANDROID_USER_FEM3_FULLNAME}               ${ANDROID_USER_FEM3_FIRSTNAME} ${ANDROID_USER_FEM3_LASTNAME}
${ANDROID_USER_FEM3_PASSWORD}               Mustonen

# USER 23 (Index 23): Kaisa Rantanen - Female
# ASSIGNED TEST: Tests_user_mobile_android_FI.robot -> "User can make paid single booking"
${ANDROID_USER_FEM4_EMAIL}                  qfaksi+kaisa@gmail.com
${ANDROID_USER_FEM4_HETU}                   121287-938M
${ANDROID_USER_FEM4_PHONE}                  +35840123676
${ANDROID_USER_FEM4_FIRSTNAME}              Kaisa
${ANDROID_USER_FEM4_LASTNAME}               Rantanen
${ANDROID_USER_FEM4_FULLNAME}               ${ANDROID_USER_FEM4_FIRSTNAME} ${ANDROID_USER_FEM4_LASTNAME}
${ANDROID_USER_FEM4_PASSWORD}               Rantanen

# USER 24 (Index 24): Ulla Hakala - Female
# ASSIGNED TEST: Tests_user_mobile_android_FI.robot -> "User can make booking that requires handling"
${ANDROID_USER_FEM5_EMAIL}                  qfaksi+ulla@gmail.com
${ANDROID_USER_FEM5_HETU}                   030888-932N
${ANDROID_USER_FEM5_PHONE}                  +35840123677
${ANDROID_USER_FEM5_FIRSTNAME}              Ulla
${ANDROID_USER_FEM5_LASTNAME}               Hakala
${ANDROID_USER_FEM5_FULLNAME}               ${ANDROID_USER_FEM5_FIRSTNAME} ${ANDROID_USER_FEM5_LASTNAME}
${ANDROID_USER_FEM5_PASSWORD}               Hakala

###############################################################################
#    IPHONE MOBILE USERS (25-30)    #
#    Tests_user_mobile_iphone_FI.robot    #
###############################################################################

# USER 25 (Index 25): Riitta Lindström - Female
# ASSIGNED TEST: Tests_user_mobile_iphone_FI.robot -> "User logs in and out with suomi_fi"
${IPHONE_USER_FEM_EMAIL}                    qfaksi+riitta@gmail.com
${IPHONE_USER_FEM_HETU}                     300474-932P
${IPHONE_USER_FEM_PHONE}                    +35840123678
${IPHONE_USER_FEM_FIRSTNAME}                Riitta
${IPHONE_USER_FEM_LASTNAME}                 Lindström
${IPHONE_USER_FEM_FULLNAME}                 ${IPHONE_USER_FEM_FIRSTNAME} ${IPHONE_USER_FEM_LASTNAME}
${IPHONE_USER_FEM_PASSWORD}                 Lindström

# USER 26 (Index 26): Tuula Aaltonen - Female
# ASSIGNED TEST: Tests_user_mobile_iphone_FI.robot -> "User can make free single booking and modifies it"
${IPHONE_USER_FEM2_EMAIL}                   qfaksi+tuula@gmail.com
${IPHONE_USER_FEM2_HETU}                    180685-934T
${IPHONE_USER_FEM2_PHONE}                   +35840123679
${IPHONE_USER_FEM2_FIRSTNAME}               Tuula
${IPHONE_USER_FEM2_LASTNAME}                Aaltonen
${IPHONE_USER_FEM2_FULLNAME}                ${IPHONE_USER_FEM2_FIRSTNAME} ${IPHONE_USER_FEM2_LASTNAME}
${IPHONE_USER_FEM2_PASSWORD}                Aaltonen

# USER 27 (Index 27): Helena Hiltunen - Female
# ASSIGNED TEST: Tests_user_mobile_iphone_FI.robot -> "User can make paid single booking"
${IPHONE_USER_FEM3_EMAIL}                   qfaksi+helena@gmail.com
${IPHONE_USER_FEM3_HETU}                    081184-938K
${IPHONE_USER_FEM3_PHONE}                   +35840123681
${IPHONE_USER_FEM3_FIRSTNAME}               Helena
${IPHONE_USER_FEM3_LASTNAME}                Hiltunen
${IPHONE_USER_FEM3_FULLNAME}                ${IPHONE_USER_FEM3_FIRSTNAME} ${IPHONE_USER_FEM3_LASTNAME}
${IPHONE_USER_FEM3_PASSWORD}                Hiltunen

# USER 28 (Index 28): Merja Kangas - Female
# ASSIGNED TEST: Tests_user_mobile_iphone_FI.robot -> "User can make paid single booking with interrupted checkout"
${IPHONE_USER_FEM4_EMAIL}                   qfaksi+merja@gmail.com
${IPHONE_USER_FEM4_HETU}                    250792-936H
${IPHONE_USER_FEM4_PHONE}                   +35840123680
${IPHONE_USER_FEM4_FIRSTNAME}               Merja
${IPHONE_USER_FEM4_LASTNAME}                Kangas
${IPHONE_USER_FEM4_FULLNAME}                ${IPHONE_USER_FEM4_FIRSTNAME} ${IPHONE_USER_FEM4_LASTNAME}
${IPHONE_USER_FEM4_PASSWORD}                Kangas

# USER 29 (Index 29): Seija Mäenpää - Female
# ASSIGNED TEST: Tests_user_mobile_iphone_FI.robot -> "User can make booking that requires handling"
${IPHONE_USER_FEM5_EMAIL}                   qfaksi+seija@gmail.com
${IPHONE_USER_FEM5_HETU}                    141279-932S
${IPHONE_USER_FEM5_PHONE}                   +35840123682
${IPHONE_USER_FEM5_FIRSTNAME}               Seija
${IPHONE_USER_FEM5_LASTNAME}                Mäenpää
${IPHONE_USER_FEM5_FULLNAME}                ${IPHONE_USER_FEM5_FIRSTNAME} ${IPHONE_USER_FEM5_LASTNAME}
${IPHONE_USER_FEM5_PASSWORD}                Mäenpää

# USER 30 (Index 30): Maija Peltonen - Female
# ASSIGNED TEST: Tests_user_mobile_iphone_FI.robot -> "User can make booking that requires handling"
${IPHONE_USER_FEM6_EMAIL}                   qfaksi+maija@gmail.com
${IPHONE_USER_FEM6_HETU}                    230986-934L
${IPHONE_USER_FEM6_PHONE}                   +35840123683
${IPHONE_USER_FEM6_FIRSTNAME}               Maija
${IPHONE_USER_FEM6_LASTNAME}                Peltonen
${IPHONE_USER_FEM6_FULLNAME}                ${IPHONE_USER_FEM6_FIRSTNAME} ${IPHONE_USER_FEM6_LASTNAME}
${IPHONE_USER_FEM6_PASSWORD}                Peltonen

# USER 31 (Index 31): Liisa Koivisto - Female
# ASSIGNED TEST: Tests_user_mobile_iphone_FI.robot -> "User can make subvented single booking that requires handling"
${IPHONE_USER_FEM7_EMAIL}                   qfaksi+liisa@gmail.com
${IPHONE_USER_FEM7_HETU}                    070591-934B
${IPHONE_USER_FEM7_PHONE}                   +35840123684
${IPHONE_USER_FEM7_FIRSTNAME}               Liisa
${IPHONE_USER_FEM7_LASTNAME}                Koivisto
${IPHONE_USER_FEM7_FULLNAME}                ${IPHONE_USER_FEM7_FIRSTNAME} ${IPHONE_USER_FEM7_LASTNAME}
${IPHONE_USER_FEM7_PASSWORD}                Koivisto

###############################################################################
#    ADMIN USERS    #
#    KÄSITTELIJÄT    #
###############################################################################

# ADMIN USER 1: TirehtööriPääkäytäjä Tötterstrom - Primary Admin
# ASSIGNED TESTS: "Admin logs in with suomi_fi", All notification tests, Fallback for unknown admin tests
# PÄÄKÄYTTÄJÄ
${BASIC_ADMIN_MALE_EMAIL}                   qfaksi+tirehtoori@gmail.com
${BASIC_ADMIN_MALE_HETU}                    120869-9332
${BASIC_ADMIN_MALE_FIRSTNAME}               Tirehtoori
${BASIC_ADMIN_MALE_LASTNAME}                Tötterstrom
${BASIC_ADMIN_MALE_FULLNAME}                ${BASIC_ADMIN_MALE_FIRSTNAME} ${BASIC_ADMIN_MALE_LASTNAME}
${BASIC_ADMIN_MALE_PASSWORD}                Tötterstrom

# DEVNOTE: Registered user information
# Tirehtööri-Pääkäyttäjä Tötterström
# Sex: Male
# Date of birth: 12.08.1969
# Age: 54

# DJANGO ADMIN USER: Kari Kekkonen - Django Admin for Permission Tests
# ASSIGNED TESTS: "Admin checks permissions", Single user mode fallback
# DJANGO PÄÄKÄYTTÄJÄ
${BASIC_DJANGO_ADMIN_EMAIL}                 qfaksi+kari@gmail.com
${BASIC_DJANGO_ADMIN_HETU}                  150875-9345
${BASIC_DJANGO_ADMIN_FIRSTNAME}             Kari
${BASIC_DJANGO_ADMIN_LASTNAME}              Kekkonen
${BASIC_DJANGO_ADMIN_FULLNAME}              ${BASIC_DJANGO_ADMIN_FIRSTNAME} ${BASIC_DJANGO_ADMIN_LASTNAME}
${BASIC_DJANGO_ADMIN_PASSWORD}              Kekkonen

# DEVNOTE: Registered user information
# Kari Kekkonen (Django Admin User)
# Sex: Male
# Date of birth: 15.08.1975
# Age: 48

# ADMIN USER 2: Seppo Korhonen - Accept Booking Admin
# ASSIGNED TEST: "Admin accepts single booking"
# PÄÄKÄYTTÄJÄ 2
${COMBINED_ADMIN_ALL_MALE3_EMAIL}           qfaksi+seppo@gmail.com
${COMBINED_ADMIN_ALL_MALE3_HETU}            280677-905Y
${COMBINED_ADMIN_ALL_MALE3_FIRSTNAME}       Seppo
${COMBINED_ADMIN_ALL_MALE3_LASTNAME}        Korhonen
${COMBINED_ADMIN_ALL_MALE3_FULLNAME}        ${COMBINED_ADMIN_ALL_MALE3_FIRSTNAME} ${COMBINED_ADMIN_ALL_MALE3_LASTNAME}
${COMBINED_ADMIN_ALL_MALE3_PASSWORD}        Korhonen

# DEVNOTE: Registered user information
# Seppo Korhonen (Admin User 2)
# Sex: Male
# Date of birth: 28.06.1977
# Age: 46

# ADMIN USER 3: Erkki Nieminen - Decline Booking Admin
# ASSIGNED TEST: "Admin declines single booking"
# PÄÄKÄYTTÄJÄ 3
${COMBINED_ADMIN_ALL_MALE4_EMAIL}           qfaksi+erkki@gmail.com
${COMBINED_ADMIN_ALL_MALE4_HETU}            141082-907K
${COMBINED_ADMIN_ALL_MALE4_FIRSTNAME}       Erkki
${COMBINED_ADMIN_ALL_MALE4_LASTNAME}        Nieminen
${COMBINED_ADMIN_ALL_MALE4_FULLNAME}        ${COMBINED_ADMIN_ALL_MALE4_FIRSTNAME} ${COMBINED_ADMIN_ALL_MALE4_LASTNAME}
${COMBINED_ADMIN_ALL_MALE4_PASSWORD}        Nieminen

# DEVNOTE: Registered user information
# Erkki Nieminen (Admin User 3)
# Sex: Male
# Date of birth: 14.10.1982
# Age: 41

# ADMIN USER 4: Antero Salonen - Available Admin
# ASSIGNED TEST: Available (not currently assigned to any specific test)
# PÄÄKÄYTTÄJÄ 4
${COMBINED_ADMIN_ALL_MALE6_EMAIL}           qfaksi+antero@gmail.com
${COMBINED_ADMIN_ALL_MALE6_HETU}            221175-907B
${COMBINED_ADMIN_ALL_MALE6_FIRSTNAME}       Antero
${COMBINED_ADMIN_ALL_MALE6_LASTNAME}        Salonen
${COMBINED_ADMIN_ALL_MALE6_FULLNAME}        ${COMBINED_ADMIN_ALL_MALE6_FIRSTNAME} ${COMBINED_ADMIN_ALL_MALE6_LASTNAME}
${COMBINED_ADMIN_ALL_MALE6_PASSWORD}        Salonen

# DEVNOTE: Registered user information
# Antero Salonen (Admin User 4)
# Sex: Male
# Date of birth: 22.11.1975
# Age: 48

###############################################################################
#    ADDITIONAL TEST USERS    #
#    Available for future tests    #
###############################################################################

# USER 32: Laura Virtanen - Female
# ASSIGNED TEST: Tests_users_with_admin_desktop.robot -> "Admin creates error notifications for both sides"
${COMBINED_USER_FEM_EMAIL}                  qfaksi+laura@gmail.com
${COMBINED_USER_FEM_HETU}                   250792-936P
${COMBINED_USER_FEM_PHONE}                  +35840123671
${COMBINED_USER_FEM_FIRSTNAME}              Laura
${COMBINED_USER_FEM_LASTNAME}               Virtanen
${COMBINED_USER_FEM_FULLNAME}               ${COMBINED_USER_FEM_FIRSTNAME} ${COMBINED_USER_FEM_LASTNAME}
${COMBINED_USER_FEM_PASSWORD}               Virtanen

# USER 33: Tiina Koskinen - Female
# ASSIGNED TEST: Tests_users_with_admin_desktop.robot -> "Admin creates notification and archive and deletes notification for both sides"
${COMBINED_USER_FEM2_EMAIL}                 qfaksi+tiina@gmail.com
${COMBINED_USER_FEM2_HETU}                  180494-938K
${COMBINED_USER_FEM2_PHONE}                 +35840123672
${COMBINED_USER_FEM2_FIRSTNAME}             Tiina
${COMBINED_USER_FEM2_LASTNAME}              Koskinen
${COMBINED_USER_FEM2_FULLNAME}              ${COMBINED_USER_FEM2_FIRSTNAME} ${COMBINED_USER_FEM2_LASTNAME}
${COMBINED_USER_FEM2_PASSWORD}              Koskinen

# ADMIN USER: Esa Mattila - Reservation Verification Admin
# ASSIGNED TEST: Available (previously used for admin verification, now available for future use)
# PÄÄKÄYTTÄJÄ
${ADMIN_ALL_MALE2_EMAIL}                    qfaksi+esa@gmail.com
${ADMIN_ALL_MALE2_HETU}                     050683-935N
${ADMIN_ALL_MALE2_FIRSTNAME}                Esa
${ADMIN_ALL_MALE2_LASTNAME}                 Mattila
${ADMIN_ALL_MALE2_FULLNAME}                 ${ADMIN_ALL_MALE2_FIRSTNAME} ${ADMIN_ALL_MALE2_LASTNAME}
${ADMIN_ALL_MALE2_PASSWORD}                 Mattila

# DEVNOTE: Registered user information
# Esa Mattila (Admin User)
# Sex: Male
# Date of birth: 05.06.1983
# Age: 40

# ADMIN USER: Hannu Rantala - Available Admin
# ASSIGNED TEST: Available (previously used for notifications, now available for future use)
# PÄÄKÄYTTÄJÄ
${COMBINED_ADMIN_ALL_MALE5_EMAIL}           qfaksi+hannu@gmail.com
${COMBINED_ADMIN_ALL_MALE5_HETU}            070590-905C
${COMBINED_ADMIN_ALL_MALE5_FIRSTNAME}       Hannu
${COMBINED_ADMIN_ALL_MALE5_LASTNAME}        Rantala
${COMBINED_ADMIN_ALL_MALE5_FULLNAME}        ${COMBINED_ADMIN_ALL_MALE5_FIRSTNAME} ${COMBINED_ADMIN_ALL_MALE5_LASTNAME}
${COMBINED_ADMIN_ALL_MALE5_PASSWORD}        Rantala

# DEVNOTE: Registered user information
# Hannu Rantala (Admin User)
# Sex: Male
# Date of birth: 07.05.1990
# Age: 33

# ADMIN USER: Matti Koskinen - Available Admin
# ASSIGNED TEST: Available (not currently assigned to any specific test)
# PÄÄKÄYTTÄJÄ
${COMBINED_ADMIN_ALL_MALE7_EMAIL}           qfaksi+matti@gmail.com
${COMBINED_ADMIN_ALL_MALE7_HETU}            090385-907F
${COMBINED_ADMIN_ALL_MALE7_FIRSTNAME}       Matti
${COMBINED_ADMIN_ALL_MALE7_LASTNAME}        Koskinen
${COMBINED_ADMIN_ALL_MALE7_FULLNAME}        ${COMBINED_ADMIN_ALL_MALE7_FIRSTNAME} ${COMBINED_ADMIN_ALL_MALE7_LASTNAME}
${COMBINED_ADMIN_ALL_MALE7_PASSWORD}        Koskinen

# DEVNOTE: Registered user information
# Matti Koskinen (Admin User)
# Sex: Male
# Date of birth: 09.03.1985
# Age: 38

# ADMIN USER: Marika Salminen - Permission Test Admin
# ASSIGNED TEST: "Admin checks permissions" - Admin whose permissions are being modified
# PÄÄKÄYTTÄJÄ
${PERMISSION_TEST_ADMIN_EMAIL}              qfaksi+marika@gmail.com
${PERMISSION_TEST_ADMIN_HETU}               140785-932R
${PERMISSION_TEST_ADMIN_PHONE}              +35840123669
${PERMISSION_TEST_ADMIN_FIRSTNAME}          Marika
${PERMISSION_TEST_ADMIN_LASTNAME}           Salminen
${PERMISSION_TEST_ADMIN_FULLNAME}           ${PERMISSION_TEST_ADMIN_FIRSTNAME} ${PERMISSION_TEST_ADMIN_LASTNAME}
${PERMISSION_TEST_ADMIN_PASSWORD}           Salminen

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
${USERMAIL_EMAIL}                           qfaksi@gmail.com

###############################################################################
#    END OF FILE    #
###############################################################################
