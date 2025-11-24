*** Settings ***
Resource    ../../Resources/custom_keywords.robot
Library     Browser


*** Keywords ***
Admin Searches Own Unit And Clicks It
    [Arguments]    ${units_location}
    Sleep    1s
    Wait For Elements State    id=search    visible
    Type Text    id=search    ${units_location}
    Sleep    2s    # Wait for the search results to load
    custom_keywords.Find And Click Element With Text    td >> a    ${units_location}
    Sleep    3s    # long wait for spinner
    Wait For Load State    load    timeout=15s

Admin Clicks Calendar Open In Own Units
    [Arguments]    ${unit_name}
    # This locates the row in the calendar with the title="${unit_name}".
    # It then selects the 26th div within that row's container and clicks it.

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

Admin Clicks Make Reservation
    Click    span:has-text("Tee varaus")

Admin Checks Make Reservation Button Is Disabled
    ${button_selector}=    Set Variable    button:has-text("Tee varaus")

    # Verify button is visible and disabled
    Wait For Elements State    ${button_selector}    visible    timeout=5s
    Wait For Elements State    ${button_selector}    disabled    timeout=2s

    Log    Button is properly disabled for VIEWER role

Admin Selects Unit From Reservation Units Dropdown
    [Arguments]    ${units_location}
    Wait For Elements State    [aria-label*="Varausyksikkö"]    visible
    Click    [aria-label*="Varausyksikkö"]
    Sleep    1s
    custom_keywords.Find And Click Element With Text    li >> span    ${units_location}
    Sleep    1s
