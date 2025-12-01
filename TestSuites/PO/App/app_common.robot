*** Settings ***
Resource    ../../Resources/devices.robot
Resource    ../../Resources/variables.robot
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/texts_FI.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../create_data.robot
Resource    ../User/user_landingpage.robot
Resource    ../Admin/admin_landingpage.robot
Resource    ../Common/topnav.robot
Resource    ../Common/login.robot
Resource    ../Common/popups.robot


*** Keywords ***
###
# USER TEST SET UP
# Desktop - iPhone - Android
# LANGUAGE FI
###

User Opens Desktop Browser To Django Admin
    # Default is chrome
    devices.Set Up Chromium Desktop Browser And Open Url    ${URL_DJANGO_ADMIN}    ${DOWNLOAD_DIR}
    Wait For Load State    load    timeout=15s
    # Check Text    h1    Ylläpito
    # h1 on Ylläpito
    # admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_NOT_LOGGED_IN}

User Opens Desktop Browser To Landing Page
    # Default is chrome

    devices.Set Up Chromium Desktop Browser And Open Url    ${URL_TEST}    ${DOWNLOAD_DIR}
    user_landingpage.Check The User Landing Page H1    ${USER_LANDING_PAGE_H1_TEXT}

User Opens Iphone Webkit To Landing Page
    devices.Set Up Iphone 14 And Open Url    ${URL_TEST}
    user_landingpage.Check The User Landing Page H1    ${USER_LANDING_PAGE_H1_TEXT}

User Opens Android Chrome To Landing Page
    devices.Set Up Android Pixel 5 And Open Url    ${URL_TEST}
    user_landingpage.Check The User Landing Page H1    ${USER_LANDING_PAGE_H1_TEXT}

User Opens Desktop Browser To Mail
    # Default is firefox
    devices.Set Up Firefox Desktop Browser And Open Url    ${URL_MAIL}    ${DOWNLOAD_DIR}

###
# END OF USER TEST SET UP
###

#
# USER
#

User Logs In With Suomi Fi
    topnav.Click Login
    login.Login Suomi Fi    ${CURRENT_USER_HETU}
    # Confirms we are on the landing page
    user_landingpage.Check The User Landing Page H1    ${USER_LANDING_PAGE_H1_TEXT}
    popups.User Accepts Cookies If Dialog Is Visible    ${COOKIETEXT}
    Log Current Cookies

User Checks Dropdown Menu Has User Info (NOT IN USE)
    [Documentation]    This information comes from tunnistamo and is not always available
    topnav.Check dropdown menu has user info    ${BASIC_USER_MALE_FULLNAME}

User Goes To Landing Page
    Go To    ${URL_TEST}

User Logs Out
    topnav.Click User Menu
    topnav.Click Logout
    Sleep    1s

User Confirms Log Out
    topnav.Click Login
    Sleep    1s

    # Confirms the logout was success
    Wait For Elements State    id=social-suomi_fi    visible

Verify Notification Banner Message
    [Arguments]    ${notification_banner_message}    ${notification_type}
    Wait For Elements State    section${notification_type}    visible    timeout=10s

    custom_keywords.Check Elements Text
    ...    section${notification_type}
    ...    ${notification_banner_message}

Verify Notification Banner Message Is Not Visible
    Wait For Elements State    [data-testid="BannerNotificationList__Notification"]    hidden    timeout=2s

###
# Mobile
###

User Logs Out Mobile
    topnav.Click Navigation Menu Mobile
    topnav.Click User Menu Mobile
    topnav.Click Logout Mobile
    Sleep    2s

User Confirms Log Out Mobile
    topnav.Click Navigation Menu Mobile
    topnav.Click Login Mobile

    # Confirms the logout was success
    Wait For Elements State    id=social-suomi_fi    visible

User Logs In With Suomi Fi Mobile
    topnav.Click Navigation Menu Mobile
    topnav.Click Login Mobile
    # login.Login Suomi_fi mobile    ${BASIC_USER_MALE_HETU}
    login.Login Suomi Fi Mobile    ${CURRENT_USER_HETU}

    # Confirms the login was success
    user_landingpage.Check The User Landing Page H1    ${USER_LANDING_PAGE_H1_TEXT}
    popups.User Accepts Cookies If Dialog Is Visible    ${COOKIETEXT}

    # Sleep    3s
    # TODO enable these steps when the dropdown has user info again
    # topnav.Check dropdown menu has user info    ${BASIC_USER_MALE_FULLNAME}

#
# END OF USER
#

###
# ADMIN TEST SET UP
# Desktop for now.
# LANGUAGE FI
###

Admin Opens Desktop Browser To Landing Page
    # Default is chrome
    # create_data.Create robot test data
    devices.Set Up Chromium Desktop Browser And Open Url    ${URL_ADMIN}    ${DOWNLOAD_DIR}
    admin_landingpage.Checks The Admin Landing Page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_NOT_LOGGED_IN}

