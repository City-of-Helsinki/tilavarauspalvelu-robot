*** Settings ***
Documentation       A resource file with keywords.

Resource            variables.robot
Resource            texts_FI.robot
Library             Browser
Library             DateTime
Library             OperatingSystem
Library             python_keywords.py
Library             String
Library             Collections


*** Keywords ***
Find And Click Element With Text
    [Documentation]    This keyword searches for an element containing the specified text within a list of elements identified by the given selector.
    [Arguments]    ${element_with_text}    ${wanted_text}

    Log    Searching for ${element_with_text} with text: ${wanted_text}
    ${elements_with_text}=    Browser.Get Elements    ${element_with_text}
    ${found}=    Set Variable    False    # Initialize a flag to track if the element is found

    FOR    ${element}    IN    @{elements_with_text}
        ${el_text}=    Get Text    ${element}
        ${el_text}=    Strip String    ${el_text}    # Remove leading and trailing whitespaces for webkit
        Log    element is: ${element}
        Log    Text found in element: ${el_text}

        IF    $el_text == $wanted_text
            Click    ${element}
            Log    Element with text "${wanted_text}" clicked.
            ${found}=    Set Variable    True    # Set the flag to True since the element is found and clicked
            BREAK
        END
    END

    # Fail the test if no element was found
    IF    not ${found}    Fail    Element with text "${wanted_text}" not found

Verify Element With Text Is Not Found
    [Documentation]    This keyword verifies that an element containing the specified text is NOT found within a list of elements identified by the given selector.
    [Arguments]    ${element_with_text}    ${wanted_text}

    Log    Verifying that ${element_with_text} with text: ${wanted_text} is NOT found
    ${elements_with_text}=    Browser.Get Elements    ${element_with_text}
    ${found}=    Set Variable    False    # Initialize a flag to track if the element is found

    FOR    ${element}    IN    @{elements_with_text}
        ${el_text}=    Get Text    ${element}
        ${el_text}=    Strip String    ${el_text}    # Remove leading and trailing whitespaces for webkit
        Log    element is: ${element}
        Log    Text found in element: ${el_text}

        IF    $el_text == $wanted_text
            Log    Element with text "${wanted_text}" found when it should not be.
            ${found}=    Set Variable    True    # Set the flag to True since the element is found
            BREAK
        END
    END

    # Fail the test if the element WAS found (opposite of the original keyword)
    IF    ${found}
        Fail    Element with text "${wanted_text}" was found but should not be present
    END

Verify Element Is Not Found
    [Documentation]    This keyword verifies that an element identified by the given selector is NOT found on the page.
    [Arguments]    ${element_selector}

    Log    Verifying that element ${element_selector} is NOT found
    ${element_count}=    Browser.Get Element Count    ${element_selector}
    Log    Element count: ${element_count}

    # Fail the test if the element WAS found
    IF    ${element_count} > 0
        Fail    Element "${element_selector}" was found but should not be present (count: ${element_count})
    END

    Log    Element "${element_selector}" is correctly not present on the page

Verify Element Is Found
    [Documentation]    This keyword verifies that an element identified by the given selector IS found on the page.
    [Arguments]    ${element_selector}

    Log    Verifying that element ${element_selector} IS found
    ${element_count}=    Browser.Get Element Count    ${element_selector}
    Log    Element count: ${element_count}

    # Fail the test if the element was NOT found
    IF    ${element_count} == 0
        Fail    Element "${element_selector}" was not found but should be present
    END

    Log    Element "${element_selector}" is correctly present on the page (count: ${element_count})

Find And Click Element With Exact Text Using JS
    [Arguments]    ${element_with_text}    ${wanted_text}
    Log    Searching for element with text: ${wanted_text}
    ${elements_with_text}=    Browser.Get Elements    ${element_with_text}
    ${found}=    Set Variable    False    # Initialize a flag to track if the element is found

    FOR    ${element}    IN    @{elements_with_text}
        ${el_text}=    Get Text    ${element}
        Log    element is: ${element}
        Log    Text found in element: ${el_text}

        IF    "${el_text}" == "${wanted_text}"
            Evaluate JavaScript    ${element}    (element) => element.click()
            Log    Element with text "${wanted_text}" clicked using JavaScript.
            ${found}=    Set Variable    True    # Set the flag to True since the element is found and clicked
            BREAK
        END
    END

    # Fail the test if no element was found
    IF    not ${found}    Fail    Element with text "${wanted_text}" not found

