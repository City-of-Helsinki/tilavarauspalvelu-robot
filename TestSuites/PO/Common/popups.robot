*** Settings ***
Library     Browser


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
