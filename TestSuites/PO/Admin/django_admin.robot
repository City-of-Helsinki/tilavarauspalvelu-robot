*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Library     Browser


*** Keywords ***
Admin Changes Permissions
    [Arguments]    ${role_value}
    Click    id=id_role
    # Wait for the dropdown to open
    Sleep    1s
    Select Options By    id=id_role    value    ${role_value}
    Sleep    1s

Admin checks permission is not present
    [Arguments]    ${role_value}
    Click    id=id_role
    # Wait for the dropdown to open
    Sleep    1s
    ${option_count}=    Browser.Get Element Count    id=id_role >> option[value="${role_value}"]
    Should Be Equal As Numbers    ${option_count}    0    msg=Option with value "${role_value}" should not be present

Admin Saves Changes
    Click    input[value="Tallenna ja poistu"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Searches The User By Email
    [Arguments]    ${user_email}
    Type Text    id=searchbar    ${user_email}
    Sleep    1s
    Click    input[type="submit"]
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Clicks First User
    [Documentation]    Clicks the role link in the search results. Should be used after searching by email to ensure only one match exists.
    Click    .field-role a
    Sleep    2s
    Wait For Load State    load    timeout=15s

Admin Navigates To General Role Page
    Go To    https://varaamo.test.hel.ninja/admin/tilavarauspalvelu/generalrole/
    Sleep    1s
    Wait For Load State    load    timeout=15s

Admin Navigates To Unit Role Page
    Go To    https://varaamo.test.hel.ninja/admin/tilavarauspalvelu/unitrole/
    Sleep    1s
    Wait For Load State    load    timeout=15s
