*** Settings ***
Library     Browser
Resource    ../../Resources/custom_keywords.robot


*** Keywords ***
Check my bookings h1
    [Arguments]    ${bookingstatus}
    Wait For Load State    load    timeout=5s
    custom_keywords.Check elements text    h1    ${bookingstatus}

###
# Cancel
###

User cancel booking
    Wait For Elements State    data-testid=reservation-detail__button--cancel    visible
    Click    data-testid=reservation-detail__button--cancel

Click reason for cancellation
    # Wait For Elements State    data-testid=reservation-detail__button--cancel    visible
    # Click    id=reason-toggle-button
    Wait For Elements State    id=reservation-cancel__reason-label
    Click    id=reservation-cancel__reason-main-button
    Sleep    1s

Select reason for cancellation
    [Arguments]    ${reason}
    # Wait For Elements State    id=reason-item-0    visible
    Wait For Elements State    id=reservation-cancel__reason-option-2    visible
    custom_keywords.Find and click element with text    li    ${reason}

Click cancel button
    Sleep    1s
    Wait For Elements State    [data-testid="reservation-cancel__button--cancel"]    enabled
    Click    [data-testid="reservation-cancel__button--cancel"]
    # Wait for reservation status to change
    Sleep    2s
    Wait For Load State    load    timeout=15s

Check cancel button is not found in reservations
    Sleep    1s
    Wait For Elements State
    ...    [data-testid="reservation-detail__button--cancel"]
    ...    state=detached
    ...    timeout=3s
    ...    message=Cancel button is still present

###
#
###

###
# Modify booking
###

User click change time
    Wait For Elements State    data-testid=reservation-detail__button--edit    visible
    Click    data-testid=reservation-detail__button--edit
    Sleep    1s    # Wait for animation
    Wait For Load State    load    timeout=15s

User click reservation calendar toggle button
    Click    [data-testid="calendar-controls__toggle-button"]
    Sleep    1s    # Wait for animation
    Wait For Load State    load    timeout=15s

###
# Reservations page
###

Check reservation status
    [Arguments]    ${reservation_status}

    Wait For Elements State    [data-testid="reservation__content"]    visible
    custom_keywords.Check elements text    [data-testid="reservation__status"]    ${reservation_status}

Check reservations payment status
    [Arguments]    ${reservation_payment_status}

    Wait For Elements State    [data-testid="reservation__content"]    visible
    custom_keywords.Check elements text    [data-testid="reservation__payment-status"]    ${reservation_payment_status}

Check reservation number from h1 text
    [Arguments]    ${booking_num}
    custom_keywords.Check number from text is equal to    [data-testid="reservation__name"]    ${booking_num}

Check number of participants
    [Arguments]    ${reservation_number_participants}
    custom_keywords.Check elements text
    ...    [data-testid="reservation__numPersons"]
    ...    ${reservation_number_participants}

Check reservation time
    [Arguments]    ${reservation_time}
    custom_keywords.Check elements text    [data-testid="reservation__time"]    ${reservation_time}

Check reservation description
    [Arguments]    ${reservation_description}
    custom_keywords.Check elements text    [data-testid="reservation__description"]    ${reservation_description}

Check reservation booker name
    [Arguments]    ${reservation_bookerName}
    custom_keywords.Check elements text
    ...    [data-testid="reservation__reservee-name"]
    ...    ${reservation_bookerName}

Check reservation booker phone
    [Arguments]    ${reservation_bookerPhone}
    custom_keywords.Check elements text
    ...    [data-testid="reservation__reservee-phone"]
    ...    ${reservation_bookerPhone}

Check reservation booker email
    [Arguments]    ${reservation_bookerEmail}
    custom_keywords.Check elements text
    ...    [data-testid="reservation__reservee-email"]
    ...    ${reservation_bookerEmail}

Check reservation purpose
    [Arguments]    ${reservation_purpose}
    custom_keywords.Check elements text
    ...    [data-testid="reservation__purpose"]
    ...    ${reservation_purpose}

Check reservation age group
    [Arguments]    ${age_group}
    custom_keywords.Check elements text
    ...    [data-testid="reservation__ageGroup"]
    ...    ${age_group}

Check reservation access code
    [Arguments]    ${access_code}
    custom_keywords.Check elements text
    ...    [data-testid="reservation__reservation-info-card__accessType"]
    ...    ${access_code}

###
# Tablist
###

Navigate to cancelled bookings
    # TODO ask/fix better selectors here
    Click    id=tab-2-button

