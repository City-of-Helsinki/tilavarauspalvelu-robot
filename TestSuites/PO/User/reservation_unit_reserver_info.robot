*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
Enter first name
    [Arguments]    ${firstname}
    Type Text    css=#reserveeFirstName    ${firstname}

Enter last name
    [Arguments]    ${lastname}
    Type Text    css=#reserveeLastName    ${lastname}

Enter email
    [Arguments]    ${email}
    Type Text    css=#reserveeEmail    ${email}

Enter phone number
    [Arguments]    ${phonenumber}
    Type Text    css=#reserveePhone    ${phonenumber}

Select home city
    [Arguments]    ${homecity}
    Click    id=homeCity-toggle-button
    custom_keywords.Find and click element with text    li    ${homecity}
