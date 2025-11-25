*** Settings ***
Documentation       A resource file with keywords.

Resource            ../PO/User/quick_reservation.robot
Resource            variables.robot
Resource            texts_FI.robot
Resource            parallel_test_data.robot
Library             Browser
Library             DateTime
Library             OperatingSystem
Library             python_keywords.py


*** Keywords ***
Formats Reservation Number And Name For Admin Side
    ${bookingNumber_and_NameOfTheBooking}=    Catenate    ${BOOKING_NUM_ONLY},    ${SINGLEBOOKING_NAME}
    Store Test Data Variable    BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED    ${bookingNumber_and_NameOfTheBooking}
    Set Test Variable    ${BOOKING_NUM_ONLY_BOOKING_NAME_SUBVENTED}    ${bookingNumber_and_NameOfTheBooking}

Formats Tagline For Admin Side
    [Documentation]    Formats the given information as "Ma 25.11.2024 22:30–23:30, 1 t | Aina käsiteltävä kellarikerros (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju"
    [Arguments]    ${info_card_time_of_reservation}    ${name_of_reservationunit}

    # Log the original time of reservation string
    Log    ${info_card_time_of_reservation}
    Log    ${name_of_reservationunit}

    # DEVNOTE: Remove 'klo' and any following whitespace using a regular expression
    # This was used when the app didn't include 'klo' in the time format
    # Uncomment the lines below if the app changes back to not including 'klo'
    # ${RESERVATION_TAG_KLO_REMOVED}=    Replace String Using Regexp
    # ...    ${info_card_time_of_reservation}
    # ...    klo\s*
    # ...    ${EMPTY}
    # Log    ${RESERVATION_TAG_KLO_REMOVED}
    # ${RESERVATION_TAG_KLO_REMOVED}=    Evaluate    '${RESERVATION_TAG_KLO_REMOVED}'.strip()
    # Log    ${RESERVATION_TAG_KLO_REMOVED}

    # Use the original time string directly (keeping 'klo' as the app now includes it)
    ${RESERVATION_TAG_TIME}=    Evaluate    '${info_card_time_of_reservation}'.strip()

    # Log the result after stripping whitespace
    Log    ${RESERVATION_TAG_TIME}

    # Build tagline by default with location
    ${RESERVATION_TAG}=    Catenate    ${RESERVATION_TAG_TIME} | ${name_of_reservationunit}

    # Normalize whitespace: replace multiple spaces with a single space
    ${RESERVATION_TAG}=    Evaluate    ' '.join('''${RESERVATION_TAG}'''.split())

    # Set the suite variable to hold the final formatted tagline
    Store Test Data Variable    RESERVATION_TAGLINE    ${RESERVATION_TAG}
    Set Test Variable    ${RESERVATION_TAGLINE}    ${RESERVATION_TAG}

    # Log the final formatted tagline
    Log    ${RESERVATION_TAGLINE}

Formats Calendar Event Content
    # TODO add documentation example here
    [Arguments]
    ...    ${firstname_used_in_reservation_by_admin}
    ...    ${lastname_used_in_reservation_by_admin}
    ...    ${prefix_fi}
    ${result}=    Set Variable
    ...    ${prefix_fi} ${firstname_used_in_reservation_by_admin} ${lastname_used_in_reservation_by_admin}
    Log    Generated string: ${result}
    RETURN    ${result}

Convert Finnish Short Day To English
    [Documentation]    Converts Finnish short weekday (e.g. "Su") from a datetime string into full English name.
    [Arguments]    ${finnish_datetime}
    Log    Finnish datetime: ${finnish_datetime}

    # 1: Extract the Finnish short day (first token before the first space)
    # e.g. ['Su','4.5.2025','klo','02:15–02:45,','30','min']
    ${parts}=    Split String    ${finnish_datetime}    ${SPACE}

    # 2: Take the first token as the short day. e.g. 'Su'
    ${short_day}=    Get From List    ${parts}    0

    # 3: Lowercase the short day e.g. 'Su' --> 'su'
    ${cleaned_shortday}=    Convert To Lowercase    ${short_day}

    Log    Normalized key ➔ ${cleaned_shortday}

    # 4: Define parallel lists of Finnish abbreviations and English full names
    ${fi_days}=    Create List    ma    ti    ke    to    pe    la    su
    ${en_days}=    Create List    Monday    Tuesday    Wednesday    Thursday    Friday    Saturday    Sunday

    # 5: Look up the index of the Finnish short day
    ${idx}=    Get Index From List    ${fi_days}    ${cleaned_shortday}
    Should Be True    ${idx} >= 0    msg=Unknown Finnish day abbreviation "${cleaned_shortday}"

    # 6: Use the same index to fetch the English full name
    ${english_day}=    Get From List    ${en_days}    ${idx}

    Store Test Data Variable    ENGLISH_DAY    ${english_day}
    Set Test Variable    ${ENGLISH_DAY}    ${english_day}