Find And Click Element With Partial Text Using JS
    [Documentation]    Finds an element containing the specified partial text and clicks it using JavaScript.
    [Arguments]    ${element}    ${partial_text}

    # Get all matching elements based on the selector
    ${elements}=    Browser.Get Elements    ${element}
    ${element_count}=    Evaluate    len(${elements})
    Log    Found ${element_count}

    # Initialize variable to track if we clicked an element
    ${clicked}=    Set Variable    False

    # Loop through each element to find matching elements with the partial text
    FOR    ${e}    IN    @{elements}
        ${text}=    Browser.Get Text    ${e}

        # Remove non-breaking spaces for accurate text comparison
        ${clean_text}=    custom_keywords.Remove Non-breaking Space    ${text}

        # Log for troubleshooting
        Log    Cleaned Text: ${clean_text}

        # Check if the cleaned text contains the partial text
        ${is_match}=    Evaluate    '${partial_text}' in '''${clean_text}'''

        # Click if a match is found and immediately break the loop
        IF    ${is_match}
            Evaluate JavaScript    ${e}    (element) => element.click()
        END
        IF    ${is_match}    Set Variable    ${clicked}    True
        IF    ${is_match}    BREAK
    END

    # Log if no match was found
    IF    not ${clicked}
        Log    No element with text '${partial_text}' was found to click.
    END

Find And Click Element In Card Element By Text
    [Documentation]    For each element matching ${card_element}, checks if it contains a child
    ...    ${text_element} with text ${text}. If so, clicks ${element_to_click} inside that card.
    [Arguments]    ${card_element}    ${text_element}    ${text}    ${element_to_click}

    Log    Searching for cards: ${card_element}
    ${cards}=    Browser.Get Elements    ${card_element}
    ${count}=    Get Length    ${cards}
    Log    Found ${count} card containers.
    ${found}=    Set Variable    False

    FOR    ${index}    IN RANGE    0    ${count}
        Log    Checking card at index ${index}

        # Check if text element exists within the current card
        ${text_element_exists}=    Run Keyword And Return Status
        ...    Browser.Get Element
        ...    ${cards[${index}]} >> ${text_element}

        IF    ${text_element_exists}
            ${el_text}=    Get Text    ${cards[${index}]} >> ${text_element}
            ${el_text}=    Strip String    ${el_text}
            Log    Found text in card: ${el_text}

            IF    "${el_text}" == "${text}"
                Log    Found matching text '${text}' in card at index ${index}
                # Found the card with the desired text, now click the target element inside this card
                Click    ${cards[${index}]} >> ${element_to_click}
                Log    Clicked element '${element_to_click}' in card containing text '${text}'
                ${found}=    Set Variable    True
                BREAK
            END
        END
    END

    IF    not ${found}
        Fail    No card element found with text '${text}' in '${text_element}'
    END

