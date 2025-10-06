*** Settings ***
Documentation       Create robot test data for Harakka via API endpoint.
...                 This is used for creating the necessary test data for test execution.

Library             RequestsLibrary
Library             Collections
Library             OperatingSystem


*** Variables ***
${BASE_URL}             https://varaamo.test.hel.ninja
${TOKEN}                ${EMPTY}
${ENDPOINT}             ${EMPTY}
${MAX_RETRIES}          2
${RETRY_DELAY}          60    # seconds

# Default values for fallback
${DEFAULT_ENDPOINT}     /v1/create_robot_test_data/


*** Keywords ***
Create robot test data
    [Documentation]    Calls the endpoint to Create robot test data.
    [Timeout]    5 minutes

    # Temporarily suppress logging
    ${original_log_level}=    Set Log Level    NONE

    # Retrieve token from variables or environment
    ${token_from_env}=    Get Environment Variable    ROBOT_API_TOKEN    default=${EMPTY}
    ${token}=    Set Variable If    "${TOKEN}"!=""    ${TOKEN}    ${token_from_env}

    # Create headers with token
    ${headers}=    Create Dictionary
    ...    Authorization=${token}
    ...    Content-Type=application/json
    ...    X-Robot-API-Secret=${token}

    # Restore original log level after all sensitive operations
    Set Log Level    ${original_log_level}

    IF    "${token}" == ""
        Fail    ROBOT_API_TOKEN not provided in TOKEN variable nor env ROBOT_API_TOKEN
    END

    # Get endpoint from environment variable or use default
    ${endpoint_from_env}=    Get Environment Variable    ROBOT_API_ENDPOINT    default=${EMPTY}
    ${endpoint}=    Set Variable If    "${ENDPOINT}"!=""    ${ENDPOINT}    ${endpoint_from_env}
    ${endpoint}=    Set Variable If    "${endpoint}"!=""    ${endpoint}    ${DEFAULT_ENDPOINT}

    Log    Creating robot test data
    Log    URL: ${BASE_URL}${endpoint}

    # Create session
    Create Session    api    ${BASE_URL}    verify=${True}

    # Try to create the test data with retries
    FOR    ${attempt}    IN RANGE    1    ${MAX_RETRIES}+1
        Log    Attempt ${attempt} of ${MAX_RETRIES}

        # Suppress logging during POST request to avoid logging sensitive headers
        ${current_log_level}=    Set Log Level    WARN
        ${status}    ${response}=    Run Keyword And Ignore Error
        ...    POST On Session    api    ${endpoint}
        ...    headers=${headers}
        ...    json=${{{}}}
        ...    expected_status=any
        Set Log Level    ${current_log_level}

        # Check if successful
        IF    "${status}" == "PASS"
            Log    Response status: ${response.status_code}

            # Success - 204 No Content expected
            IF    ${response.status_code} == 204
                Log    SUCCESS: Robot test data created successfully
                RETURN

                # Handle specific error cases
            ELSE IF    ${response.status_code} == 400
                ${body}=    Set Variable    ${response.json()}
                IF    "ReservationUnitType matching query does not exist" in "${body}"
                    Fail    PREREQUISITE DATA MISSING: Required objects don't exist in database
                END
                Fail    Bad Request: ${body}
            ELSE IF    ${response.status_code} == 425
                Log    Test data creation already in progress, waiting...    WARN
                Sleep    ${RETRY_DELAY}
            ELSE IF    ${response.status_code} == 429
                ${retry_after}=    Get From Dictionary    ${response.headers}    Retry-After    default=60
                Log    Rate limited, waiting ${retry_after} seconds...    WARN
                Sleep    ${retry_after}
            ELSE IF    ${response.status_code} == 502
                Log    Server error (502), waiting before retry...    WARN
                Sleep    ${RETRY_DELAY}
            ELSE
                Fail    Unexpected status ${response.status_code}: ${response.text}
            END
        ELSE
            Fail    Request failed: ${response}
        END
    END

    Fail    Failed to Create robot test data after ${MAX_RETRIES} attempts
