*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Library             Dialogs
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/users.robot


*** Keywords ***
Click login
    [Arguments]    ${Login_text}
    Custom_keywords.Click element by role with text    button    ${Login_text}

Check dropdown menu has user info
    [Arguments]    ${name}
    ${Topnav_Login_Button_Text}=    Get Text    css=#userDropdown-button
    Log    ${Topnav_Login_Button_Text}
    Log    ${BASIC_USER_MALE_FULLNAME}
    Should Be Equal    ${Topnav_Login_Button_Text}    ${name}

Navigate to single booking page
    [Arguments]    ${single_booking_button_text}
    # tänne id
    ${singlebookingbutton}=    Get Element By    text    ${single_booking_button_text}
    Click    ${singlebookingbutton}

###
# MOBILE UI
###

Click navigation menu mobile
    Click    css=button[aria-label="Menu"]

Check menu has user info mobile
    # DEV NOTE
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
    # tänne id
    # miksi katoaa klikin jälkeen. miksi pitää 2 x klikata
    # Click navigation menu mobile
    Click    css=button[aria-label="Menu"]
    Sleep    1s
    Click    css=button[aria-label="Menu"]

    Click    id=hds-mobile-menu >> css=[data-testid="navigation__reservationUnitSearch"]