Navigate to past bookings
    # TODO ask/fix better selectors here
    Click    id=tab-1-button

Navigate to upcoming bookings
    # TODO ask/fix better selectors here
    Click    id=tab-0-button

###
# Additional checks
###

Validate reservations are not for today or later
    Log
    ...    This step assumes that there are reservations in the list. Disabling strict mode here to make sure that selector exists.

    Sleep    2s
    # Disable strict mode to ensure the selector can be located even if multiple matches are found
    Set Strict Mode    False
    # Wait until the reservation elements are visible on the page
    Wait For Elements State    [data-testid="reservation-card__time"]    visible
    # Re-enable strict mode for subsequent operations
    Set Strict Mode    True

    # Get the current date in the format YYYYMMDD to use as the baseline for validation
    ${today}=    Get Current Date    result_format=%Y%m%d

    # Fetch all reservation elements on the page
    @{reservations}=    Browser.Get Elements    [data-testid="reservation-card__time"]

    # Loop through each reservation element
    FOR    ${reservation}    IN    @{reservations}
        # Extract the text content of the reservation element
        ${reservation_text}=    Get Text    ${reservation}

        # Log the reservation details for debugging purposes
        Log    Processing reservation: ${reservation_text}

        # Extract the date portion before the word "klo"
        ${date_part}=    Fetch From Left    ${reservation_text}    klo

        # Remove any leading or trailing whitespace from the extracted date
        ${date_part}=    Strip String    ${date_part}

        # Remove any non-numeric characters (e.g. weekdays or symbols) from the date
        ${date_without_weekday}=    Replace String Using Regexp    ${date_part}    [^0-9.]    ${EMPTY}

        # Convert the cleaned date into the format YYYYMMDD
        ${converted_date_part}=    Evaluate
        ...    datetime.datetime.strptime('''${date_without_weekday}''', '%d.%m.%Y').strftime('%Y%m%d')

        # Log the converted date for debugging
        Log    Converted date: ${converted_date_part}

        # Check if the reservation date is today or later
        IF    '${converted_date_part}' >= '${today}'
            Fail
            ...    Found reservation for ${converted_date_part} which is greater than ${today}. Reservations should not exist for the current day or any future date."
            ...    BREAK
        END
    END

    # Log a success message if no invalid reservations are found
    Log    Validation completed successfully: No reservations found for today or later.

Check unitname and reservation time and click show
    [Documentation]    This keyword verifies if a reservation card with a specified unit name and reservation time is present in the list,
    ...    and clicks the "Show" button on the matching card if found.
    ...    If multiple matches exist, selects the last matching card.
    ...    This behavior is used to handle double matching canceled reservations
    ...    because we cannot clear backend data between test runs.
    [Arguments]    ${unitname}    ${reservation_time}

    Log
    ...    Starting validation for reservation card with unit name: ${unitname} and reservation time: ${reservation_time}

    # Log the time we got in
    Log    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    Log    ${reservation_time}

    # Retrieve all reservation card containers and log their count
    ${containers}=    Browser.Get Elements    [data-testid="reservation-card__container"]
    ${count}=    Get Length    ${containers}
    Log    Found ${count} reservation card containers.

    # Initialize variables to track the last match
    ${match_found}=    Set Variable    False
    ${last_match_index}=    Set Variable    -1

    # Loop through each reservation card container to find matches
    FOR    ${index}    IN RANGE    0    ${count}
        ${name_element}=    Browser.Get Element    ${containers[${index}]} >> [data-testid="reservation-card__name"]
        ${name_text}=    Get Text    ${name_element}
        Log    Checking reservation card at index ${index} with name: ${name_text}

        # Check if the reservation time element exists within the current reservation card.
        ${time_element_exists}=    Run Keyword And Return Status
        ...    Browser.Get Element
        ...    ${containers[${index}]} >> [data-testid="reservation-card__time"]
        ${time_text}=    Set Variable    NONE
        IF    ${time_element_exists}
            ${time_text}=    Get Text    ${containers[${index}]} >> [data-testid="reservation-card__time"]
        END

        # Check if both unit name and reservation time match the target values.
        IF    '${name_text}' == '${unitname}'
            IF    '${time_text}' == '${reservation_time}'
                # Instead of immediately clicking and breaking, store this as the last match
                ${match_found}=    Set Variable    True
                ${last_match_index}=    Set Variable    ${index}
                Log    Found matching reservation at index ${index}, continuing to look for more matches
            END
        END
    END

    # After checking all containers, click the last matching one if any match was found
    IF    ${match_found} == True
        Log    Clicking the last matching reservation at index ${last_match_index}
        Click Show Button    ${containers[${last_match_index}]}
    ELSE
        Fail    No match found for unit name: ${unitname} and reservation time: ${reservation_time}
    END

    Log    Completed validation for reservation card.

