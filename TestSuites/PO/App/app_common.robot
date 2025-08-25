*** Settings ***
Resource    ../../Resources/devices.robot
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Resource    ../../Resources/texts_FI.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../User/user_landingpage.robot
Resource    ../Admin/admin_landingpage.robot
Resource    ../Common/topNav.robot
Resource    ../Common/login.robot
Resource    ../Common/popups.robot


*** Keywords ***
###
# USER TEST SET UP
# Desktop - iPhone - Android
# LANGUAGE FI
###

User opens desktop browser to django admin
    # Default is chrome
    devices.Set up chromium desktop browser and open url    ${URL_DJANGO_ADMIN}    ${DOWNLOAD_DIR}
    Wait For Load State    load    timeout=15s
    # Check Text    h1    Ylläpito
    # h1 on Ylläpito
    # admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_NOT_LOGGED_IN}

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
    login.Login Suomi_fi    ${CURRENT_USER_HETU}
    # Confirms we are on the landing page
    user_landingpage.Check the user landing page h1    ${USER_LANDING_PAGE_H1_TEXT}
    popups.User accepts cookies if dialog is visible    ${COOKIETEXT}
    Log current cookies

    Log    Enable dropdown menu has user info when the profile bug is fixed and name info is no longer empty

    # Confirms the user info is present
    # TODO enable these steps when the dropdown has user info again
    # topNav.Check dropdown menu has user info    ${BASIC_USER_MALE_FULLNAME}

User goes to landing page
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

Verify notification banner message
    [Arguments]    ${notification_banner_message}    ${notification_type}
    Wait For Elements State    section${notification_type}    visible    timeout=10s

    custom_keywords.Check elements text
    ...    [data-testid="BannerNotificationList__Notification"]
    ...    ${notification_banner_message}

Verify notification banner message is not visible
    Wait For Elements State    [data-testid="BannerNotificationList__Notification"]    hidden    timeout=2s

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
    # login.Login Suomi_fi mobile    ${BASIC_USER_MALE_HETU}
    login.Login Suomi_fi mobile    ${CURRENT_USER_HETU}

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
    admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_NOT_LOGGED_IN}

Admin goes to landing page
    Go To    ${URL_ADMIN}
    Wait For Load State    load    timeout=15s
    admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_NOT_LOGGED_IN}

Admin logs in with suomi_fi
    topNav.Click login admin side
    login.Login Suomi_fi    ${ADMIN_CURRENT_USER_HETU}
    admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN_WITH_USER_INFO}
    # Wait For Elements State    id=user-menu    visible
    # TODO enable these steps when the dropdown has user info again
    # admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN}
    # Sleep    3s
    # topNav.Check dropdown menu has user info    ${BASIC_ADMIN_MALE_FULLNAME}

Admin logs out
    topNav.Click user menu
    topNav.Click logout admin side
    # TODO enable these steps when the dropdown has user info again
    # custom_keywords.Check text of element with logging    p    ${USER_LOGOUT_TEXT}

###
# END OF ADMIN TEST SET UP
###

###
# SWITCH PAGE
###

Switch to new tab from current page
    ${page1}=    Get Page Ids    ACTIVE    ACTIVE    ACTIVE
    Set Suite Variable    ${PAGE1}    ${page1}
    Log    ${PAGE1}
    Switch Page    NEW
    Wait For Load State    load    timeout=15s

Open new window from admin side to user side and saves both windows
    # Save the current page
    ${all_pages_before}=    Get Page Ids
    ${admin_id}=    Get From List    ${all_pages_before}    0
    Set Suite Variable    ${PAGE_ADMIN_SIDE}    ${admin_id}
    Log    Admin page handle is ${PAGE_ADMIN_SIDE}

    # Open the user side page in a brand new tab
    ${user_handle}=    New Page    ${URL_TEST}
    Wait For Load State    load    timeout=15s

    # Save the new page
    Set Suite Variable    ${PAGE_USER_SIDE}    ${user_handle}
    Log    User page handle is ${PAGE_USER_SIDE}

Reload page
    Reload
    Sleep    500ms
    Wait For Load State    networkidle    timeout=30s

###
# END OF SWITCH PAGE
###
