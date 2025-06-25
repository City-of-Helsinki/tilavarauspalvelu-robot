*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/users.robot


*** Keywords ***
User clicks the accept terms of use checkbox
    Click    id=preview.acceptTermsOfUse-terms-accepted

User clicks the specific terms of use checkbox
    Click    id=preview.acceptServiceSpecificTerms-terms-accepted

User clicks the submit button
    Click    id=button__application--submit
    Sleep    1s
    Wait For Load State    load    timeout=10s
