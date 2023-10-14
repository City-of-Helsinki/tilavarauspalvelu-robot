*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/users.robot


*** Keywords ***
Click login
    [Arguments]    ${Login_text}
    # Custom_keywords.Click element by role with text    button    ${Login_text}
    # DEVNOTE add datatest id
    Click    css=.NavigationUser-module_user__4HdTn

Check dropdown menu has user info
    [Arguments]    ${name}
    ${Topnav_Login_Button_Text}=    Get Text    css=#userDropdown-button
    Log    ${Topnav_Login_Button_Text}
    Log    ${BASIC_USER_MALE_FULLNAME}
    Should Be Equal    ${Topnav_Login_Button_Text}    ${name}

Navigate to single booking page
    # [Arguments]    ${single_booking_button_text}
    # DEVNOTE add datatest id
    # ${singlebookingbutton}=    Get Element By    text    ${single_booking_button_text}
    # Click    ${singlebookingbutton}
    Click    data-testid=navigation__reservationUnitSearch
###
# MOBILE UI
###

Click navigation menu mobile
    Click    css=button[aria-label="Menu"]

Click login mobile
    Click    id=hds-mobile-menu >> css=.NavigationUser-module_user__4HdTn

Check menu has user info mobile
    # DEVNOTE
    # Korjataan myöhemmin mobiili selectorit. Nyt löytyy 4 kpl kumpaakin
    [Arguments]    ${Expected_name}    ${Expected_email}
    Click navigation menu mobile
    ${Topnav_menu_name_elements}=    Get Elements    css=[data-testid="navigation-user-menu-user-card-name"]
    ${Topnav_menu_name_element_text}=    Get Text    ${Topnav_menu_name_elements}[1]
    Should Be Equal    ${Topnav_menu_name_element_text}    ${Expected_name}
#
    ${Topnav_menu_email_elements}=    Get Elements    css=[data-testid="navigation-user-menu-user-card-email"]
    ${Topnav_menu_email_element_text}=    Get Text    ${Topnav_menu_email_elements}[1]
    Should Be Equal    ${Topnav_menu_email_element_text}    ${Expected_email}

Navigate to single booking page mobile
    #    [Arguments]    ${single_booking_button_text}
    # DEVNOTE. Add datatest id here. and why dual clicks needed here
    # Click navigation menu mobile
    Click    css=button[aria-label="Menu"]
    Sleep    1s
    Click    css=button[aria-label="Menu"]

    Click    id=hds-mobile-menu >> css=[data-testid="navigation__reservationUnitSearch"]
