*** Settings ***
Documentation       A resource file with keywords.

Resource            ../PO/User/quick_reservation.robot
Resource            variables.robot
Resource            texts_FI.robot
Library             Browser
Library             DateTime
Library             OperatingSystem
Library             python_keywords.py


*** Keywords ***
Formats reservation number and name for admin side
    ${bookingNumber_and_NameOfTheBooking}=    Catenate    ${BOOKING_NUM_ONLY},    ${SINGLEBOOKING_NAME}
    Set Suite Variable    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}    ${bookingNumber_and_NameOfTheBooking}

Formats tagline for admin side
    [Documentation]    Formats the given information as "Ma 25.11.2024 22:30–23:30, 1 t | Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju"
    [Arguments]    ${info_card_time_of_reservation}    ${name_of_reservationunit}

    # Log the original time of reservation string
    Log    ${info_card_time_of_reservation}
    Log    ${name_of_reservationunit}

    # Remove 'klo' and any following whitespace using a regular expression
    ${RESERVATION_TAG_KLO_REMOVED}=    Replace String Using Regexp
    ...    ${info_card_time_of_reservation}
    ...    klo\s*
    ...    ${EMPTY}

    # Log the result after 'klo' removal
    Log    ${RESERVATION_TAG_KLO_REMOVED}

    # Strip any leading or trailing whitespace from the result
    ${RESERVATION_TAG_KLO_REMOVED}=    Evaluate    '${RESERVATION_TAG_KLO_REMOVED}'.strip()

    # Log the result after stripping whitespace
    Log    ${RESERVATION_TAG_KLO_REMOVED}

    # Build tagline by default with location
    ${RESERVATION_TAG}=    Catenate    ${RESERVATION_TAG_KLO_REMOVED} | ${name_of_reservationunit}

    # Normalize whitespace: replace multiple spaces with a single space
    ${RESERVATION_TAG}=    Evaluate    ' '.join('''${RESERVATION_TAG}'''.split())

    # Set the suite variable to hold the final formatted tagline
    Set Suite Variable    ${RESERVATION_TAGLINE}    ${RESERVATION_TAG}

    # Log the final formatted tagline
    Log    ${RESERVATION_TAGLINE}

Formats calendar event content
    # TODO add documentation example here
    [Arguments]
    ...    ${firstname_used_in_reservation_by_admin}
    ...    ${lastname_used_in_reservation_by_admin}
    ...    ${prefix_fi}
    ${result}=    Set Variable
    ...    ${prefix_fi} ${firstname_used_in_reservation_by_admin} ${lastname_used_in_reservation_by_admin}
    Log    Generated string: ${result}
    RETURN    ${result}

Get modified date and time
    [Documentation]    Advances the current date by 1–15 days and adjusts start/end hours by random offsets between 1 and 5.

    # Get the current date and time
    ${current_date}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S

    # DEVNOTE to test this manually
    # ${current_date}=    Set Variable    2024-04-29 18:52:45

    # Generate random number for days to add (1-15 days)
    ${number_day}=    Evaluate    random.randint(1, 15)    random
    Log    ${number_day}

    # Generate random number for the start hour subtraction (1-5 hours)
    ${start_hour_subtraction}=    Evaluate    random.randint(1, 5)    random
    Log    Start hour subtraction: ${start_hour_subtraction}

    # Calculate the modified date and times
    ${date_plus_x_days}=    Add Time To Date    ${current_date}    ${number_day} days    result_format=%d.%m.%Y
    ${start_hour}=    Add Time To Date    ${current_date}    -${start_hour_subtraction} hours    result_format=%H
    ${end_hour}=    Add Time To Date    ${current_date}    -${start_hour_subtraction-1} hours    result_format=%H

    Log    ${date_plus_x_days}
    Log    ${start_hour}
    Log    ${end_hour}

    RETURN    ${date_plus_x_days}    ${start_hour}    ${end_hour}

Formats reservation time to start and end time
    [Documentation]    Sets format "Pe 1.11.2024 klo 11:00–12:00"
    ...    to "Alkamisaika: 1.11.2024 klo 11:00" and "Päättymisaika: 1.11.2024 klo 12:00"
    ...    It adds "Alkamisaika:" and "Päättymisaika:"
    [Arguments]    ${time_of_the_reservation}

    Log    This sets the FORMATTED_STARTTIME and FORMATTED_ENDTIME

    # DEVNOTE For testing
    # ${time_of_the_reservation}=    Set variable    Pe 13.9.2024 klo 11:45–12:45
    # This uses en dash (–)

    # Validate the format of the original time string --> "Pe 1.11.2024 klo 11:00–12:00"
    ${time_format_is_valid}=    python_keywords.validate_timeformat    ${time_of_the_reservation}

    # Extract the weekday, date, and time range
    ${weekday}    ${date}    ${time_range}=    Split String    ${time_of_the_reservation}    ${SPACE}    2

    # Further split the date into day, month, and year
    ${day}    ${month}    ${year}=    Split String    ${date}    .

    # Split the time range into start and end times
    ${start_time}    ${end_time}=    Split String    ${time_range}    –

    # Remove "klo" from start time if present
    ${start_time}=    Remove String    ${start_time}    klo

    # Remove any leading/trailing spaces from the start and end times
    ${start_time}=    Strip String    ${start_time}
    ${end_time}=    Strip String    ${end_time}

    # Construct the formatted start and end times
    Set Suite Variable    ${FORMATTED_STARTTIME_EMAIL}    Alkamisaika: ${day}.${month}.${year} klo ${start_time}
    Set Suite Variable    ${FORMATTED_ENDTIME_EMAIL}    Päättymisaika: ${day}.${month}.${year} klo ${end_time}

    Log    ${FORMATTED_STARTTIME_EMAIL}
    Log    ${FORMATTED_ENDTIME_EMAIL}

