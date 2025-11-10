*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Library     Browser


*** Keywords ***
Admin changes permissions
    [Arguments]    ${role_value}
    Click    id=id_role
    # Wait for the dropdown to open
    Sleep    1s
    Select Options By    id=id_role    value    ${role_value}
    Sleep    1s

Admin saves changes
    Click    input[value="Tallenna ja poistu"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin searches the user by email
    [Arguments]    ${user_email}
    Type Text    id=searchbar    ${user_email}
    Sleep    1s
    Click    input[type="submit"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin clicks first user
    [Documentation]    Clicks the role link in the search results. Should be used after searching by email to ensure only one match exists.
    Click    .field-role a
    Sleep    2s
    Wait For Load State    load    timeout=15s

Admin navigates to general role page
    Go to    https://varaamo.test.hel.ninja/admin/tilavarauspalvelu/generalrole/
    sleep    1s
    wait for load state    load    timeout=15s

Admin navigates to unit role page
    Go to    https://varaamo.test.hel.ninja/admin/tilavarauspalvelu/unitrole/
    sleep    1s
    wait for load state    load    timeout=15s