Click Show Button
    [Arguments]    ${container}
    Log    Attempting to click the show button inside the container
    ${button_element}=    Browser.Get Element
    ...    ${container} >> [data-testid="reservation-card__button--goto-reservation"]
    Click    ${button_element}
    Log    Successfully clicked the show button

Check unitname and reservation time and verify no cancel button
    [Documentation]    This keyword validates that a reservation card with the specified
    ...    unit name and time exists and fails the test if a cancel button is present.
    [Arguments]    ${unitname}    ${reservation_time}
    Log
    ...    Starting validation for reservation card with unit name: ${unitname} and reservation time: ${reservation_time}
    Log    ${TIME_OF_QUICK_RESERVATION_MINUS_T}
    Log    ${reservation_time}

    # DEVNOTE for testing
    # ${unitname}=    Set Variable    Aina maksullinen Aitio (AUTOMAATIOTESTI ÄLÄ POISTA), Harakka, piilokoju
    # ${reservation_time}=    Set Variable    Ke 24.7.2024 klo 09:30–09:45

    # 1. Source Data Verification
    ${containers}=    Browser.Get Elements    [data-testid="reservation-card__container"]
    ${count}=    Get Length    ${containers}
    Log    Found ${count} reservation card containers.

    # Initialize a flag to track if a match is found
    ${match_found}=    Set Variable    False

    FOR    ${index}    IN RANGE    0    ${count}
        ${name_element}=    Browser.Get Element    ${containers[${index}]} >> [data-testid="reservation-card__name"]
        ${name_text}=    Get Text    ${name_element}
        Log    Checking reservation card at index ${index} with name: ${name_text}

        # 2. Enhanced Logging
        ${time_element_exists}=    Run Keyword And Return Status
        ...    Browser.Get Element
        ...    ${containers[${index}]} >> [data-testid="reservation-card__time"]
        ${time_text}=    Set Variable    NONE
        IF    ${time_element_exists}
            ${time_text}=    Get Text    ${containers[${index}]} >> [data-testid="reservation-card__time"]
        END

        # 3. Boundary Conditions: Ensuring time match
        # Check if both unit name and reservation time match the expected values
        # If any cancel button is found, fail the test
        IF    '${name_text}' == '${unitname}'
            IF    '${time_text}' == '${reservation_time}'
                # Count the number of cancel buttons in the matching container
                ${cancel_button_count}=    Browser.Get Element Count
                ...    ${containers[${index}]} >> [data-testid="reservation-card__button--cancel-reservation"]
                # If any cancel button is found, fail the test
                IF    ${cancel_button_count} > 0
                    Fail
                    ...    Cancel button is present for unit name: ${unitname} and reservation time: ${reservation_time}
                ELSE
                    ${match_found}=    Set Variable    True
                END
                BREAK
            END
        END
    END

    # Check if no match was found, and if so, fail the test
    IF    ${match_found} == False
        Fail    No match found for unit name: ${unitname} and reservation time: ${reservation_time}
    END

    Log    Completed validation for reservation card.

