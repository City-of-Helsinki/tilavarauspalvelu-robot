*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Library     Browser


*** Keywords ***
Admin searches own unit and clicks it
    [Arguments]    ${units_location}
    Sleep    1s
    Wait For Elements State    id=search    visible
    Type Text    id=search    ${units_location}
    Sleep    2s
    custom_keywords.Find and click element with text    td >> a    ${units_location}
    Sleep    2s

Admin clicks calendar open in own units
    [Arguments]    ${unit_name}
    # This locates the row in the calendar with the title="${unit_name}".
    # It then selects the 26th div within that row's container and clicks it.

    Sleep    2s

    Log    If a wrong unit is opened, check that the DOM order has not changed

    ${result}=    Evaluate JavaScript
    ...    ${None}
    ...    function(unitName) {
    ...    // Find the main element with the specified title
    ...    const mainElement = document.querySelector(`div[title="${unitName}"]`);
    ...    if (!mainElement) {
    ...    return `Element with selector "div[title=${unitName}]" not found.`;
    ...    }
    ...
    ...    // Get the next sibling of the main element as the row container
    ...    const rowContainer = mainElement.nextElementSibling;
    ...    if (!rowContainer) {
    ...    return "Row container (next sibling) not found";
    ...    }
    ...
    ...    // Locate the 26th div within the row container
    ...    const targetDiv = rowContainer.querySelectorAll("div")[25];
    ...    if (!targetDiv) {
    ...    return "26th div not found within the row container";
    ...    }
    ...
    ...    // Click the target div
    ...    targetDiv.click();
    ...    return "Clicked the 26th div successfully";
    ...    }
    ...    arg=${unit_name}

    Log    ${result}
