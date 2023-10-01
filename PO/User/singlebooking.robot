*** Settings ***
Library     Browser


*** Keywords ***
Search units by name
    [Arguments]    ${search_text}
    Type Text    input#search    ${search_text}
#
    Click    id=searchButton-desktop
    Sleep    1s

Click searched unit
    [Arguments]    ${searched_text}
    ${searched_list_element}=    Get Text    [data-testid="list-with-pagination__list--container"] >> h2
    Log    ${searched_list_element}
    Should Be Equal    ${searched_list_element}    ${searched_text}
    Click    h2 >> '${searched_text}'
