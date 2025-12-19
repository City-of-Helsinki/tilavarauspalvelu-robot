*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/serial_users.robot
Library     Browser


*** Keywords ***
Enter First Name
    [Arguments]    ${firstname}
    Type Text    id=reservation-form-field__reserveeFirstName    ${firstname}

Enter Last Name
    [Arguments]    ${lastname}
    Type Text    id=reservation-form-field__reserveeLastName    ${lastname}

Enter Email
    [Arguments]    ${email}
    Type Text    id=reservation-form-field__reserveeEmail    ${email}

Enter Phone Number
    [Arguments]    ${phonenumber}
    Type Text    id=reservation-form-field__reserveePhone    ${phonenumber}

Select Home City
    [Arguments]    ${homecity}
    Click    id=reservation-form-field__municipality-main-button
    Sleep    500ms    # Wait for animation
    custom_keywords.Find And Click Element With Text    li    ${homecity}
    Sleep    1.5s    # Wait for animation

Check Application Cannot Be Made Without Info
    [Documentation]    Checks for the error notification banner that appears when required
    ...    fields are missing.
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    Click    [data-testid="reservation__button--continue"]
    Sleep    1s

    # Check that error notification banner is displayed
    Wait For Elements State    ${NOTIFICATION_TYPE_ERROR}    visible
