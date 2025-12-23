*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Library     Browser


*** Keywords ***
Admin Clicks Create Notification Button
    Sleep    1.5s
    Click    [href="/kasittely/notifications/new"]
    Sleep    3s
    Wait For Elements State    [data-testid="Notification__Page--publish-button"]    visible    timeout=15s

Admin Clicks Notification Name
    [Arguments]    ${notification_name}
    custom_keywords.Find And Click Element With Text    tbody >> a    ${notification_name}
    Sleep    3s
    Wait For Elements State    [data-testid="Notification__Page--publish-button"]    visible    timeout=15s

Admin Verifies Notification Is Not Found
    [Documentation]    Verifies that a notification with the specified name is NOT present in the notifications list
    [Arguments]    ${notification_name}
    custom_keywords.Verify Element With Text Is Not Found    tbody >> a    ${notification_name}