Find And Click Button In Group With Matching Conditions
    [Documentation]    Finds a group wrapper containing specified text, then searches for card elements
    ...    within that group. For each card, checks if the heading and tags elements contain
    ...    specified text. If both conditions are met, clicks the specified button.
    [Arguments]
    ...    ${group_wrapper_selector}
    ...    ${group_text}
    ...    ${card_selector}
    ...    ${heading_selector}
    ...    ${heading_text}
    ...    ${tags_selector}
    ...    ${tags_text}
    ...    ${button_text}

    Log    Searching for group wrapper containing "${group_text}"

    # Find all group wrappers
    ${group_wrappers}=    Browser.Get Elements    ${group_wrapper_selector}
    ${group_count}=    Get Length    ${group_wrappers}
    Log    Found ${group_count} group wrappers.

    ${target_group_wrapper}=    Set Variable    ${None}
    ${found_target_group}=    Set Variable    False

    # Find the target group wrapper with specified text
    FOR    ${wrapper}    IN    @{group_wrappers}
        ${wrapper_text}=    Get Text    ${wrapper}
        ${wrapper_text}=    Strip String    ${wrapper_text}
        Log    Checking group wrapper text: ${wrapper_text}

        ${contains_group_text}=    Evaluate    '${group_text}' in '''${wrapper_text}'''
        IF    ${contains_group_text}
            ${target_group_wrapper}=    Set Variable    ${wrapper}
            ${found_target_group}=    Set Variable    True
            Log    Found target group wrapper containing "${group_text}"
            BREAK
        END
    END

    IF    not ${found_target_group}
        Fail    No group wrapper found containing "${group_text}" text
    END

    # Find card elements within the target group wrapper and reverse to find last match efficiently
    ${card_contents}=    Browser.Get Elements    ${target_group_wrapper} >> ${card_selector}
    ${card_count}=    Get Length    ${card_contents}
    Log    Found ${card_count} card elements in target group.

    # Reverse the list to find the last matching card with early termination
    Reverse List    ${card_contents}

    ${matching_card}=    Set Variable    ${None}
    ${found_match}=    Set Variable    False

    FOR    ${card}    IN    @{card_contents}
        ${is_match}=    custom_keywords.Card Matches
        ...    ${card}
        ...    ${heading_selector}
        ...    ${heading_text}
        ...    ${tags_selector}
        ...    ${tags_text}
        IF    ${is_match}
            ${matching_card}=    Set Variable    ${card}
            ${found_match}=    Set Variable    True
            Log    Found last matching card (first match in reversed list)
            BREAK
        END
    END

    IF    not ${found_match}
        Fail
        ...    No card found with matching conditions: heading contains '${heading_text}' and tags contain '${tags_text}'
    END

    # Click the button in the matching card
    custom_keywords.Click Button In Card    ${matching_card}    ${button_text}

Card Matches
    [Documentation]    Check if a card matches both heading and tags text criteria
    [Arguments]    ${card}    ${heading_selector}    ${heading_text}    ${tags_selector}    ${tags_text}

    # Check heading text contains the expected text
    ${heading_contains}=    Check Element Contains Text
    ...    ${card} >> ${heading_selector}
    ...    ${heading_text}
    ...    return_status=True
    IF    not ${heading_contains}    RETURN    False

    # Check tags text contains the expected text
    ${tags_contains}=    Check Element Contains Text
    ...    ${card} >> ${tags_selector}
    ...    ${tags_text}
    ...    return_status=True
    RETURN    ${tags_contains}

Click Button In Card
    [Documentation]    Helper keyword to find and click a button with specific text in a card
    [Arguments]    ${card}    ${button_text}

    ${buttons}=    Browser.Get Elements    ${card} >> button
    ${button_count}=    Get Length    ${buttons}
    Log    Found ${button_count} buttons in card

    FOR    ${button}    IN    @{buttons}
        ${text_matches}=    Check Elements Text    ${button}    ${button_text}    return_status=True
        IF    ${text_matches}
            Click    ${button}
            Log    Clicked "${button_text}" button successfully
            RETURN
        END
    END

    Fail    No "${button_text}" button found in card

