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
    ${main_button}=    Set Variable    id=reservation-form-field__municipality-main-button
    # Clicking the selected city would unselect it
    ${already_selected}=    Get Element Count    ${main_button} >> text="${homecity}"
    IF    ${already_selected} == 0
        Click    ${main_button}
        custom_keywords.Find And Click Element With Text    li    ${homecity}
    END
    Wait For Elements State    ${main_button} >> text="${homecity}" >> nth=0    visible    timeout=5s
    custom_keywords.Close Select List If Open    ${main_button}

Check Application Cannot Be Made Without Info
    [Documentation]    Checks for the error notification banner that appears when required
    ...    fields are missing.
    Wait For Elements State    [data-testid="reservation__button--continue"]    visible
    Click    [data-testid="reservation__button--continue"]
    Sleep    1s

    # Check that error notification banner is displayed
    Wait For Elements State    ${NOTIFICATION_TYPE_ERROR}    visible
