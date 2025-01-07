*** Settings ***
Library     Browser


*** Keywords ***
Click submit button continue
    # DEVNOTE Ui selectors have changed so lets change to use only one submit/continue here
    Sleep    500ms
    # TODO wait for enabled here
    Wait For Elements State    [data-testid="reservation__button--continue"]    enabled
    Click    [data-testid="reservation__button--continue"]
    Sleep    1s
    Wait For Load State    Load    timeout=7s
