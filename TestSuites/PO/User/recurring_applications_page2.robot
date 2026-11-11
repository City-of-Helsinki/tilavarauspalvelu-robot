*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User Selects Type Of The Booking Request
    [Arguments]    ${type_of_booking_request_txt}
    # A radio button: the times painted after it get this type. Its label is clicked, like a user does.
    Click    css=label:has-text("${type_of_booking_request_txt}")

User Clicks Available Seasonal Booking Times For
    [Arguments]    ${name_of_the_unit}
    Click    css=[aria-label*="Näytä kausivarattavat "]
    Sleep    500ms
    Find And Click Element With Text    ul >> span    ${name_of_the_unit}

User Selects The Times For Recurring Application
    [Documentation]    Paints the times of one weekday in the calendar, from the start to the end, with the type
    ...    selected before.
    [Arguments]    ${weekday}    ${from}    ${to}
    # The calendar is a table with the role grid. Its cells have their weekday and the start and end of their time: the
    # first cell of the times starts at ${from}, and the last one ends at ${to}.
    ${first_cell}=    Set Variable    css=table[role="grid"] td[data-weekday="${weekday}"][data-time-start="${from}"]
    ${last_cell}=    Set Variable    css=table[role="grid"] td[data-weekday="${weekday}"][data-time-end="${to}"]
    # Drag And Drop doesn't scroll: it moves the mouse to where the cells are on the screen, and the evening rows are
    # below the fold. Scrolling to the first cell and then to the last one leaves both in view when they are less than
    # half a screen apart (2 hours is about 100 px).
    Scroll To Element    ${first_cell}
    Scroll To Element    ${last_cell}
    # Dragging from a cell to another on the same day paints the cells between them, like a user does with a mouse
    Drag And Drop    ${first_cell}    ${last_cell}
    # The first cell of a painted run is named after the whole run, e.g. "Torstai, 19:00–21:00, Ensisijainen toive"
    Get Attribute    ${first_cell}    aria-label    *=    ${from}–${to}

User Clicks Continue Button
    Log    this is the same in the page 3
    custom_keywords.Click And Wait For Page    id=button__application--next
