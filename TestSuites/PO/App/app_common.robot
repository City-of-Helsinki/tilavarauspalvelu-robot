*** Settings ***
Resource    ../../Resources/devices.robot
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Resource    ../../Resources/texts_FI.robot
Resource    ../User/user_landingpage.robot
Resource    ../Common/topNav.robot
Resource    ../Common/login.robot


*** Keywords ***
###
# TEST SET UP
# Desktop - iPhone - Android
# LANGUAGE FI
###
User opens desktop browser to landing Page
    # Default is chrome
    devices.Set up chromium desktop browser and open url    ${URL_TEST}
    # topNav.Select language    ${SELECTED_LANGUAGE}
    user_landingpage.Checks the user landing page H1    ${USER_LANDING_PAGE_H1_TEXT}

User opens iphone webkit to landing Page
    devices.Set up iphone 13 and open url    ${URL_TEST}
    user_landingpage.Checks the user landing page H1    ${USER_LANDING_PAGE_H1_TEXT}

User opens android chrome to landing Page
    devices.Set up android pixel 5 and open url    ${URL_TEST}
    user_landingpage.Checks the user landing page H1    ${USER_LANDING_PAGE_H1_TEXT}

###
# END OF TEST SET UP
###

User logs in with suomi_fi
    # topNav.Select language    ${SELECTED_LANGUAGE}
    topNav.Click login    ${LOGIN_TEXT}
    login.Login Suomi_fi    ${BASIC_USER_MALE_HETU}
    user_landingpage.Checks the user landing page H1    ${USER_LANDING_PAGE_H1_TEXT}
    Sleep    3s
    topNav.Check dropdown menu has user info    ${BASIC_USER_MALE_FULLNAME}
###

User logs in with suomi_fi mobile
    topNav.Click navigation menu mobile
    topNav.Click login    ${LOGIN_TEXT}
    login.Login Suomi_fi mobile    ${BASIC_USER_MALE_HETU}
    user_landingpage.Checks the user landing page H1    ${USER_LANDING_PAGE_H1_TEXT}
    Sleep    3s
    topNav.Check menu has user info mobile    ${BASIC_USER_MALE_FULLNAME}    ${BASIC_USER_MALE_EMAIL}
