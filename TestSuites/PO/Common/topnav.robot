*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot
Resource            ../User/mybookings.robot


*** Keywords ***
Click Login
    Wait For Elements State    id=login    stable
    Click    id=login
    Sleep    500ms

Click Login Admin Side
    Wait For Elements State    h1    visible
    Click    button >> span:text-is("${LOGIN_TEXT_ADMIN}") >> nth=-1
    Sleep    1s

Click Logout
    Sleep    1s
    Wait For Elements State    css=[aria-label="Kirjaudu ulos"]    stable
    Click    css=[aria-label="Kirjaudu ulos"]
    Sleep    3s    # wait for the page to load

Click Logout Admin Side
    Sleep    1s
    Wait For Elements State    css=[aria-label="signout"]    visible
    Click    css=[aria-label="signout"]
    Sleep    3s    # wait for the page to load

Click User Menu
    Wait For Elements State    id=user-menu    stable
    Click    id=user-menu
    Sleep    1s

Click Close Navigation Menu
    Wait For Elements State    id=Menu    stable
    Click    id=Menu
    Sleep    1s

Check Dropdown Menu Has User Info
    [Arguments]    ${name}
    # DEVNOTE Enable this when the profile bug no longer empties the name info
    ${Topnav_Login_Button_Text}=    Get Text    id=user-menu:text-is("${name}")
    Log    ${Topnav_Login_Button_Text}
    Log    ${name}
    Should Be Equal    ${Topnav_Login_Button_Text}    ${name}

Navigate To Single Booking Page
    Click    header >> [href="/search"]:text-is("${SINGLEBOOKING_FI}")
    Sleep    3s
    Wait For Load State    load    timeout=15s

Navigate To My Bookings
    Click    header >> [href="/reservations"]:text-is("${MYBOOKINGS_FI}")
    Sleep    4s

    # Confirms page is loaded
    mybookings.Check My Bookings H1    ${MYBOOKINGS_FI}

Navigate To Recurring Booking Page
    Click    header >> [href="/recurring"]:text-is("${RECURRING_BOOKINGS_FI}")
    Sleep    4s

Navigate To My Applications
    Click    header >> [href="/applications"]:text-is("${MYAPPLICATIONS_FI}")
    Sleep    4s

###
# MOBILE UI
###

Click Navigation Menu Mobile
    Wait For Elements State    id=Menu    visible
    Click    id=Menu
    Sleep    1s    # wait for animation to complete

Click User Menu Mobile
    Click    id=user-menu
    Sleep    1s    # wait for animation to complete

Click Login Mobile
    Wait For Elements State    id=login    visible
    Click    id=login
    Sleep    2s    # wait for the page to load
    Wait For Load State    load    timeout=15s

Click Logout Mobile
    Wait For Elements State    css=[aria-label="Kirjaudu ulos"]    visible
    Click    css=[aria-label="Kirjaudu ulos"]
    Sleep    2s    # wait for the page to load
    Wait For Load State    load    timeout=15s

Click Tablist Scroll Button To Right Mobile
    Wait For Elements State    [class*=Tabs-module_scrollButton__]    visible
    Click    [class*=Tabs-module_scrollButton__] >> [aria-label="angle-right"]
    Sleep    1.5s    # wait for the animation to complete
# Check menu has user info mobile
    # DEVNOTE - Waiting for fixes for the test environment from another team
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

Navigate To Single Booking Page Mobile
    Click    id=Menu
    Sleep    1s    # wait for animation to complete
    Click    header >> [href="/search"]:text-is("${SINGLEBOOKING_FI}")
    Sleep    3s
    Wait For Load State    load    timeout=15s

Navigate To My Bookings Mobile
    Click Navigation Menu Mobile
    Navigate To My Bookings
    Wait For Elements State    h1    visible
