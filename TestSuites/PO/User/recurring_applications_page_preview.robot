*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User Clicks The Accept Terms Of Use Checkbox
    Click    id=preview.acceptTermsOfUse-terms-accepted

User Clicks The Specific Terms Of Use Checkbox
    Click    id=preview.acceptServiceSpecificTerms-terms-accepted

User Clicks The Submit Button
    Click    id=button__application--submit
    Sleep    1s
    Wait For Load State    load    timeout=10s
