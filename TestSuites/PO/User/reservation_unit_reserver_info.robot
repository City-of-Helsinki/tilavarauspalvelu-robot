*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
Enter first name
    [Arguments]    ${firstname}
    Type Text    id=reserveeFirstName    ${firstname}

Enter last name
    [Arguments]    ${lastname}
    Type Text    id=reserveeLastName    ${lastname}

Enter email
    [Arguments]    ${email}
    Type Text    id=reserveeEmail    ${email}

Enter phone number
    [Arguments]    ${phonenumber}
    Type Text    id=reserveePhone    ${phonenumber}

Select home city
    [Arguments]    ${homecity}
    Click    id=homeCity-toggle-button
    custom_keywords.Find and click element with text    li    ${homecity}
