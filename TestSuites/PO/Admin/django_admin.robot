*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Library     Browser


*** Keywords ***
Admin changes permissions
    [Arguments]    ${role_value}
    Click    id=id_role
    # Wait for the dropdown to open
    Sleep    1s
    Click    option[value="${role_value}"]
    Sleep    1s

Admin saves changes
    Click    input[type="submit"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin searches the user by email
    [Arguments]    ${user_email}
    Type Text    id=searchbar    ${user_email}
    Sleep    1s
    Click    [type="submit"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin clicks user link by partial email
    [Arguments]    ${partial_email}
    Click    a[href*="${partial_email}"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

tilavaraus.test+john.actor@gmail.com

https://varaamo.test.hel.ninja/kasittely/reservations/50006

käyttää sitä vanhaa varausta joka on luotu permissio tsekki
