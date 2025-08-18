*** Settings ***
Resource    ../../Resources/variables.robot
Resource    ../../Resources/users.robot
Resource    ../../Resources/custom_keywords.robot
Resource    ../../Resources/data_modification.robot
Library     Browser


*** Keywords ***
Admin selects validity period to immediately
    Click    css=label[for="v-radio1"]

Admin selects notification active until
    # TODO: add date format to data_modification.robot
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

Admin fills notification name
    [Arguments]    ${name}
    Fill Text    id=notification-name    ${name}
    Sleep    500ms

# Ilmoituksen tyyppi

Admin selects type of notification
    [Arguments]    ${notification_type}
    Click    css=[aria-label*="Ilmoituksen tyyppi."]
    Sleep    500ms
    custom_keywords.Find and click element with text    form >> li >> span    ${notification_type}
    Sleep    500ms

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

Admin selects target group all
    Click    css=[aria-label*="Kohderyhmä."]
    Sleep    1s
    custom_keywords.Find and click element with text    form >> li >> span    ${NOTIFICATION_BANNER_TARGET_GROUP_ALL}
    Sleep    1s

Admin selects target group admin
    Click    css=[aria-label*="Kohderyhmä."]
    Sleep    1s
    custom_keywords.Find and click element with text    form >> li >> span    ${NOTIFICATION_BANNER_TARGET_GROUP_ADMIN}
    Sleep    1s

Admin selects target group user
    Click    css=[aria-label*="Kohderyhmä."]
    Sleep    1s
    custom_keywords.Find and click element with text    form >> li >> span    ${NOTIFICATION_BANNER_TARGET_GROUP_USER}
    Sleep    1s

#

# Viesti

Admin clicks notification text fi container
    Click    id=notification-text-fi-container
    Sleep    500ms
    Wait For Load State    load    timeout=15s

Admin fills notification text fi
    [Arguments]    ${text_fi}
    Fill Text    id=notification-text-fi >> p    ${text_fi}
    Sleep    500ms

Admin fills notification text eng
    [Arguments]    ${text_eng}
    Fill Text    id=notification-text-eng    ${text_eng}
    Sleep    500ms

Admin fills notification text en sv
    [Arguments]    ${text_sv}
    Fill Text    id=notification-text-sv    ${text_sv}
    Sleep    500ms

Admin publishes notification
    Click    [data-testid="Notification__Page--publish-button"]
    Sleep    2s
    Wait For Load State    load    timeout=15s

Admin drafts notification
    Click    [data-testid="Notification__Page--save-draft-button"]
    Sleep    2s
    Wait For Load State    load    timeout=15s

Admin deletes notification
    custom_keywords.Find and click element with text    button    ${DELETE_NOTIFICATION_BUTTON_TEXT}
    Sleep    2s
    Wait For Load State    load    timeout=15s
