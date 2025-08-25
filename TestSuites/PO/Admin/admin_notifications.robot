*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Library     Browser


*** Keywords ***
Admin clicks create notification button
    Sleep    1.5s
    Click    [href="/kasittely/notifications/new"]
    Sleep    1.5s
    Wait For Load State    load    timeout=15s

Admin clicks notification name
    [Arguments]    ${notification_name}
    custom_keywords.Find and click element with text    tbody >> a    ${notification_name}
    Sleep    2s
    Wait For Load State    load    timeout=15s

Admin verifies notification is not found
    [Documentation]    Verifies that a notification with the specified name is NOT present in the notifications list
    [Arguments]    ${notification_name}
    custom_keywords.Verify element with text is not found    tbody >> a    ${notification_name}