Admin Goes To Landing Page
    Go To    ${URL_ADMIN}
    Wait For Load State    load    timeout=15s
    admin_landingpage.Checks The Admin Landing Page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_NOT_LOGGED_IN}

Admin Logs In With Suomi Fi
    topnav.Click Login Admin Side
    login.Login Suomi Fi    ${ADMIN_CURRENT_USER_HETU}
    admin_landingpage.Checks The Admin Landing Page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN_WITH_USER_INFO}
    # Wait For Elements State    id=user-menu    visible
    # TODO enable these steps when the dropdown has user info again
    # admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN}
    # Sleep    3s
    # topnav.Check dropdown menu has user info    ${BASIC_ADMIN_MALE_FULLNAME}

Permission Target Admin Logs In With Suomi Fi
    [Documentation]    Logs in the permission target admin (Marika Salminen) for permission tests
    ...    This is the admin whose permissions are being modified and verified
    topnav.Click Login Admin Side
    login.Login Suomi Fi    ${PERMISSION_TARGET_ADMIN_HETU}
    admin_landingpage.Checks The Admin Landing Page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN_WITH_USER_INFO}
    # Wait For Elements State    id=user-menu    visible
    # TODO enable these steps when the dropdown has user info again
    # admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_LOGGED_IN}
    # Sleep    3s
    # topnav.Check dropdown menu has user info    ${BASIC_ADMIN_MALE_FULLNAME}

Admin Logs Out
    topnav.Click User Menu
    topnav.Click Logout Admin Side
    # TODO enable these steps when the dropdown has user info again
    # custom_keywords.Check text of element with logging    p    ${USER_LOGOUT_TEXT}

Admin Opens Desktop Browser To Django Admin
    # Default is chrome
    devices.Set Up Chromium Desktop Browser And Open Url    ${URL_DJANGO_ADMIN}    ${DOWNLOAD_DIR}
    Wait For Load State    load    timeout=15s
    # Check Text    h1    Ylläpito
    # h1 on Ylläpito
    # admin_landingpage.Checks the admin landing page H1    ${ADMIN_LANDING_PAGE_H1_TEXT_NOT_LOGGED_IN}

Admin Navigates To Django Admin
    # Default is chrome
    Go To    ${URL_DJANGO_ADMIN}
    Wait For Load State    load    timeout=15s

###
# END OF ADMIN TEST SET UP
###

###
# SWITCH PAGE
###

Switch To New Tab From Current Page
    ${page1}=    Get Page Ids    ACTIVE    ACTIVE    ACTIVE
    Set Suite Variable    ${PAGE1}    ${page1}
    Log    ${PAGE1}
    Switch Page    NEW
    Wait For Load State    load    timeout=15s

Open New Window From Admin Side To User Side And Saves Both Windows
    [Arguments]    ${url}
    # Save the current page
    ${all_pages_before}=    Get Page Ids
    ${admin_id}=    Get From List    ${all_pages_before}    0
    Set Suite Variable    ${PAGE_ADMIN_SIDE}    ${admin_id}
    Log    Admin page handle is ${PAGE_ADMIN_SIDE}

    # Open the user side page in a brand new tab
    ${user_handle}=    New Page    ${url}
    Wait For Load State    load    timeout=15s

    # Save the new page
    Set Suite Variable    ${PAGE_USER_SIDE}    ${user_handle}
    Log    User page handle is ${PAGE_USER_SIDE}

Open Django Admin In Firefox And App Admin In Chromium
    [Documentation]    Sets up two separate browsers: Firefox for Django admin and Chromium for app admin
    [Arguments]    ${django_url}    ${app_url}

    # Set up Firefox browser for Django admin
    Log    🦊 Setting up Firefox browser for Django admin...
    devices.Set Up Firefox Desktop Browser And Open Url    ${django_url}    ${DOWNLOAD_DIR}

    # Get and save the Firefox browser ID
    ${firefox_browsers}=    Get Browser Ids    ACTIVE
    ${firefox_browser_id}=    Get From List    ${firefox_browsers}    0
    Set Suite Variable    ${BROWSER_ADMIN_SIDE}    ${firefox_browser_id}
    Log    Django admin (Firefox) browser ID is ${BROWSER_ADMIN_SIDE}

    # Set up Chromium browser for app admin
    Log    🌐 Setting up Chromium browser for app admin...
    devices.Set Up Chromium Desktop Browser And Open Url    ${app_url}    ${DOWNLOAD_DIR}

    # Get and save the Chromium browser ID
    ${chromium_browsers}=    Get Browser Ids    ACTIVE
    ${chromium_browser_id}=    Get From List    ${chromium_browsers}    0
    Set Suite Variable    ${BROWSER_USER_SIDE}    ${chromium_browser_id}
    Log    App admin (Chromium) browser ID is ${BROWSER_USER_SIDE}

    Log    ✅ Both browsers set up successfully

Reload Page
    Reload
    Sleep    1s
    Wait For Load State    networkidle    timeout=30s

###
# END OF SWITCH PAGE
###
