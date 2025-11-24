*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User Selects Who Is The Application Created For
    [Arguments]    ${application_type_element}
    Click    label[for="${application_type_element}"]

User Types First Name
    [Arguments]    ${first_name}
    Fill Text    id=contactPersonFirstName    ${first_name}

User Types Last Name
    [Arguments]    ${last_name}
    Fill Text    id=contactPersonLastName    ${last_name}

User Types Street Address
    [Arguments]    ${street_address}
    Fill Text    id=billingStreetAddress    ${street_address}

User Types Post Code
    [Arguments]    ${post_code}
    Fill Text    id=billingPostCode    ${post_code}

User Types City
    [Arguments]    ${city}
    Fill Text    id=billingCity    ${city}

User Types Phone Number
    [Arguments]    ${phone_number}
    Fill Text    id=contactPersonPhoneNumber    ${phone_number}

User Types Email
    [Arguments]    ${email}
    Fill Text    id=contactPersonEmail    ${email}

User Types Additional Information
    [Arguments]    ${the purpose of the booking}
    Fill Text    id=additionalInformation    ${the purpose of the booking}
