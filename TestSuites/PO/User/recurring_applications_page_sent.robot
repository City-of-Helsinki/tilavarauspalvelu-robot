*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/users.robot


*** Keywords ***
User checks h1 of the sent page
    Get Text    h1    ==    Kiitos hakemuksesta!
    custom_keywords.Check elements text    h1    Kiitos hakemuksesta!

User clicks the specific terms of use checkbox
    Click    id=preview.acceptServiceSpecificTerms-terms-accepted
