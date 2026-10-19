*** Settings ***
Library     Browser
Resource    ../../Resources/custom_keywords.robot


*** Keywords ***
Click Submit Button Continue
    Wait For Elements State    [data-testid="reservation__button--continue"]    enabled
    custom_keywords.Click And Wait For Page    [data-testid="reservation__button--continue"]
