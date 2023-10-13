*** Settings ***
Library     Browser


*** Keywords ***
Click submit button continue
    Click    [data-test="reservation__button--update"]
    Sleep    2
