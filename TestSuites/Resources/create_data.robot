*** Settings ***
Documentation       Create robot test data for Harakka via API endpoint.
...                 This is used for creating the necessary test data for test execution.

Library             RequestsLibrary
Library             Collections
Library             OperatingSystem
Variables           env_loader.py


*** Variables ***
${BASE_URL}             https://varaamo.test.hel.ninja
# For quick testing, set TOKEN to the value of ROBOT_API_TOKEN in the .env file
# ${TOKEN}    ${EMPTY}
# ${ENDPOINT}    ${EMPTY}
${MAX_RETRIES}          2
${RETRY_DELAY}          60    # seconds

# Default values for fallback
${DEFAULT_ENDPOINT}     /v1/create_robot_test_data/


*** Keywords ***
Create Robot Test Data DISABLED
    Log    Disabled until backend data creation is ready

Create Robot Test Data
    [Documentation]    Calls the endpoint to Create robot test data.
    ...    Backend returns 204 immediately and processes data asynchronously.
    ...    Waits 3 minutes for backend processing to complete.
    [Timeout]    5 minutes

    # Temporarily suppress logging
    ${original_log_level}=    Set Log Level    NONE

    # Retrieve token from Robot Framework variables (loaded by env_loader.py)
    # Priority: $TOKEN (if defined) > $ROBOT_API_TOKEN from env_loader.py > empty
    ${token}=    Get Variable Value    $TOKEN    ${EMPTY}
    ${token}=    Set Variable If    "${token}"==""    ${ROBOT_API_TOKEN}    ${token}

    # Create headers with token
    VAR    &{headers}    Authorization=${token}    Content-Type=application/json    X-Robot-API-Secret=${token}

    # Restore original log level after all sensitive operations
    Set Log Level    ${original_log_level}

    IF    "${token}" == ""
        Fail    ROBOT_API_TOKEN not provided in TOKEN variable nor .env file
    END

    # Get endpoint from Robot Framework variables or use default
    # Priority: $ENDPOINT (if defined) > $ROBOT_API_ENDPOINT from env_loader.py > DEFAULT_ENDPOINT
    ${endpoint}=    Get Variable Value    $ENDPOINT    ${EMPTY}
    ${endpoint}=    Set Variable If    "${endpoint}"==""    ${ROBOT_API_ENDPOINT}    ${endpoint}
    ${endpoint}=    Set Variable If    "${endpoint}"!=""    ${endpoint}    ${DEFAULT_ENDPOINT}

    Log    Creating robot test data
    Log    URL: ${BASE_URL}${endpoint}

    # Create session
    Create Session    api    ${BASE_URL}    verify=${True}

    # Suppress logging during POST request to avoid logging sensitive headers
    ${current_log_level}=    Set Log Level    WARN
    ${status}    ${response}=    Run Keyword And Ignore Error
    ...    POST On Session    api    ${endpoint}
    ...    headers=${headers}
    ...    json=${{{}}}
    ...    expected_status=any
    Set Log Level    ${current_log_level}

    # Check if request was successful
    IF    "${status}" != "PASS"
        Fail    Request failed: ${response}
    END

    Log    Response status: ${response.status_code}

    # Handle response
    IF    ${response.status_code} == 204
        Log    SUCCESS: Robot test data creation request accepted (204 No Content)
        Log    Waiting 3 minutes for backend to complete data creation...    WARN
        Sleep    180s    # 3 minutes for backend processing
        Log    Backend processing wait completed
        RETURN

    ELSE IF    ${response.status_code} == 400
        ${body}=    Set Variable    ${response.json()}
        IF    "ReservationUnitType matching query does not exist" in "${body}"
            Fail    PREREQUISITE DATA MISSING: Required objects don't exist in database
        END
        Fail    Bad Request: ${body}

    ELSE
        Fail    Unexpected status ${response.status_code}: ${response.text}
    END
