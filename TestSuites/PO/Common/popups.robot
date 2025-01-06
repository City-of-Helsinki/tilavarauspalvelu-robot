*** Settings ***
Library     Browser


*** Keywords ***
User accepts cookies if dialog is visible
    [Documentation]    Ensures the visibility of the "Salli kaikki evästeet" button inside a dialog.
    ...    If the dialog with role="dialog" is visible, clicks the button.
    ...    Otherwise, continues the test without failing.

    ${dialog_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State
    ...    css=[role=dialog] >> button.ch2-btn-primary:has-text("Salli kaikki evästeet")
    ...    visible
    ...    timeout=5s

    IF    ${dialog_visible}
        Log    Dialog is visible. Checking for the button with text "Salli kaikki evästeet".
        Click    css=[role=dialog] >> button.ch2-btn-primary:has-text("Salli kaikki evästeet")
        Log    Clicked the "Salli kaikki evästeet" button.
    ELSE
        Log    Dialog is not visible. Continuing the test.
    END