Verify Card Not Found In Group With Matching Conditions
    [Documentation]    Verifies that a specific empty state message is displayed in the application.
    ...
    ...    0. Before test runs: User data is set so there are NO other applications - everything is empty
    ...    1. The test creates exactly 1 application
    ...    2. The test then cancels that 1 application
    ...    3. After cancellation, there should be NO other applications remaining
    ...    4. An appropriate empty state message should be displayed
    [Arguments]
    ...    ${empty_state_message}

    Log    Starting verification for empty state message: "${empty_state_message}"
    Log    Context: Test creates 1 application, cancels it, then verifies no applications remain

    # Get all elements that could contain the message
    ${message_selector}=    Set Variable    id=main >> span
    ${message_elements}=    Browser.Get Elements    ${message_selector}
    ${element_count}=    Get Length    ${message_elements}

    IF    ${element_count} == 0
        Fail    No message elements found using selector: ${message_selector}
    END

    Log    Found ${element_count} potential message element(s) to check

    # Check if any element contains the expected message
    ${message_found}=    Set Variable    False
    ${found_text}=    Set Variable    ${EMPTY}

    FOR    ${element}    IN    @{message_elements}
        ${element_text}=    Get Text    ${element}
        ${element_text}=    Strip String    ${element_text}

        # Check for exact match
        IF    '${element_text}' == '${empty_state_message}'
            ${message_found}=    Set Variable    True
            ${found_text}=    Set Variable    ${element_text}
            Log    SUCCESS: Found expected empty state message: "${empty_state_message}"
            RETURN
        END
    END

    # If message not found, raise error (message should exist after cancellation)
    Fail
    ...    Expected empty state message "${empty_state_message}" not found. This indicates applications still exist after cancellation, but none should remain.

Find Text From Elements Or Fail
    [Arguments]    ${element_with_text}    ${wanted_text}
    Log    Searching for text: ${wanted_text}
    ${elements_with_text}=    Browser.Get Elements    ${element_with_text}
    ${text_found}=    Set Variable    False    # Initialize the flag to False

    FOR    ${element}    IN    @{elements_with_text}
        ${el_text}=    Get Text    ${element}
        ${el_text_clean}=    Strip String    ${el_text}
        ${wanted_text_clean}=    Strip String    ${wanted_text}
        Log    Found text in element (cleaned): ${el_text_clean}

        IF    '${el_text_clean}' == '${wanted_text_clean}'
            Log    Found element with text: "${wanted_text_clean}."
            ${text_found}=    Set Variable    True    # Set the flag to True when text is found
            BREAK
        END
    END

    IF    not ${text_found}
        Fail    "Text '${wanted_text}' not found in any given elements."
    END

Find Text Element From Elements
    [Arguments]    ${element_with_text}    ${wanted_text}

    Log    Searching for text: ${wanted_text}
    ${elements_with_text}=    Browser.Get Elements    ${element_with_text}
    ${text_found}=    Set Variable    False    # Initialize the flag to False

    FOR    ${element}    IN    @{elements_with_text}
        ${el_text}=    Get Text    ${element}
        ${el_text}=    Strip String    ${el_text}
        ${wanted_text}=    Strip String    ${wanted_text}
        Log    Found text in element: ${el_text}

        IF    "${el_text}" == "${wanted_text}"
            Log    Found element with text "${wanted_text}."
            ${text_found}=    Set Variable    True    # Set the flag to True when text is found
            RETURN    ${element}    # Return the matching element
        END
    END

    IF    not ${text_found}
        Log    "Text '${wanted_text}' not found in any given elements."
        RETURN    False
    END

Remove Non-breaking Space
    [Arguments]    ${string}
    Log    Original string: '${string}'
    ${string}=    Evaluate    re.sub(r'[\xa0\u200b\u200c\u200d\u202f]', ' ', '''${string}''').strip()    re

    Log    Normalized string: '${string}'
    RETURN    ${string}

Check Number From Text Is Equal To
    [Documentation]    Verifies if a number extracted from the specified text element matches the expected value.
    [Arguments]    ${text_element}    ${number_equalTo}
    Log    ${number_equalTo}
    Wait For Elements State    ${text_element}    visible
    ${number_element_string}=    Get Text    ${text_element}
    Log    ${number_element_string}
    ${number_element_string_num_only}=    Replace String Using Regexp    ${number_element_string}    [^0-9]    ${EMPTY}

    ${NUM_FROM_TXT}=    Set Variable    ${number_element_string_num_only}
    Log    ${NUM_FROM_TXT}
    Should Be Equal    ${NUM_FROM_TXT}    ${number_equalTo}

