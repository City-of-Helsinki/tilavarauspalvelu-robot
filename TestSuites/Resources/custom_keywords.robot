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
Find and click element with text
    [Documentation]    This keyword searches for an element containing the specified text within a list of elements identified by the given selector.
    [Arguments]    ${element_with_text}    ${wanted_text}

    Log    Searching for ${element_with_text} with text: ${wanted_text}
    ${elements_with_text}=    Browser.Get Elements    ${element_with_text}
    ${found}=    Set Variable    False    # Initialize a flag to track if the element is found

    FOR    ${element}    IN    @{elements_with_text}
        ${el_text}=    Get Text    ${element}
        Log    element is: ${element}
        Log    Text found in element: ${el_text}

        IF    "${el_text}" == "${wanted_text}"
            Click    ${element}
            Log    Element with text "${wanted_text}" clicked.
            ${found}=    Set Variable    True    # Set the flag to True since the element is found and clicked
            BREAK
        END
    END

    # Fail the test if no element was found
    IF    not ${found}    Fail    Element with text "${wanted_text}" not found

Find and click element with exact text using JS
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

Find and click element with partial text using JS
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
        ${clean_text}=    custom_keywords.Remove non-breaking space    ${text}

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

Find text from elements or fail
    [Arguments]    ${element_with_text}    ${wanted_text}
    Log    Searching for text: ${wanted_text}
    ${elements_with_text}=    Browser.Get Elements    ${element_with_text}
    ${text_found}=    Set Variable    False    # Initialize the flag to False

    FOR    ${element}    IN    @{elements_with_text}
        ${el_text}=    Get Text    ${element}
        Log    Found text in element: ${el_text}

        IF    "${el_text}" == "${wanted_text}"
            Log    Found element with text: "${wanted_text}."
            ${text_found}=    Set Variable    True    # Set the flag to True when text is found
            BREAK
        END
    END

    IF    not ${text_found}
        Fail    "Text '${wanted_text}' not found in any given elements."
    END

Find text element from elements
    # TODO check if can use Get Element By    selection_strategy    text
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

Remove non-breaking space
    [Arguments]    ${string}
    Log    Original string: '${string}'
    ${string}=    Evaluate    re.sub(r'[\xa0\u200b\u200c\u200d\u202f]', ' ', '''${string}''').strip()    re

    Log    Normalized string: '${string}'
    RETURN    ${string}

Check number from text is equal to
    [Documentation]    Verifies if a number extracted from the specified text element matches the expected value.
    [Arguments]    ${text_element}    ${number_equalTo}
    Log    ${number_equalTo}
    Wait For Elements State    ${text_element}    visible
    ${number_element_string}=    Get text    ${text_element}
    Log    ${number_element_string}
    ${number_element_string_num_only}=    Replace String Using Regexp    ${number_element_string}    [^0-9]    ${EMPTY}

    ${NUM_FROM_TXT}=    Set Variable    ${number_element_string_num_only}
    Log    ${NUM_FROM_TXT}
    Should Be Equal    ${NUM_FROM_TXT}    ${number_equalTo}

Check elements text with remove non-breaking space
    [Arguments]    ${Element}    ${Expected text}

    Sleep    2s
    Log    Element: ${Element}
    Log    Expected text: ${Expected text}

    # Wait until the element is visible on the page
    Wait For Elements State    ${Element}    visible

    # Retrieve the text content of the element
    ${Elements_text}=    Get Text    ${Element}

    # Normalize the element's text by removing non-breaking spaces
    ${Elements_text}=    custom_keywords.Remove non-breaking space    ${Elements_text}

    # Final text comparison
    Should Be Equal    ${Elements_text}    ${Expected text}

Check text of element with normalization and logging to file
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
    ${Elements_text}=    custom_keywords.Remove non-breaking space    ${Elements_text}

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
    ${differences}=    python_keywords.log_differences    ${Elements_text}    ${Expected text}

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

Check elements text
    [Arguments]    ${Element}    ${Expected text}

    Sleep    1s
    Log    Element: ${Element}
    Log    Expected text: ${Expected text}

    # Wait until the element is visible on the page
    Wait For Elements State    ${Element}    visible

    # Retrieve the text content of the element
    ${Elements_text}=    Get Text    ${Element}

    # Final text comparison
    Should Be Equal    ${Elements_text}    ${Expected text}

###
# Calendar extraction
# Format time of the booking to ICS
###

Convert booking time to ICS format
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

###
# Calendar extraction
# Extract time from downloaded file
###

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

###
# Calendar extraction
###

###
# Mail UI
###
# TODO these are wip. The mail ui part maybe deleted in future

# Click mail with title
#    [Arguments]    ${partial_text}
#
#    # Select the last tbody directly
#    ${last_tbody}=    Browser.Get Element    css=tbody >> nth=-1
#
#    # Find all <tr> elements in the last <tbody>
#    ${tr_elements}=    Browser.Get Elements    ${last_tbody} >> css=tr
#    ${tr_count}=    Evaluate    len(${tr_elements})
#    Log    Found ${tr_count} <tr> elements inside the last <tbody>.
#
#    # Initialize a flag to track if the element is found
#    ${clicked}=    Set Variable    False
#
#    # Loop through each <tr> and find matching <span> elements with the partial text
#    FOR    ${tr}    IN    @{tr_elements}
#    ${spans}=    Browser.Get Elements    ${tr} >> css=span
#    FOR    ${span}    IN    @{spans}
#    ${text}=    Browser.Get Text    ${span}
#    ${clean_text}=    custom_keywords.Remove non-breaking space    ${text}
#
#    # Log the clean_text for troubleshooting
#    Log    Cleaned Text: ${clean_text}
#
#    # Check if the clean_text contains the partial text
#    ${is_match}=    Evaluate    '${partial_text}' in '''${clean_text}'''
#
#    # For logs
#    IF    ${is_match}    Log    Found match: ${clean_text}
#
#    # Force click using JavaScript if match is found and set `${clicked}` to `True`
#    IF    ${is_match}
#    Evaluate JavaScript    ${span}    (element) => element.click()
#    ${clicked}=    Set Variable    True
#    Log    Clicked set to: ${clicked}
#    BREAK
#    END
#    END
#    IF    ${clicked}    BREAK
#    END
#    Log    clicked value: ${clicked}
#
#    # Log if no match was found
#    IF    not ${clicked}
#    Fail    No element with text "${partial_text}" was found to click.
#    END
#
# Get text content from mail
#    [Arguments]    ${unit_name}
#    ${result}=    Evaluate JavaScript
#    ...    ${None}
#    ...    function() {
#    ...    let matchingTbody = null;
#    ...    const tbodies = document.querySelectorAll("tbody");
#    ...
#    ...    tbodies.forEach(tbody => {
#    ...    if (tbody.textContent.includes(arguments[0])) {
#    ...    matchingTbody = tbody;
#    ...    }
#    ...    });
#    ...
#    ...    let elementTexts = [];
#    ...    if (matchingTbody) {
#    ...    const elements = matchingTbody.querySelectorAll("td, span, p, b");
#    ...    elements.forEach(element => {
#    ...    elementTexts.push(element.textContent.trim());
#    ...    });
#    ...    } else {
#    ...    console.log("No matching tbody found with the specified text.");
#    ...    }
#    ...    return elementTexts;
#    ...    }
#    ...    arg=${UNIT_NAME}
#
#    Log    ${result}
#    RETURN    ${result}

###
#
###
