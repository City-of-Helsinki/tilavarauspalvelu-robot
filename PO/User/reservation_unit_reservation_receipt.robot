*** Settings ***
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
Enter first name
    [Arguments]    ${firstname}
    Type Text    css=#reserveeFirstName    ${firstname}
