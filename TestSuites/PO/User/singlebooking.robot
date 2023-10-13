*** Settings ***
Library     Browser
Library     Dialogs


*** Keywords ***
Search units by name
    [Arguments]    ${search_text}
    Type Text    input#search    ${search_text}
#
    Click    id=searchButton-desktop
    Wait For Elements State    [data-testid="list-with-pagination__list--container"]    visible

Click searched unit
    [Arguments]    ${searched_text}
    ${searched_list_element}=    Get Text    [data-testid="list-with-pagination__list--container"] >> h2
    Log    ${searched_list_element}
    Should Be Equal    ${searched_list_element}    ${searched_text}
    Click    h2 >> '${searched_text}'

###
###MOBILE
###

Click show more filters mobile
    Click    [data-testid="search-form__button--toggle-filters"]
    Wait For Elements State    [data-testid="search-form__button--toggle-filters"]    visible

Search units by name mobile
    [Arguments]    ${search_text}
    Type Text    id=search    ${search_text}
#
    Click    id=searchButton
    Wait For Elements State    [data-testid="list-with-pagination__list--container"]    visible

Click searched unit mobile
    [Arguments]    ${searched_text}
    ${searched_list_element}=    Get Text    [data-testid="list-with-pagination__list--container"] >> h2
    Log    ${searched_list_element}
    Should Be Equal    ${searched_list_element}    ${searched_text}
    Click    h2 >> '${searched_text}'
