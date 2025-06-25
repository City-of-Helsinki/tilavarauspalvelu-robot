*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/users.robot


*** Keywords ***
User fills the recurring reservation name
    [Arguments]    ${name_of_the_recurring_reservation}
    Type Text    id=applicationSections.0.name    ${name_of_the_recurring_reservation}

User fills the number of people in the recurring reservation
    [Arguments]    ${number_of_people}
    Type Text    id=applicationSections.0.numPersons    ${number_of_people}

User fills the age group in the recurring reservation
    [Arguments]    ${age_group}
    Click    css=[aria-label*="Ikäryhmä. "]
    Sleep    300ms
    custom_keywords.Find and click element with text    span    ${age_group}

User chooses the purpose of the recurring reservation
    [Arguments]    ${purpose}
    Click    css=[aria-label*="Varauksen käyttötarkoitus. "]
    Sleep    300ms
    custom_keywords.Find and click element with text    span    ${purpose}

###

User selects the default time period for the recurring reservation
    Click    id=applicationSections.0.defaultPeriod

User selects the minimum length for the recurring reservation
    [Arguments]    ${minimum_length}
    Click    css=[aria-label*="Varauksen vähimmäiskesto. "]
    Sleep    300ms
    custom_keywords.Find and click element with text    span    ${minimum_length}

User selects the maximum length for the recurring reservation
    [Arguments]    ${maximum_length}
    Click    css=[aria-label*="Varauksen enimmäiskesto. "]
    Sleep    300ms
    custom_keywords.Find and click element with text    span    ${maximum_length}

User selects the amount of reservations per week
    [Arguments]    ${amount_of_reservations_per_week}
    Type Text    id=applicationSections.0.appliedReservationsPerWeek    ${amount_of_reservations_per_week}

User clicks continue button
    Click    id=button__application--next
