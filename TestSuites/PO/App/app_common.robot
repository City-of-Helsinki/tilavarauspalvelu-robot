*** Settings ***
Resource    ../../Resources/devices.robot
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Resource    ../../Resources/texts_FI.robot
Resource    ../User/user_landingpage.robot
Resource    ../Admin/admin_landingpage.robot
Resource    ../Common/topNav.robot
Resource    ../Common/login.robot
Resource    ../Common/popups.robot
Resource    ../../Resources/custom_keywords.robot


*** Keywords ***
###
# USER TEST SET UP
# Desktop - iPhone - Android
# LANGUAGE FI
###

User opens desktop browser to landing page
    # Default is chrome
    devices.Set up chromium desktop browser and open url    ${URL_TEST}    ${DOWNLOAD_DIR}
    user_landingpage.Check the user landing page h1    ${USER_LANDING_PAGE_H1_TEXT}

User opens iphone webkit to landing page
    devices.Set up iphone 14 and open url    ${URL_TEST}
    user_landingpage.Check the user landing page h1    ${USER_LANDING_PAGE_H1_TEXT}

User opens android chrome to landing page
    devices.Set up android pixel 5 and open url    ${URL_TEST}
    user_landingpage.Check the user landing page h1    ${USER_LANDING_PAGE_H1_TEXT}

User opens desktop browser to mail
    # Default is firefox
    devices.Set up firefox desktop browser and open url    ${URL_MAIL}    ${DOWNLOAD_DIR}

###
# END OF USER TEST SET UP
###

#
# USER
#

User logs in with suomi_fi
    topNav.Click login
    login.Login Suomi_fi    ${BASIC_USER_MALE_HETU}
    # Confirms we are on the landing page
    user_landingpage.Check the user landing page h1    ${USER_LANDING_PAGE_H1_TEXT}
    popups.User accepts cookies if dialog is visible    ${COOKIETEXT}

    Log    Enable dropdown menu has user info when the profile bug is fixed and name info is no longer empty

    # Confirms the user info is present
    # TODO enable these steps when the dropdown has user info again
    # topNav.Check dropdown menu has user info    ${BASIC_USER_MALE_FULLNAME}

User goes to landing Page
    Go To    ${URL_TEST}

User logs out
    topNav.Click user menu
    topNav.Click logout
    Sleep    1s

User confirms log out
    topNav.Click login
    Sleep    1s

    # Confirms the logout was success
    Wait For Elements State    id=social-suomi_fi    visible

###
# Mobile
###

User logs out mobile
    topNav.Click navigation menu mobile
    topNav.Click user menu mobile
    topNav.Click logout mobile
    Sleep    2s

User confirms log out mobile
    topNav.Click navigation menu mobile
    topNav.Click login mobile

    # Confirms the logout was success
    Wait For Elements State    id=social-suomi_fi    visible

User logs in with suomi_fi mobile
    topNav.Click navigation menu mobile
    topNav.Click login mobile
    login.Login Suomi_fi mobile    ${BASIC_USER_MALE_HETU}

    # Confirms the login was success
    user_landingpage.Check the user landing page h1    ${USER_LANDING_PAGE_H1_TEXT}
    popups.User accepts cookies if dialog is visible    ${COOKIETEXT}

    # Sleep    3s
    # TODO enable these steps when the dropdown has user info again
    # topNav.Check dropdown menu has user info    ${BASIC_USER_MALE_FULLNAME}

#
# END OF USER
#

###
# ADMIN TEST SET UP
# Desktop for now.
# LANGUAGE FI
###

Admin opens desktop browser to landing page
    # Default is chrome
    devices.Set up chromium desktop browser and open url    ${URL_ADMIN}    ${DOWNLOAD_DIR}
    admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT}

Admin goes to landing Page
    Go To    ${URL_ADMIN}
    Wait For Load State    load    timeout=15s
    admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT}

Admin logs in with suomi_fi
    topNav.Click login admin side
    login.Login Suomi_fi    ${ADMIN_ALL_MALE_HETU}
    Wait For Elements State    id=user-menu    visible
    # TODO enable these steps when the dropdown has user info again
    # admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN}
    # Sleep    3s
    # topNav.Check dropdown menu has user info    ${ADMIN_ALL_MALE_FULLNAME}

Admin logs out
    topNav.Click user menu
    topNav.Click logout admin side
    # TODO enable these steps when the dropdown has user info again
    # custom_keywords.Check text of element with logging    p    ${USER_LOGOUT_TEXT}

###
# END OF ADMIN TEST SET UP
###

Switch to new tab from current page
    ${page1}=    Get Page Ids    ACTIVE    ACTIVE    ACTIVE
    Set Suite Variable    ${PAGE1}    ${page1}
    Log    ${PAGE1}
    Switch Page    NEW
    Wait For Load State    load    timeout=15s
