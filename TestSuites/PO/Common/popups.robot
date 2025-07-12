*** Settings ***
Library     Browser
Resource    ../App/app_common.robot


*** Keywords ***
User accepts cookies if dialog is visible
    [Documentation]    Ensures the visibility of the button with the specified text inside a dialog.
    ...    If the dialog with role="dialog" is visible, clicks the button.
    ...    Otherwise, continues the test without failing.
    [Arguments]    ${cookie_text}

    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State
    ...    button:has-text("${cookie_text}")
    ...    visible
    ...    timeout=10s

    IF    ${dialog_visible}
        Log    Dialog is visible. Checking for the button with text "${cookie_text}".
        Click    button:has-text("${cookie_text}")
        Log    Clicked the "${cookie_text}" button.
        Sleep    1.5s    # wait for the animation to close
    ELSE
        Log    Dialog is not visible. Continuing the test.
    END

Close notification banner if visible
    [Documentation]    Closes all notification banners by clicking close button
    ...    and refreshing until no notifications are visible

    ${attempt}=    Set Variable    1
    ${success}=    Set Variable    False
    WHILE    True
        # Check if notification exists
        ${notifications_visible}=    Browser.Get Element Count
        ...    [data-sentry-component="BannerNotificationsList"] >> [data-testid="BannerNotificationList__Notification"]
        Log    Attempt ${attempt}: Found ${notifications_visible} notifications

        # Exit if no notifications
        IF    ${notifications_visible} == 0
            Log    No more notifications found. Continuing test.
            ${success}=    Set Variable    True
            BREAK
        END

        # Check if we've reached the limit
        IF    ${attempt} > 5
            Log    Reached maximum attempts (5). Unable to close all notifications.
            BREAK
        END

        # Close notification and refresh
        Click    [data-testid="BannerNotificationList__Notification"] >> button[title="Sulje"] >> nth=0
        Sleep    500ms
        Log    Clicked close button on notification

        app_common.Reload page
        ${attempt}=    Evaluate    ${attempt} + 1
    END
    # If we reach here and success is False, we couldn't close all notifications
    IF    not ${success}
        Fail    Too many notification banners! Please delete extra notifications from admin side.
    END
