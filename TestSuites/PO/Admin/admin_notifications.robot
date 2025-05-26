*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Library     Browser


*** Keywords ***
Admin clicks create notification button
    Click    [href="/kasittely/messaging/notifications/new"]
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin clicks notification name
    [Arguments]    ${notification_name}
    custom_keywords.Find and click element with text    tbody >> a    ${notification_name}
    Sleep    500ms
    Wait For Load State    load    timeout=15s
