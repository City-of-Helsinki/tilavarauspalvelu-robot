*** Settings ***
Library     Browser


*** Keywords ***
Search Units By Name
    [Arguments]    ${search_text}
    Sleep    1s
    Type Text    input#search    ${search_text}
    Sleep    1s
#
    # Click    button[type="submit"]
    Click    [data-testid="searchButton"]
    Sleep    2s    # wait for search results to load
    Wait For Load State    load    timeout=15s
    # Check if actual results are found
    Wait For Elements State    [data-testid="list-with-pagination__list--container"]    visible

Click Searched Unit
    [Arguments]    ${searched_text}
    Sleep    2s
    ${searched_list_element}=    Get Text    [data-testid="list-with-pagination__list--container"] >> h2
    Log    ${searched_list_element}
    Should Be Equal    ${searched_list_element}    ${searched_text}
    Click    h2 >> '${searched_text}'

Click Advanced Search If Search Not Visible
    [Documentation]    Ensures the visibility of the search input by clicking the
    ...    "Advanced Search" toggle button if the search field is not already visible.

    ${search_visible}=    Run Keyword And Return Status
    ...    Wait For Elements State
    ...    id=search
    ...    visible
    ...    timeout=5s

    IF    not ${search_visible}
        Log    Search input is not visible. Clicking advanced search
        # Tää ei klikkaa oikeasti
        Wait For Elements State    [data-testid="show-all__toggle-button"]    visible
        Click    [data-testid="show-all__toggle-button"]
        # Wait for animation
        Sleep    1s
        Wait For Elements State    id=search    visible    timeout=5s
    ELSE
        Log    Search input is visible. No further action required.
    END
