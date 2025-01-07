*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/users.robot
Resource            ../User/mybookings.robot


*** Keywords ***
Click login
    Wait For Elements State    id=login    visible
    Click    id=login

Click login admin side
    Wait For Elements State    h1    visible
    ${LoginElement}=    Browser.Get Element    button >> span:text-is("${LOGIN_TEXT_ADMIN}")
    Click    ${LoginElement}

Click logout
    Sleep    1s
    Wait For Elements State    css=[aria-label="Kirjaudu ulos"]    visible
    Click    css=[aria-label="Kirjaudu ulos"]

Click logout admin side
    Sleep    1s
    Wait For Elements State    css=[aria-label="signout"]    visible
    Click    css=[aria-label="signout"]

Click user menu
    Wait For Elements State    id=user-menu    visible
    Click    id=user-menu
    Sleep    1s

Click close navigation menu
    Wait For Elements State    id=Menu    visible
    Click    id=Menu
    Sleep    1s

Check dropdown menu has user info
    [Arguments]    ${name}
    # DEVNOTE Enable this when the profile bug no longer empties the name info
    ${Topnav_Login_Button_Text}=    Get Text    id=user-menu >> span:text-is("${name}")
    Log    ${Topnav_Login_Button_Text}
    Log    ${name}
    Should Be Equal    ${Topnav_Login_Button_Text}    ${name}

Navigate to single booking page
    Click    header >> [href="/search"] >> span:text-is("${SINGLEBOOKING_FI}")
    Sleep    200ms
    Wait For Load State    Load    timeout=7s

Navigate to my bookings
    Click    header >> [href="/reservations"] >> span:text-is("${MYBOOKINGS_FI}")
    Sleep    1s
    Wait For Load State    domcontentloaded    timeout=5s

    # Confirms page is loaded
    mybookings.Check my bookings h1    ${MYBOOKINGS_FI}

###
# MOBILE UI
###

Click navigation menu mobile
    Click    css=button[aria-label="Menu"]
    Sleep    1s

Click user menu mobile
    Click    id=user-menu
    Sleep    1s

Click close navigation menu mobile
    Wait For Elements State    id=Menu    visible
    Click    id=Menu
    Sleep    1s

Click login mobile
    Wait For Elements State    id=login    visible
    Click    id=login

Click logout mobile
    Wait For Elements State    css=[aria-label="Kirjaudu ulos"]    visible
    Click    css=[aria-label="Kirjaudu ulos"]

Click tablist scroll button to right mobile
    Wait For Elements State    [class*=Tabs-module_scrollButton__]    visible
    Click    [class*=Tabs-module_scrollButton__] >> [aria-label="angle-right"]

# Check menu has user info mobile
    # DEVNOTE Commented out. Waiting for fixes for the test environment from another team
    # this step will be enabled when the test environment is fixed

    # TODO - 4 selectors of the same name in the ui. Fix better selector
    # [Arguments]    ${Expected_name}    ${Expected_email}
    # Click navigation menu mobile
    # id="user-menu"
    # ${Topnav_menu_name_elements}=    Browser.Get Elements    id=hds-mobile-menu >> [data-testid="navigation__user-name"]
    # ${Topnav_menu_name_element_text}=    Get Text    ${Topnav_menu_name_elements}[1]
    # Should Be Equal    ${Topnav_menu_name_element_text}    ${Expected_name}
#
    # ${Topnav_menu_email_element_text}=    Get Text    id=hds-mobile-menu >> [data-testid="navigation-user-email"]
    # ${Topnav_menu_email_elements}=    Browser.Get Elements    id=hds-mobile-menu >> [data-testid="navigation-user-email"]
    # ${Topnav_menu_email_element_text}=    Get Text    ${Topnav_menu_email_elements}[1]
    # Should Be Equal    ${Topnav_menu_email_element_text}    ${Expected_email}

Navigate to single booking page mobile
    Click    id=Menu
    Navigate to single booking page

Navigate to my bookings mobile
    Click navigation menu mobile
    Navigate to my bookings
    Wait For Elements State    h1    visible