Compute Reservation Time Slot
    [Documentation]    Given a start time (HH:MM) and duration (e.g. "60 min"), formats to "HH:MM-HH:MM".
    ...    Durations over 90 min (like '1t 45min') are not supported.
    [Arguments]
    ...    ${reservation_start_time}    # e.g. "17:30"
    ...    ${duration}    # e.g. "60 min"

    Log    Reservation start time: ${reservation_start_time}
    Log    Duration: ${duration}

    # 1: Validate start time (H:MM or HH:MM with optional leading zeros, minutes 00–59)
    Should Match Regexp
    ...    ${reservation_start_time}
    ...    ^(?:[0-1]?[0-9]|2[0-3]):[0-5][0-9]$
    ...    msg=Start time must be "H:MM" or "HH:MM" (with optional leading zero) and valid minutes (00-59)

    # 2: Validate duration "<digits> min"
    Should Match Regexp
    ...    ${duration}
    ...    ^\\d+\\s*min$
    ...    msg=Duration must be like "60 min". Durations over 90 min (like '1t 45min') are not supported.

    # 3: Split the start time into hour and minute components
    ${start_parts}=    Split String    ${reservation_start_time}    :
    ${start_hour_raw}=    Get From List    ${start_parts}    0    # e.g. "17" or "09"
    ${start_min}=    Get From List    ${start_parts}    1    # e.g. "30"

    # 3a: Remove leading zero from start hour
    ${start_hour}=    Convert To Integer    ${start_hour_raw}
    Log    Parsed start: ${start_hour}h ${start_min}m (leading zero removed if present)

    # 4: Build a time interval string for the start (e.g. "17 hours 30 minutes")
    ${start_interval}=    Catenate    SEPARATOR=${SPACE}
    ...    ${start_hour} hours    ${start_min} minutes
    Log    Start interval ➔ ${start_interval}

    # 5: Normalize duration to full words (e.g. "60 min" → "60 minutes")
    ${parts}=    Split String    ${duration}    min
    ${num_str}=    Get From List    ${parts}    0
    ${num_str}=    Replace String    ${num_str}    ${SPACE}    ${EMPTY}
    ${duration_str}=    Catenate    SEPARATOR=${SPACE}    ${num_str}    minutes
    Log    Normalized duration ➔ ${duration_str}

    # 6: Add start interval and duration to get raw end time "HH:MM:SS"
    ${end_timer}=    Add Time To Time
    ...    ${start_interval}    ${duration_str}
    ...    result_format=timer    exclude_millis=True
    Log    Raw timer end ➔ ${end_timer}

    # 7: Extract hour and minute from timer string
    ${end_parts}=    Split String    ${end_timer}    :
    ${end_hour}=    Get From List    ${end_parts}    0    # e.g. "18"
    ${end_min}=    Get From List    ${end_parts}    1    # e.g. "30"
    Log    Computed end: ${end_hour}h ${end_min}m

    # 8: Remove leading zero from end_hour
    ${end_hour}=    Convert To Integer    ${end_hour}
    Log    End hour without leading zero ➔ ${end_hour}

    # 9: Ensure end time didn’t wrap past midnight
    ${start_h_int}=    Convert To Integer    ${start_hour}
    ${end_h_int}=    Convert To Integer    ${end_hour}

    # a) Must not exceed 23
    Should Be True    ${end_h_int} <= 23
    ...    msg=End hour ${end_h_int} past midnight not supported
    # b) Must not be before the start
    Should Be True    ${end_h_int} >= ${start_h_int}
    ...    msg=End hour ${end_h_int} is before start hour ${start_h_int}

    # 10: Combine into final slot (both times without leading zeros)
    ${start_time}=    Catenate    SEPARATOR=:    ${start_hour}    ${start_min}
    ${end_time}=    Catenate    SEPARATOR=:    ${end_hour}    ${end_min}
    ${full_slot}=    Catenate    SEPARATOR=-    ${start_time}    ${end_time}
    Log    Final reservation slot ➔ ${full_slot}

    # 11: Expose for suite use
    Store Test Data Variable    CALENDAR_TIMESLOT    ${full_slot}
    Set Test Variable    ${CALENDAR_TIMESLOT}    ${full_slot}

Get Modified Date And Time
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

Formats Reservation Time To Start And End Time
    [Documentation]    Sets format "Pe 1.11.2024 klo 11:00–12:00"
    ...    to "Alkamisaika: 1.11.2024 klo 11:00" and "Päättymisaika: 1.11.2024 klo 12:00"
    ...    It adds "Alkamisaika:" and "Päättymisaika:"
    [Arguments]    ${time_of_the_reservation}

    Log    This sets the FORMATTED_STARTTIME and FORMATTED_ENDTIME

    # DEVNOTE For testing
    # ${time_of_the_reservation}=    Set variable    Pe 13.9.2024 klo 11:45–12:45
    # This uses en dash (–)

    # Validate the format of the original time string --> "Pe 1.11.2024 klo 11:00–12:00"
    ${time_format_is_valid}=    python_keywords.Validate Timeformat    ${time_of_the_reservation}

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

Set Info Card Duration Time Info
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

Generate Random Letter And Number
    ${letter}=    Generate Random String    1    [LETTERS]
    ${number}=    Generate Random String    1    [NUMBERS]
    ${random_string}=    Set Variable    ${letter}${number}
    Log    Generated random string: ${random_string}
    RETURN    ${random_string}

Get Date Plus 60 Days
    [Documentation]    Sets the current date plus 60 days in format d.M.yyyy (e.g. 12.2.2012).
    ${current_date}=    Get Current Date    result_format=%Y-%m-%d
    ${date_plus_60_days}=    Add Time To Date    ${current_date}    60 days    result_format=%d.%m.%Y

    # Remove leading zeros from day and month
    ${day}    ${month}    ${year}=    Split String    ${date_plus_60_days}    .
    ${day}=    Convert To Integer    ${day}
    ${month}=    Convert To Integer    ${month}
    ${date_plus_60_days}=    Catenate    SEPARATOR=.    ${day}    ${month}    ${year}

    RETURN    ${date_plus_60_days}