Format reservation time for email receipt
    [Documentation]    This keyword reformats a reservation time string from the format
    ...    "Pe 1.11.2024 klo 11:00–12:00" to "Pe 1.11.2024 11:00-12:00".
    ...    It removes the word "klo" and replaces the en dash (–) with a hyphen (-),
    [Arguments]    ${time_of_the_reservation}

    Log
    ...    Formatting reservation time from '${time_of_the_reservation}' to remove 'klo' and replace en dash with hyphen.

    # Remove 'klo ' and replace the en dash with a hyphen
    ${reservation_time_email_receipt}=    Evaluate
    ...    '''${time_of_the_reservation}'''.replace('klo ', '').replace('–', '-')

    # Log the formatted result
    Log    Formatted reservation time: ${reservation_time_email_receipt}

    Set Suite Variable    ${RESERVATION_TIME_EMAIL_RECEIPT}    ${reservation_time_email_receipt}

Set info card duration time info
    [Documentation]    Format the Finnish date and time into the desired format
    ...    HH:MM WITH ":" "–" "Ti 5.12.2023 klo 11:30–12:30".
    ...    this keyword uses hard coded formatting to assume that reservation duration is 60min
    [Arguments]    ${Timeslot_to_format}    ${Date_to_format}

    Log    Timeslot to format: ${Timeslot_to_format}
    Log    Date to format: ${Date_to_format}

    # DEVNOTE For testing keyword
    # ${Timeslot_to_format}=    Set Variable    12.15

    # Convert the date from Finnish format to a format suitable for datetime conversion
    ${formatted_date}=    Replace String    ${Date_to_format}    .    -

    # Handle time format to ensure it uses colon as the separator
    ${formatted_time}=    Replace String Using Regexp    ${Timeslot_to_format}    [.:]    :

    # Combine date and time into a single datetime string
    ${date_time_string}=    Catenate    SEPARATOR=    ${formatted_date} ${formatted_time}

    # Strip any extra whitespace or hidden characters from the datetime string
    ${date_time_string}=    Strip String    ${date_time_string}
    Log    Formatted datetime string: ${date_time_string}

    # Convert string to datetime object
    ${date_time}=    Convert Date    ${date_time_string}    result_format=datetime    date_format=%d-%m-%Y %H:%M

    # Extracting components directly from a datetime object
    ${year}=    Set Variable    ${date_time.year}
    ${month}=    Set Variable    ${date_time.month}
    ${day}=    Set Variable    ${date_time.day}
    ${hour}=    Evaluate    '{:02}'.format(int(${date_time.hour}))
    ${minute}=    Evaluate    '{:02}'.format(${date_time.minute})
    ${end_hour}=    Evaluate    '{:02}'.format((int(${date_time.hour}) + 1) % 24)

    # Get the Finnish day name from the datetime object using the Python function
    ${finnish_day}=    Get Finnish Day    ${date_time}

    # Format the Finnish date and time into the desired format
    # HH:MM WITH ":" "–" "Ti 5.12.2023 klo 11:30–12:30"
    # 1t comes from duration of the reservation that is set in this test to 1h / 60min
    ${finnish_date}=    Catenate    SEPARATOR=    ${day}.${month}.${year}
    ${formatted_date}=    Catenate
    ...    SEPARATOR=
    ...    ${finnish_day} ${finnish_date} klo ${hour}:${minute}–${end_hour}:${minute}, 1 t
    ${formatted_date_minus_t}=    Catenate
    ...    SEPARATOR=
    ...    ${finnish_day} ${finnish_date} klo ${hour}:${minute}–${end_hour}:${minute}

    # Return the formatted strings
    RETURN    ${formatted_date}    ${formatted_date_minus_t}

Generate random letter and number
    ${letter}=    Generate Random String    1    [LETTERS]
    ${number}=    Generate Random String    1    [NUMBERS]
    ${random_string}=    Set Variable    ${letter}${number}
    Log    Generated random string: ${random_string}
    RETURN    ${random_string}