Check Number From Text Is Not Equal To
    [Documentation]    Verifies if a number extracted from the specified text element does NOT match the expected value.
    [Arguments]    ${text_element}    ${number_notEqualTo}
    Log    Expected number should NOT be: ${number_notEqualTo}
    Wait For Elements State    ${text_element}    visible
    ${number_element_string}=    Get Text    ${text_element}
    Log    Original text from element: ${number_element_string}
    ${number_element_string_num_only}=    Replace String Using Regexp    ${number_element_string}    [^0-9]    ${EMPTY}
    ${NUM_FROM_TXT}=    Set Variable    ${number_element_string_num_only}
    Log    Extracted number: ${NUM_FROM_TXT}
    Should Not Be Equal    ${NUM_FROM_TXT}    ${number_notEqualTo}
    Log    ✓ Numbers are different: ${NUM_FROM_TXT} != ${number_notEqualTo}

Get Number From Element Text
    [Documentation]    Extracts only numeric characters from an element's text and returns the number.
    ...    Returns empty string if no numbers are found.
    [Arguments]    ${text_element}
    Wait For Elements State    ${text_element}    visible
    ${element_text}=    Get Text    ${text_element}
    Log    Original text: ${element_text}
    ${numbers_only}=    Replace String Using Regexp    ${element_text}    [^0-9]    ${EMPTY}
    Log    Extracted numbers: ${numbers_only}
    RETURN    ${numbers_only}

Check Elements Text With Remove Non-breaking Space
    [Arguments]    ${Element}    ${Expected text}

    Sleep    2s
    Log    Element: ${Element}
    Log    Expected text: ${Expected text}

    # Wait until the element is visible on the page
    Wait For Elements State    ${Element}    visible

    # Retrieve the text content of the element
    ${Elements_text}=    Get Text    ${Element}

    # Normalize the element's text by removing non-breaking spaces
    ${Elements_text}=    custom_keywords.Remove Non-breaking Space    ${Elements_text}

    # Final text comparison
    Should Be Equal    ${Elements_text}    ${Expected text}

