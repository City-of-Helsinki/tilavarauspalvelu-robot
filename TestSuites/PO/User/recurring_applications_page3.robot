*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/users.robot


*** Keywords ***
User selects who is the application created for
    [Arguments]    ${application_type_element}
    Click    label[for="${application_type_element}"]

User types first name
    [Arguments]    ${first_name}
    Fill Text    id=contactPersonFirstName    ${first_name}

User types last name
    [Arguments]    ${last_name}
    Fill Text    id=contactPersonLastName    ${last_name}

User types street address
    [Arguments]    ${street_address}
    Fill Text    id=billingStreetAddress    ${street_address}

User types post code
    [Arguments]    ${post_code}
    Fill Text    id=billingPostCode    ${post_code}

User types city
    [Arguments]    ${city}
    Fill Text    id=billingCity    ${city}

User types phone number
    [Arguments]    ${phone_number}
    Fill Text    id=contactPersonPhoneNumber    ${phone_number}

User types email
    [Arguments]    ${email}
    Fill Text    id=contactPersonEmail    ${email}

User types additional information
    [Arguments]    ${the purpose of the booking}
    Fill Text    id=additionalInformation    ${the purpose of the booking}
