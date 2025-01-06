*** Settings ***
Library     Browser


*** Keywords ***
Click submit button continue
    # DEVNOTE Ui selectors have changed so lets change to use only one submit/continue here
    Sleep    200ms
    # TODO wait for enabled here
    Click    [data-testid="reservation__button--continue"]
    Sleep    1s
    Wait For Load State    domcontentloaded    timeout=7s