Check Text Of Element With Normalization And Logging To File
    [Documentation]    Compares the text content of an element with the expected text
    ...    normalizes it, and logs differences if mismatched.
    [Arguments]    ${Element}    ${Expected text}

    Sleep    1s
    Log    Element: ${Element}
    Log    Expected text: ${Expected text}

    # Wait until the element is visible on the page
    Wait For Elements State    ${Element}    visible

    # Retrieve the text content of the element
    ${Elements_text}=    Get Text    ${Element}
    Log    Retrieved text: ${Elements_text}

    # Initial text comparison
    ${status}    ${message}=    Run Keyword And Ignore Error
    ...    Should Be Equal
    ...    ${Elements_text}
    ...    ${Expected text}

    Log    Initial comparison status: ${status}, message: ${message}

    # If texts match, stop execution here
    IF    "${status}" == "PASS"
        Log    Texts match. Test passes.
        RETURN
    END

    # If texts do not match, perform normalization
    Log    Texts do not match. Attempting normalization.

    # Normalize the actual elements text by removing non-breaking spaces
    ${Elements_text}=    custom_keywords.Remove Non-breaking Space    ${Elements_text}

    Log    After normalization, actual text: ${Elements_text}, expected text: ${Expected text}

    # Compare again after normalization
    ${status}    ${message}=    Run Keyword And Ignore Error
    ...    Should Be Equal
    ...    ${Elements_text}
    ...    ${Expected text}

    Log    Comparison status after normalization: ${status}, message: ${message}

    # If texts match after normalization, stop execution here
    IF    "${status}" == "PASS"
        Log    Texts match after normalization. Test passes.
        RETURN
    END

    # If texts still do not match, log the differences
    Log    Texts still do not match after normalization.

    # Log differences using the Python function
    ${differences}=    python_keywords.Log Differences    ${Elements_text}    ${Expected text}

    # Get the timestamp
    ${timestamp}=    Get Time    format=timestamp

    # Create the header
    ${header}=    Set Variable    Test Name: ${TEST NAME}\nTimestamp: ${timestamp}\nDifferences:\n

    # Format the differences
    ${formatted_differences}=    Evaluate
    ...    "\\n".join([\"Position: {0} | Elements Text: {1} | Expected Text: {2}\".format(diff['position'], diff['elementsText'], diff['expectedText']) for diff in ${differences}])

    # Combine header and differences
    ${content}=    Set Variable    ${header}${formatted_differences}

    # Write to file
    Append To File    debug_${TEST NAME}.txt    ${content}

    # Fail the test with a descriptive message
    Fail    Texts still do not match after normalization. Differences logged to debug_${TEST NAME}.txt.

Check Elements Text
    [Documentation]    Checks element text with automatic space stripping and flexible comparison options
    [Arguments]
    ...    ${Element}
    ...    ${Expected text}
    ...    ${strip_spaces}=True
    ...    ${ignore_case}=False
    ...    ${return_status}=False
    ...    ${message}=${NONE}

    Sleep    1s
    Log    Element: ${Element}
    Log    Expected text: ${Expected text}

    # Wait until the element is visible on the page
    Wait For Elements State    ${Element}    visible    timeout=10s

    # Retrieve the text content of the element
    ${Elements_text}=    Get Text    ${Element}

    # Determine the error message to use
    ${default_msg}=    Set Variable    Element text does not match. Element: ${Element}
    ${final_msg}=    Set Variable If    "${message}" != "${NONE}"    ${message}    ${default_msg}

    # Return status boolean for loops vs fail test for assertions
    IF    ${return_status}
        ${status}=    Run Keyword And Return Status
        ...    Should Be Equal    ${Elements_text}    ${Expected text}
        ...    strip_spaces=${strip_spaces}    ignore_case=${ignore_case}
        ...    msg=${final_msg}
        RETURN    ${status}
    ELSE
        Should Be Equal    ${Elements_text}    ${Expected text}
        ...    strip_spaces=${strip_spaces}    ignore_case=${ignore_case}
        ...    msg=${final_msg}
    END

Check Element Contains Text
    [Documentation]    Checks if element text contains expected text using Should Contain
    [Arguments]
    ...    ${Element}
    ...    ${Expected text}
    ...    ${strip_spaces}=True
    ...    ${ignore_case}=False
    ...    ${return_status}=False

    Sleep    1s
    Log    Element: ${Element}
    Log    Expected text: ${Expected text}

    # Wait until the element is visible on the page
    Wait For Elements State    ${Element}    visible    timeout=10s

    # Retrieve the text content of the element
    ${Elements_text}=    Get Text    ${Element}

    # Return status boolean for loops vs fail test for assertions
    IF    ${return_status}
        ${status}=    Run Keyword And Return Status
        ...    Should Contain    ${Elements_text}    ${Expected text}
        ...    strip_spaces=${strip_spaces}    ignore_case=${ignore_case}
        ...    msg=Element text does not contain expected text
        RETURN    ${status}
    ELSE
        Should Contain    ${Elements_text}    ${Expected text}
        ...    strip_spaces=${strip_spaces}    ignore_case=${ignore_case}
        ...    msg=Element text does not contain expected text. Element: ${Element}
    END

###
# Calendar extraction
###

Convert Booking Time To ICS Format
    [Documentation]    Converts a booking time string to ICS format with time zone information.
    [Arguments]    ${time_string}

    # Check System Time Zone
    ${timezone}=    Evaluate    datetime.datetime.now().astimezone().tzname()
    Log    Current system time zone is: ${timezone}
    Log    This is the timeslot ${time_string}

    # Convert booking time to ICS format using the Python function
    ${ics_start}    ${ics_end}=    Convert Booking Time To Ics    ${time_string}
    Log    ICS Start Time: ${ics_start}
    Log    ICS End Time: ${ics_end}
    Set Suite Variable    ${FORMATTED_START_TO_ICS}    ${ics_start}
    Set Suite Variable    ${FORMATTED_END_TO_ICS}    ${ics_end}

Extract Start And End Time From ICS File
    [Arguments]    ${text_from_ics_file}

    # Log the ICS text for debugging
    Log    ICS Text: ${text_from_ics_file}

    # For testing
    # ${text_from_ics_file}=    Set Variable    asdfasfasdf_DTSTART;TZID=America/New_York:20241003T083000..werwer_DTEND;TZID=America/New_York:20241003T093000

    # Targets the event-specific DTSTART and DTEND lines with TZID.
    ${dtstart_pattern}=    Set Variable    DTSTART;TZID=Europe/Helsinki:[0-9]{8}T[0-9]{6}
    ${dtend_pattern}=    Set Variable    DTEND;TZID=Europe/Helsinki:[0-9]{8}T[0-9]{6}

    # Find all matches in the ICS text
    ${dtstart_matches}=    Get Regexp Matches    ${text_from_ics_file}    ${dtstart_pattern}
    ${dtend_matches}=    Get Regexp Matches    ${text_from_ics_file}    ${dtend_pattern}

    # Check if matches are found and directly use the first match for DTSTART and DTEND
    IF    len(${dtstart_matches}) == 0
        Fail    No DTSTART matches found in the text
    END
    IF    len(${dtend_matches}) == 0
        Fail    No DTEND matches found in the text
    END

    ${start_match}=    Get From List    ${dtstart_matches}    0
    ${end_match}=    Get From List    ${dtend_matches}    0
    Log    Start match: ${start_match} and End match: ${end_match}

    # Set the extracted matches as suite variables
    Set Suite Variable    ${START_TIME_FROM_ICS}    ${start_match}
    Set Suite Variable    ${END_TIME_FROM_ICS}    ${end_match}

    # Log the variables for confirmation
    Log    Start datetime: ${START_TIME_FROM_ICS}
    Log    End datetime: ${END_TIME_FROM_ICS}

Verify Reservation Slot Exists
    [Documentation]    Checks that a given weekday's column in the calendar contains
    ...    an event label exactly matching the specified time.
    [Arguments]    ${TIME_TO_CHECK}    ${DAY_TO_CHECK}

    # normalize search key
    ${normTime}=    Replace String    ${TIME_TO_CHECK}    –    -
    ${normTime}=    Replace String    ${normTime}    —    -
    ${normTime}=    Replace String    ${normTime}    ${SPACE}    ${EMPTY}
    Log    Normalized search ➔ ${normTime}

    # pick correct column index
    VAR    @{days}    Monday    Tuesday    Wednesday    Thursday    Friday    Saturday    Sunday
    ${dayIdx}=    Get Index From List    ${days}    ${DAY_TO_CHECK}
    Should Be True    ${dayIdx} >= 0    msg=Day "${DAY_TO_CHECK}" not found
    Log    Checking column index ${dayIdx + 2}

    ${labels}=    Browser.Get Elements
    ...    css=.rbc-time-column:nth-child(${dayIdx + 2}) .rbc-events-container .rbc-event-label
    ${count}=    Get Length    ${labels}
    Log    Found ${count} label(s) on ${DAY_TO_CHECK}
    Should Be True    ${count} > 0    msg=No reservation labels found. There should be at least one ${DAY_TO_CHECK}

    # initialize found so it always exists
    Set Test Variable    ${found}    ${False}

    FOR    ${lbl}    IN    @{labels}
        ${txt}=    Get Text    ${lbl}
        ${txt}=    Replace String    ${txt}    –    -
        ${txt}=    Replace String    ${txt}    —    -
        ${txt}=    Replace String    ${txt}    ${SPACE}    ${EMPTY}
        Log    Normalized label ➔ ${txt}
        IF    '${txt}' == '${normTime}'
            Set Test Variable    ${found}    ${True}
            Log    Match found!
            BREAK
        END
    END

    Log    Final result: ${found}
    Should Be True    ${found}    msg=Reservation not found for ${DAY_TO_CHECK} at ${TIME_TO_CHECK}

###
# Calendar extraction
###