Check unitname and reservation are found
    [Arguments]    ${unitname}    ${reservation_time}
    Log
    ...    Starting validation for reservation card with unit name: ${unitname} and reservation time: ${reservation_time}
    Log
    ...    This keyword uses selectors: [data-testid="reservation-card__name"] and [data-testid="reservation-card__time"]

    # Fetch all elements that match the reservation card container test ID
    ${containers}=    Browser.Get Elements    [data-testid="reservation-card__container"]
    ${count}=    Get Length    ${containers}
    Log    Found ${count} reservation card containers - Starting detailed checks.

    # Initialize a flag to track if a valid match is found
    ${match_found}=    Set Variable    False

    # Loop through each container to check for name and time matches
    FOR    ${index}    IN RANGE    0    ${count}
        ${name_element}=    Browser.Get Element    ${containers[${index}]} >> [data-testid="reservation-card__name"]
        ${name_text}=    Get Text    ${name_element}
        Log    Checking reservation card at index ${index} with name: ${name_text}

        # Check if the time element exists and fetch its text
        ${time_element_exists}=    Run Keyword And Return Status
        ...    Browser.Get Element
        ...    ${containers[${index}]} >> [data-testid="reservation-card__time"]
        ${time_text}=    Set Variable    NONE
        IF    ${time_element_exists}
            ${time_text}=    Get Text    ${containers[${index}]} >> [data-testid="reservation-card__time"]
            Log    Time found at index ${index}: ${time_text}
        ELSE
            Log    No time element found at index ${index}
        END

        # Compare the fetched name and the expected unit name
        ${name_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${name_text}    ${unitname}
        IF    ${name_match}
            Log    Name matches for unit name: ${unitname}

            # If name matches, check the time match
            ${time_match}=    Run Keyword And Return Status
            ...    Should Be Equal As Strings
            ...    ${time_text}
            ...    ${reservation_time}
            IF    ${time_match}
                Log    Match found at index ${index}: ${unitname} at ${reservation_time}

                # Set the match found flag to True and break the loop
                ${match_found}=    Set Variable    True
                BREAK
            ELSE
                Log    Time mismatch at index ${index}. Expected: ${reservation_time}, Found: ${time_text}
            END
        ELSE
            Log    Name mismatch at index ${index}. Expected: ${unitname}, Found: ${name_text}
        END
    END

    # After the loop, check if no valid match was found
    IF    ${match_found} == False
        # Fail the keyword if no match was found, indicating an error or unexpected condition
        Fail    No match found for unit name: ${unitname} and reservation time: ${reservation_time}
    ELSE
        Log    Successfully validated reservation for ${unitname} at ${reservation_time}
    END
    Log    Completed validation for reservation card.

Check unitname and reservation are not found
    [Arguments]    ${unitname}    ${reservation_time}
    # Log the start of the validation process for ensuring the absence of specific reservation details
    Log
    ...    Starting validation for reservation card absence with unit name: ${unitname} and reservation time: ${reservation_time}

    # Log additional debugging information if required
    Log    Current reservation time being validated: ${TIME_OF_QUICK_RESERVATION_MINUS_T}

    # Retrieve all reservation card containers by their test IDs and count them
    ${containers}=    Browser.Get Elements    [data-testid="reservation-card__container"]
    ${count}=    Get Length    ${containers}
    Log    Found ${count} reservation card containers.

    # Initialize a flag to detect any unwanted matches
    ${match_found}=    Set Variable    False

    # Loop through all container elements to check for unwanted name and time matches
    FOR    ${index}    IN RANGE    0    ${count}
        # Retrieve the element containing the reservation name from the current container
        ${name_element}=    Browser.Get Element    ${containers[${index}]} >> [data-testid="reservation-card__name"]
        ${name_text}=    Get Text    ${name_element}

        # Check if a time element exists within the current container and retrieve its text if present
        ${time_element_exists}=    Run Keyword And Return Status
        ...    Browser.Get Element
        ...    ${containers[${index}]} >> [data-testid="reservation-card__time"]
        ${time_text}=    Set Variable    NONE
        IF    ${time_element_exists}
            ${time_text}=    Get Text    ${containers[${index}]} >> [data-testid="reservation-card__time"]
        END

        # Log the name and time retrieved for debugging purposes
        Log    Checking reservation card: Name - ${name_text}, Time - ${time_text}

        # Check if the retrieved name matches the expected unit name (it shouldn't)
        ${condition}=    Run Keyword And Return Status    Should Not Be Equal As Strings    ${name_text}    ${unitname}
        IF    ${condition} == False
            # If the name matches, further check if the retrieved time also matches the expected reservation time
            ${condition_time}=    Run Keyword And Return Status
            ...    Should Not Be Equal As Strings
            ...    ${time_text}
            ...    ${reservation_time}
            IF    ${condition_time} == False
                # If both name and time match, log the issue and set the match_found flag to True
                Log    Unexpected match found: Name - ${name_text}, Time - ${time_text}
                ${match_found}=    Set Variable    True
                BREAK    # Exit the loop as an unexpected match has been found
            END
        END
    END

    # After completing the loop, check if any matches were found
    IF    ${match_found} == True
        # Fail the test if a match was found, logging the details of the unexpected match
        Fail
        ...    Match found for unit name: ${unitname} and reservation time: ${reservation_time}. Test should not find them.
    END

    # Log completion of the check for the absence of the reservation card
    Log    Completed validation for reservation card absence.

###
###MOBILE
###
