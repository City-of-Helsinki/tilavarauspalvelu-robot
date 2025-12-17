*** Settings ***
Documentation       Simple HAR Recording for Robot Framework Test Suite

Library             Browser
Library             DateTime
Library             OperatingSystem
Library             String
Library             Collections
Resource            variables.robot


*** Variables ***
${HAR_OUTPUT_DIR}       ${CURDIR}${/}..${/}..${/}output${/}har_files
${CURRENT_HAR_PATH}     ${EMPTY}
${LOCALE}               en-US


*** Keywords ***
Create Context With Optional HAR
    [Documentation]    Creates a browser context with optional HAR recording based on ENABLE_HAR_RECORDING variable
    [Arguments]    ${context_config}    ${browser_type}=UNKNOWN

    ${har_enabled}=    Get Variable Value    ${ENABLE_HAR_RECORDING}    ${FALSE}

    # Convert string values to boolean for proper evaluation
    IF    '${har_enabled}' == 'True' or '${har_enabled}' == '${TRUE}' or $har_enabled == ${TRUE}
        ${har_enabled}=    Set Variable    ${TRUE}
    ELSE
        ${har_enabled}=    Set Variable    ${FALSE}
    END

    IF    $har_enabled
        Log    📹 HAR recording enabled - creating HAR-enabled context
        ${context_config}=    Start HAR Recording For Context    ${browser_type}    ${context_config}
        # Temporarily suppress logging to prevent sensitive headers from being logged
        ${original_log_level}=    Set Log Level    NONE
        ${contextId}=    New Context    &{context_config}
        Set Log Level    ${original_log_level}
        Log    ✅ HAR-enabled context created
    ELSE
        Log    📹 HAR recording disabled - creating standard context
        # Temporarily suppress logging to prevent sensitive headers from being logged
        ${original_log_level}=    Set Log Level    NONE
        ${contextId}=    New Context    &{context_config}
        Set Log Level    ${original_log_level}
        Log    ✅ Standard context created
    END

    RETURN    ${contextId}

Generate Unique HAR File Path
    [Documentation]    Creates a unique HAR file path based on test context and timestamp
    [Arguments]    ${browser_type}=unknown

    # Get test execution context
    ${test_name}=    Get Variable Value    ${TEST NAME}    unknown_test
    ${suite_name}=    Get Variable Value    ${SUITE NAME}    unknown_suite
    ${pool_id}=    Get Variable Value    $PABOTEXECUTIONPOOLID    single

    # Create timestamp for uniqueness
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S_%f
    ${timestamp}=    Get Substring    ${timestamp}    0    17

    # Sanitize names for filesystem
    ${clean_test_name}=    Replace String    ${test_name}    ${SPACE}    _
    ${clean_suite_name}=    Replace String    ${suite_name}    ${SPACE}    _
    ${clean_suite_name}=    Replace String    ${clean_suite_name}    .    -

    # Build HAR filename
    ${har_filename}=    Set Variable
    ...    pool${pool_id}_${browser_type}_${clean_suite_name}_${clean_test_name}_${timestamp}.har

    # Ensure output directory exists
    Create Directory    ${HAR_OUTPUT_DIR}

    ${har_path}=    Join Path    ${HAR_OUTPUT_DIR}    ${har_filename}
    RETURN    ${har_path}

Start HAR Recording For Context
    [Documentation]    Enables HAR recording for a browser context
    [Arguments]    ${browser_type}    ${context_config}

    # Generate unique HAR file path
    ${har_path}=    Generate Unique HAR File Path    ${browser_type}
    Set Test Variable    ${CURRENT_HAR_PATH}    ${har_path}

    # Create HAR configuration
    VAR    &{har_config}    path=${har_path}    omitContent=${FALSE}

    # Add HAR recording to context configuration
    Set To Dictionary    ${context_config}    recordHar=${har_config}

    RETURN    ${context_config}

Create HAR-Enabled Chromium Context
    [Documentation]    Creates Chromium context with HAR recording enabled

    VAR    &{context_config}
    ...    viewport={'width': 1440, 'height': 900}
    ...    acceptDownloads=True
    ...    locale=${LOCALE}
    ...    timezoneId=Europe/Helsinki
    ...    ignoreHTTPSErrors=true
    ...    deviceScaleFactor=1

    ${context_config}=    Start HAR Recording For Context    CHROMIUM    ${context_config}
    ${contextId}=    New Context    &{context_config}

    RETURN    ${contextId}

Create HAR-Enabled Firefox Context
    [Documentation]    Creates Firefox context with HAR recording enabled

    VAR    &{context_config}
    ...    viewport={'width': 1920, 'height': 1080}
    ...    acceptDownloads=True
    ...    locale=${LOCALE}
    ...    timezoneId=Europe/Helsinki
    ...    ignoreHTTPSErrors=true

    ${context_config}=    Start HAR Recording For Context    FIREFOX    ${context_config}
    ${contextId}=    New Context    &{context_config}

    RETURN    ${contextId}

Create HAR-Enabled Mobile Context
    [Documentation]    Creates mobile device context with HAR recording enabled
    [Arguments]    ${device_name}

    ${device_config}=    Get Device    ${device_name}
    Set To Dictionary    ${device_config}    locale=${LOCALE}

    ${device_type}=    Replace String    ${device_name}    ${SPACE}    _
    ${device_config}=    Start HAR Recording For Context    ${device_type}    ${device_config}
    ${contextId}=    New Context    &{device_config}

    RETURN    ${contextId}
