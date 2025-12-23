*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/serial_users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Library     Browser


*** Keywords ***
Admin Selects Immediate Validity Period
    Click    css=label[for="v-radio1"]

Admin Selects Notification Active Until
    [Arguments]    ${date}
    Type Text    id=notification-active-until    ${date}
    Sleep    500ms

# Admin clicks notification active until time label
#    Click    id=notification-active-until-time-label
#    Sleep    500ms

# Admin clicks notification active until time
#    Click    id=notification-active-until-time
#    Sleep    500ms

# Admin clicks notification active until time hours
#    Click    id=notification-active-until-time-hours
#    Sleep    500ms

# Admin clicks notification active until time minutes
#    Click    id=notification-active-until-time-minutes
#    Sleep    500ms

Admin Fills Notification Name
    [Arguments]    ${name}
    Fill Text    id=notification-name    ${name}
    Sleep    500ms

# Ilmoituksen tyyppi

Admin Selects Type Of Notification
    [Arguments]    ${notification_type}
    Click    css=[aria-label*="Ilmoituksen tyyppi."]
    Sleep    1.5s
    custom_keywords.Find And Click Element With Text    form >> li >> span    ${notification_type}
    Sleep    1.5s

# Admin selects type of notification warning
    #    Click    css=[aria-label*="Ilmoituksen tyyppi."]
    # Sleep    500ms
    # custom_keywords.Find and click element with text    form >> li >> span    ${NOTIFICATION_BANNER_MESSAGE_WARNING}
    # Sleep    500ms

# Admin selects type of notification critical
    # Click    css=[aria-label*="Ilmoituksen tyyppi."]
    # Sleep    500ms
    # custom_keywords.Find and click element with text    form >> li >> span    ${NOTIFICATION_BANNER_MESSAGE_ERROR}
    # Sleep    500ms

#

# Kohderyhmä

Admin Selects Target Group All
    Click    css=[aria-label*="Kohderyhmä."]
    Sleep    1.5s
    custom_keywords.Find And Click Element With Text    form >> li >> span    ${NOTIFICATION_BANNER_TARGET_GROUP_ALL}
    Sleep    1.5s

Admin Selects Target Group Admin
    Click    css=[aria-label*="Kohderyhmä."]
    Sleep    1.5s
    custom_keywords.Find And Click Element With Text    form >> li >> span    ${NOTIFICATION_BANNER_TARGET_GROUP_ADMIN}
    Sleep    1.5s

Admin Selects Target Group User
    Click    css=[aria-label*="Kohderyhmä."]
    Sleep    1.5s
    custom_keywords.Find And Click Element With Text    form >> li >> span    ${NOTIFICATION_BANNER_TARGET_GROUP_USER}
    Sleep    1.5s

#

# Viesti

Admin Clicks Notification Text Fi Container
    #
    Click    [data-testid="Notification__Page--message-fi-input"]
    Sleep    1s

Admin Fills Notification Text Fi
    [Arguments]    ${text_fi}
    Fill Text    [data-testid="Notification__Page--message-fi-input"] >> p    ${text_fi}
    Sleep    500ms

Admin Fills Notification Text Eng
    [Arguments]    ${text_eng}
    Fill Text    [data-testid="Notification__Page--message-en-input"]    ${text_eng}
    Sleep    500ms

Admin Fills Notification Text Sv
    [Arguments]    ${text_sv}
    Fill Text    [data-testid="Notification__Page--message-sv-input"]    ${text_sv}
    Sleep    500ms

Admin Publishes Notification
    Click    [data-testid="Notification__Page--publish-button"]
    Sleep    3s
    # Check that publish worked, we should not see this button after clicking it
    Wait For Elements State    [data-testid="Notification__Page--publish-button"]    hidden    timeout=5s    message=Publish button is still visible after clicking - notification publish may have failed

Admin Drafts Notification
    Click    [data-testid="Notification__Page--save-draft-button"]
    Sleep    5s
    Wait For Elements State    [href="/kasittely/notifications/new"]    visible    timeout=15s

Admin Deletes Notification
    custom_keywords.Find And Click Element With Text    button    ${DELETE_NOTIFICATION_BUTTON_TEXT}
    Sleep    5s
    Wait For Elements State    [href="/kasittely/notifications/new"]    visible    timeout=15s

Admin Verifies Notification Is Not Found
    [Documentation]    Verifies that a notification with the specified name is NOT present in the notifications list
    [Arguments]    ${notification_name}
    custom_keywords.Verify Element With Text Is Not Found    tbody >> a    ${notification_name}
