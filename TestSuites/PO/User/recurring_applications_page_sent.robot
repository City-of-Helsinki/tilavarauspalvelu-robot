*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User Checks H1 Of The Sent Page
    Get Text    h1    ==    Kiitos hakemuksesta!
    custom_keywords.Check Elements Text    h1    Kiitos hakemuksesta!

User Clicks The Specific Terms Of Use Checkbox
    Click    id=preview.acceptServiceSpecificTerms-terms-accepted
