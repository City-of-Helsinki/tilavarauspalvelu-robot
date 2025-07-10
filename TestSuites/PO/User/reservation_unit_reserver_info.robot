*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
Enter first name
    [Arguments]    ${firstname}
    Type Text    id=reservation-form-field__reserveeFirstName    ${firstname}

Enter last name
    [Arguments]    ${lastname}
    Type Text    id=reservation-form-field__reserveeLastName    ${lastname}

Enter email
    [Arguments]    ${email}
    Type Text    id=reservation-form-field__reserveeEmail    ${email}

Enter phone number
    [Arguments]    ${phonenumber}
    Type Text    id=reservation-form-field__reserveePhone    ${phonenumber}

Select home city
    [Arguments]    ${homecity}
    Click    id=reservation-form-field__municipality-main-button
    Sleep    500ms    # Wait for animation
    custom_keywords.Find and click element with text    li    ${homecity}
    Sleep    1.5s    # Wait for animation
