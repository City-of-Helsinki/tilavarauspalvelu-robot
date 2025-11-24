*** Settings ***
Documentation       A resource file with top navigation keywords.

Library             Browser
Resource            ../../Resources/custom_keywords.robot
Resource            ../../Resources/variables.robot
Resource            ../../Resources/serial_users.robot


*** Keywords ***
User Fills The Recurring Reservation Name
    [Arguments]    ${name_of_the_recurring_reservation}
    Type Text    id=applicationSections.0.name    ${name_of_the_recurring_reservation}

User Fills The Number Of People In The Recurring Reservation
    [Arguments]    ${number_of_people}
    Type Text    id=applicationSections.0.numPersons    ${number_of_people}

User Fills The Age Group In The Recurring Reservation
    [Arguments]    ${age_group}
    Click    css=[aria-label*="Ikäryhmä. "]
    Sleep    300ms
    custom_keywords.Find And Click Element With Text    span    ${age_group}

User Chooses The Purpose Of The Recurring Reservation
    [Arguments]    ${purpose}
    Click    css=[aria-label*="Varauksen käyttötarkoitus. "]
    Sleep    300ms
    custom_keywords.Find And Click Element With Text    span    ${purpose}

###

User Selects The Default Time Period For The Recurring Reservation
    Click    id=applicationSections.0.defaultPeriod

User Selects The Minimum Length For The Recurring Reservation
    [Arguments]    ${minimum_length}
    Click    css=[aria-label*="Varauksen vähimmäiskesto. "]
    Sleep    300ms
    custom_keywords.Find And Click Element With Text    span    ${minimum_length}

User Selects The Maximum Length For The Recurring Reservation
    [Arguments]    ${maximum_length}
    Click    css=[aria-label*="Varauksen enimmäiskesto. "]
    Sleep    300ms
    custom_keywords.Find And Click Element With Text    span    ${maximum_length}

User Selects The Amount Of Reservations Per Week
    [Arguments]    ${amount_of_reservations_per_week}
    Type Text    id=applicationSections.0.appliedReservationsPerWeek    ${amount_of_reservations_per_week}

User Clicks Continue Button
    Click    id=button__application--next
