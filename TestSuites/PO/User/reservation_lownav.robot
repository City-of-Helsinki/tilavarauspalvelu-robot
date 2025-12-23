*** Settings ***
Library     Browser


*** Keywords ***
Click Submit Button Continue
    Sleep    500ms
    Wait For Elements State    [data-testid="reservation__button--continue"]    enabled
    Click    [data-testid="reservation__button--continue"]
    Sleep    4s
    Wait For Load State    load    timeout=50s
