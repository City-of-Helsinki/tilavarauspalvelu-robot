*** Settings ***
Documentation       Parallel test data management using PabotLib
...
...                 MODES:
...                 - PARALLEL: Each test gets dedicated user from value sets
...                 - SINGLE: All tests use desktop-test-data-set-0 (FORCE_SINGLE_USER=True)

Library             pabot.PabotLib
Library             String
Library             Collections
Resource            users.robot


*** Variables ***
# Override flag to force single user for all tests (useful for Code editor debugging)
${FORCE_SINGLE_USER}    ${FALSE}


*** Keywords ***
Initialize Test Data
    [Documentation]    Acquires an isolated value set for this test based on test suite type
    ...
    ...    PARALLEL MODE: Uses PabotLib to assign unique users per test
    ...    SINGLE MODE: Uses desktop-test-data-set-0 for all tests
    [Arguments]    ${data_type}=desktop-test-data

    # Get test context
    ${test_name}=    Get Variable Value    ${TEST NAME}    unknown_test
    ${suite_name}=    Get Variable Value    ${SUITE NAME}    unknown_suite
    ${process_id}=    Get Variable Value    ${PABOTEXECUTIONPOOLID}    ${NONE}

    Log    Initializing test data for: ${test_name} (Suite: ${suite_name}, Process: ${process_id})

    # Check if we should force single user mode
    ${force_single}=    Get Variable Value    ${FORCE_SINGLE_USER}    ${FALSE}
    IF    ${force_single}
        Log    Using FORCE_SINGLE_USER mode - all tests use desktop-test-data-set-0
        Use Single User Mode
        RETURN
    END

    # Check if running without pabot (Code editor, single execution)
    IF    '${process_id}' == '${NONE}'
        Log    Non-parallel execution detected - using single user mode
        Use Single User Mode
        RETURN
    END

    # PARALLEL MODE: Use test-specific user assignment
    ${user_index}=    Get User Index For Test    ${suite_name}    ${test_name}
    ${value_set_name}=    Set Variable    ${data_type}-set-${user_index}

    Log    Attempting to acquire value set: ${value_set_name}

    # Try to acquire the PabotLib value set
    ${status}=    Run Keyword And Return Status    Acquire Value Set    ${value_set_name}
    IF    ${status}
        Set Test Variable    ${CURRENT_VALUE_SET}    ${value_set_name}
        Log    ✓ Successfully acquired PabotLib value set: ${value_set_name}

        # Import all variables from the value set
        TRY
            # Determine what variables to set based on data type
            IF    '${data_type}' == 'desktop-test-data' or '${data_type}' == 'mobile-android-data' or '${data_type}' == 'mobile-iphone-data'
                # USER-ONLY SUITES: Set only regular user variables
                Set User Variables From Value Set
                Log    ✓ User variables set from value set
            ELSE IF    '${data_type}' == 'admin-test-data'
                # ADMIN-ONLY SUITES: Set only admin variables
                Set Admin Variables From Value Set
                Log    ✓ Admin variables set from value set
            ELSE IF    '${data_type}' == 'combined-test-data'
                # COMBINED SUITES: Set both user and admin variables
                Set User Variables From Value Set
                Set Admin Variables From Value Set
                Log    ✓ Both user and admin variables set from value set
            ELSE
                Log    ⚠ WARNING: Unknown data type ${data_type}, using user variables only
                Set User Variables From Value Set
            END
        EXCEPT    AS    ${error}
            Log    ⚠ WARNING: Failed to get variables from value set: ${error}
            Log    Falling back to single user mode
            Use Single User Mode
        END
    ELSE
        Log    ⚠ WARNING: Value set ${value_set_name} not available
        Log    Falling back to single user mode
        Use Single User Mode
    END

Use Single User Mode
    [Documentation]    Sets test variables to use the default test user (Ande AutomaatioTesteri)
    ${data_type}=    Get Suite Data Type

    # Set user variables for user and combined suites
    IF    '${data_type}' == 'desktop-test-data' or '${data_type}' == 'mobile-android-data' or '${data_type}' == 'mobile-iphone-data' or '${data_type}' == 'combined-test-data'
        Log    Using single user mode: Ande AutomaatioTesteri
        Set Test Variable    ${CURRENT_USER_EMAIL}    ${BASIC_USER_MALE_EMAIL}
        Set Test Variable    ${CURRENT_USER_HETU}    ${BASIC_USER_MALE_HETU}
        Set Test Variable    ${CURRENT_USER_PHONE}    ${BASIC_USER_MALE_PHONE}
        Set Test Variable    ${CURRENT_USER_FIRST_NAME}    ${BASIC_USER_MALE_FIRSTNAME}
        Set Test Variable    ${CURRENT_USER_LAST_NAME}    ${BASIC_USER_MALE_LASTNAME}
        Set Test Variable    ${CURRENT_USER_FULLNAME}    ${BASIC_USER_MALE_FIRSTNAME} ${BASIC_USER_MALE_LASTNAME}
        Set Test Variable    ${CURRENT_PASSWORD}    ${BASIC_USER_MALE_PASSWORD}
    END

    # Set admin variables for admin and combined suites
    IF    '${data_type}' == 'admin-test-data' or '${data_type}' == 'combined-test-data'
        Use Single Admin User Mode
    END

Use Single Admin User Mode
    [Documentation]    Sets admin test variables to use the default admin user (TirehtööriPääkäytäjä Tötterstrom)
    Log    Using single admin user mode: TirehtööriPääkäytäjä Tötterstrom
    Set Test Variable    ${ADMIN_CURRENT_USER_EMAIL}    ${BASIC_ADMIN_MALE_EMAIL}
    Set Test Variable    ${ADMIN_CURRENT_USER_HETU}    ${BASIC_ADMIN_MALE_HETU}
    Set Test Variable    ${ADMIN_CURRENT_USER_FIRST_NAME}    ${BASIC_ADMIN_MALE_FIRSTNAME}
    Set Test Variable    ${ADMIN_CURRENT_USER_LAST_NAME}    ${BASIC_ADMIN_MALE_LASTNAME}
    Set Test Variable    ${ADMIN_CURRENT_USER_FULLNAME}    ${BASIC_ADMIN_MALE_FULLNAME}
    Set Test Variable    ${ADMIN_CURRENT_USER_PASSWORD}    ${BASIC_ADMIN_MALE_PASSWORD}

Get User Index For Test
    [Documentation]    Returns the user index for a specific test in a specific suite
    ...    This creates a deterministic mapping: each test always gets the same user
    [Arguments]    ${suite_name}    ${test_name}

    # DESKTOP SUITE TESTS (indices 0-11)
    IF    'Tests user desktop FI' in '${suite_name}'
        IF    'User logs in and out with suomi_fi' in '${test_name}'
            RETURN    0
        ELSE IF    'User can make free single booking and modifies it' in '${test_name}'
            RETURN    1
        ELSE IF    'User can create non-cancelable booking' in '${test_name}'
            RETURN    2
        ELSE IF    'User can make paid single booking with interrupted checkout' in '${test_name}'
            RETURN    3
        ELSE IF    'User can make paid single booking' in '${test_name}' and 'interrupted' not in '${test_name}'
            RETURN    4
        ELSE IF    'User can make subvented single booking that requires handling' in '${test_name}'
            RETURN    5
        ELSE IF    'User can make reservation with access code' in '${test_name}'
            RETURN    6
        ELSE IF    'User checks that reserved time is not available anymore' in '${test_name}'
            RETURN    7
        ELSE IF    'User checks that there are not current dates in the past bookings' in '${test_name}'
            RETURN    8
        ELSE IF    'User can make free single booking and check info from downloaded calendar file' in '${test_name}'
            RETURN    9
        ELSE IF    'Check emails from reservations' in '${test_name}'
            RETURN    10
        ELSE IF    'User makes recurring reservation' in '${test_name}'
            RETURN    11
        ELSE
            RETURN    0    # Default fallback
        END

        # ADMIN SUITE TESTS (indices 0-1)
    ELSE IF    'Tests admin desktop FI' in '${suite_name}'
        IF    'Admin logs in with suomi_fi' in '${test_name}'
            RETURN    0
        ELSE IF    'Admin verifies all reservation types' in '${test_name}'
            RETURN    1
        ELSE
            RETURN    0    # Default fallback
        END

        # COMBINED SUITE TESTS (indices 0-5)
    ELSE IF    'Tests users with admin desktop' in '${suite_name}'
        IF    'User creates and Admin accepts single booking that requires handling' in '${test_name}'
            RETURN    0
        ELSE IF    'User creates and Admin declines single booking that requires handling' in '${test_name}'
            RETURN    1
        ELSE IF    'Admin creates normal notifications for both sides' in '${test_name}'
            RETURN    2
        ELSE IF    'Admin creates warning notifications for both sides' in '${test_name}'
            RETURN    3
        ELSE IF    'Admin creates error notifications for both sides' in '${test_name}'
            RETURN    4
        ELSE IF    'Admin creates notification and archive and deletes notification for both sides' in '${test_name}'
            RETURN    5
        ELSE
            RETURN    0    # Default fallback
        END

        # NOTIFICATIONS SUITE TESTS (indices 0-3)
    ELSE IF    'Tests notifications single process' in '${suite_name}'
        IF    'Admin creates normal notifications for both sides' in '${test_name}'
            RETURN    0
        ELSE IF    'Admin creates warning notifications for both sides' in '${test_name}'
            RETURN    1
        ELSE IF    'Admin creates error notifications for both sides' in '${test_name}'
            RETURN    2
        ELSE IF    'Admin creates notification and archive and deletes notification for both sides' in '${test_name}'
            RETURN    3
        ELSE
            RETURN    0    # Default fallback
        END

        # MOBILE ANDROID SUITE TESTS (indices 0-5)
    ELSE IF    'Tests user mobile android FI' in '${suite_name}'
        IF    'User logs in and out with suomi_fi mobile' in '${test_name}'
            RETURN    0
        ELSE IF    'User can make a free single booking and modifies it mobile' in '${test_name}'
            RETURN    1
        ELSE IF    'User can make paid single booking mobile' in '${test_name}' and 'interrupted' not in '${test_name}'
            RETURN    2
        ELSE IF    'User can make paid single booking with interrupted checkout mobile' in '${test_name}'
            RETURN    3
        ELSE IF    'User can make single booking that requires handling mobile' in '${test_name}'
            RETURN    4
        ELSE IF    'User can make subvented single booking that requires handling mobile' in '${test_name}'
            RETURN    5
        ELSE
            RETURN    0    # Default fallback
        END

        # MOBILE iPHONE SUITE TESTS (indices 0-5)
    ELSE IF    'Tests user mobile iphone FI' in '${suite_name}'
        IF    'User logs in and out with suomi_fi' in '${test_name}'
            RETURN    0
        ELSE IF    'User can make free single booking and modifies it' in '${test_name}'
            RETURN    1
        ELSE IF    'User can make paid single booking' in '${test_name}' and 'interrupted' not in '${test_name}'
            RETURN    2
        ELSE IF    'User can make paid single booking with interrupted checkout' in '${test_name}'
            RETURN    3
        ELSE IF    'User can make booking that requires handling' in '${test_name}'
            RETURN    4
        ELSE IF    'User can make subvented single booking that requires handling' in '${test_name}'
            RETURN    5
        ELSE
            RETURN    0    # Default fallback
        END

        # UNKNOWN SUITE - Use hash-based selection as fallback
    ELSE
        Log    Unknown suite: ${suite_name}, using hash-based user selection
        ${hash_value}=    Evaluate    hash('${test_name}') % 12
        RETURN    ${hash_value}
    END

Release Test Data
    [Documentation]    Releases the PabotLib value set when test is finished
    ${status}=    Run Keyword And Return Status    Release Value Set
    IF    ${status}
        Log    ✓ Released PabotLib value set
    ELSE
        Log    No PabotLib value set to release (single user mode or non-parallel execution)
    END

Get Suite Data Type
    [Documentation]    Returns the appropriate data type based on the suite name
    ...    - Tests_user_desktop_FI.robot → desktop-test-data (user variables only)
    ...    - Tests_user_mobile_android_FI.robot → mobile-android-data (user variables only)
    ...    - Tests_user_mobile_iphone_FI.robot → mobile-iphone-data (user variables only)
    ...    - Tests_admin_desktop_FI.robot → admin-test-data (admin variables only)
    ...    - Tests_users_with_admin_desktop.robot → combined-test-data (both user and admin variables)
    ...    - Tests_admin_notifications_serial.robot → combined-test-data (both user and admin variables)
    ${suite_name}=    Get Variable Value    ${SUITE NAME}    unknown

    Log    Debug: Suite name for data type detection: ${suite_name}

    # Handle combined suite names by looking at the last part after the final dot
    # Example: "Tests user desktop FI & Tests admin desktop FI.Tests admin desktop FI"
    # We want to check "Tests admin desktop FI" (the actual running suite)
    ${suite_parts}=    Split String    ${suite_name}    .
    ${actual_suite}=    Get From List    ${suite_parts}    -1
    Log    Debug: Actual running suite: ${actual_suite}

    # Check the actual running suite (last part after final dot)
    IF    '${actual_suite}' == 'Tests admin desktop FI'
        Log    Debug: Detected admin-test-data for actual suite: ${actual_suite}
        RETURN    admin-test-data
    ELSE IF    '${actual_suite}' == 'Tests users with admin desktop'
        Log    Debug: Detected combined-test-data for actual suite: ${actual_suite}
        RETURN    combined-test-data
    ELSE IF    '${actual_suite}' == 'Tests admin notifications serial'
        Log    Debug: Detected combined-test-data for actual suite: ${actual_suite}
        RETURN    combined-test-data
    ELSE IF    '${actual_suite}' == 'Tests notifications single process'
        Log    Debug: Detected combined-test-data for actual suite: ${actual_suite}
        RETURN    combined-test-data
    ELSE IF    '${actual_suite}' == 'Tests user desktop FI'
        Log    Debug: Detected desktop-test-data for actual suite: ${actual_suite}
        RETURN    desktop-test-data
    ELSE IF    '${actual_suite}' == 'Tests user mobile android FI'
        Log    Debug: Detected mobile-android-data for actual suite: ${actual_suite}
        RETURN    mobile-android-data
    ELSE IF    '${actual_suite}' == 'Tests user mobile iphone FI'
        Log    Debug: Detected mobile-iphone-data for actual suite: ${actual_suite}
        RETURN    mobile-iphone-data
        # Fallback to original logic for non-combined suites
    ELSE IF    'Tests admin desktop FI' in '${suite_name}'
        Log    Debug: Detected admin-test-data for suite (fallback): ${suite_name}
        RETURN    admin-test-data
    ELSE IF    'Tests users with admin desktop' in '${suite_name}'
        Log    Debug: Detected combined-test-data for suite (fallback): ${suite_name}
        RETURN    combined-test-data
    ELSE IF    'Tests admin notifications serial' in '${suite_name}'
        Log    Debug: Detected combined-test-data for suite (fallback): ${suite_name}
        RETURN    combined-test-data
    ELSE IF    'Tests notifications single process' in '${suite_name}'
        Log    Debug: Detected combined-test-data for suite (fallback): ${suite_name}
        RETURN    combined-test-data
        # Check for user-specific patterns after admin patterns
    ELSE IF    'Tests user desktop FI' in '${suite_name}'
        Log    Debug: Detected desktop-test-data for suite (fallback): ${suite_name}
        RETURN    desktop-test-data
    ELSE IF    'Tests user mobile android FI' in '${suite_name}'
        Log    Debug: Detected mobile-android-data for suite (fallback): ${suite_name}
        RETURN    mobile-android-data
    ELSE IF    'Tests user mobile iphone FI' in '${suite_name}'
        Log    Debug: Detected mobile-iphone-data for suite (fallback): ${suite_name}
        RETURN    mobile-iphone-data
    ELSE
        Log    Debug: Using default desktop-test-data for unknown suite: ${suite_name}
        RETURN    desktop-test-data    # Default fallback
    END

Set User Variables From Value Set
    [Documentation]    Sets all regular user variables from the PabotLib value set
    ${email}=    Get Value From Set    CURRENT_USER_EMAIL
    ${first_name}=    Get Value From Set    CURRENT_USER_FIRST_NAME
    ${last_name}=    Get Value From Set    CURRENT_USER_LAST_NAME
    ${full_name}=    Get Value From Set    CURRENT_USER_FULLNAME
    ${hetu}=    Get Value From Set    CURRENT_USER_HETU
    ${phone}=    Get Value From Set    CURRENT_USER_PHONE
    ${password}=    Get Value From Set    CURRENT_PASSWORD

    Set Test Variable    ${CURRENT_USER_EMAIL}    ${email}
    Set Test Variable    ${CURRENT_USER_FIRST_NAME}    ${first_name}
    Set Test Variable    ${CURRENT_USER_LAST_NAME}    ${last_name}
    Set Test Variable    ${CURRENT_USER_FULLNAME}    ${full_name}
    Set Test Variable    ${CURRENT_USER_HETU}    ${hetu}
    Set Test Variable    ${CURRENT_USER_PHONE}    ${phone}
    Set Test Variable    ${CURRENT_PASSWORD}    ${password}

Set Admin Variables From Value Set
    [Documentation]    Sets all admin user variables from the PabotLib value set
    ${admin_email}=    Get Value From Set    ADMIN_CURRENT_USER_EMAIL
    ${admin_first_name}=    Get Value From Set    ADMIN_CURRENT_USER_FIRST_NAME
    ${admin_last_name}=    Get Value From Set    ADMIN_CURRENT_USER_LAST_NAME
    ${admin_hetu}=    Get Value From Set    ADMIN_CURRENT_USER_HETU
    ${admin_fullname}=    Get Value From Set    ADMIN_CURRENT_USER_FULLNAME
    ${admin_password}=    Get Value From Set    ADMIN_CURRENT_USER_PASSWORD

    Set Test Variable    ${ADMIN_CURRENT_USER_EMAIL}    ${admin_email}
    Set Test Variable    ${ADMIN_CURRENT_USER_FIRST_NAME}    ${admin_first_name}
    Set Test Variable    ${ADMIN_CURRENT_USER_LAST_NAME}    ${admin_last_name}
    Set Test Variable    ${ADMIN_CURRENT_USER_HETU}    ${admin_hetu}
    Set Test Variable    ${ADMIN_CURRENT_USER_FULLNAME}    ${admin_fullname}
    Set Test Variable    ${ADMIN_CURRENT_USER_PASSWORD}    ${admin_password}

# =============================================================================
# MAIL TEST DATA MANAGEMENT (for cross-test data sharing)
# =============================================================================

Store Mail Test Data
    [Documentation]    Stores mail-related test data for cross-test access
    [Arguments]
    ...    ${reservation_number}
    ...    ${reservation_time}
    ...    ${unit_name}
    ...    ${formatted_start_time}
    ...    ${formatted_end_time}

    ${status}=    Run Keyword And Return Status
    ...    Set Parallel Value For Key
    ...    MAIL_RESERVATION_NUMBER
    ...    ${reservation_number}
    IF    ${status}
        Set Parallel Value For Key    MAIL_RESERVATION_TIME    ${reservation_time}
        Set Parallel Value For Key    MAIL_UNIT_NAME    ${unit_name}
        Set Parallel Value For Key    MAIL_FORMATTED_START_TIME    ${formatted_start_time}
        Set Parallel Value For Key    MAIL_FORMATTED_END_TIME    ${formatted_end_time}
        Log    ✓ Stored mail test data using PabotLib
    ELSE
        Set Test Variable    ${MAIL_RESERVATION_NUMBER}    ${reservation_number}
        Set Test Variable    ${MAIL_RESERVATION_TIME}    ${reservation_time}
        Set Test Variable    ${MAIL_UNIT_NAME}    ${unit_name}
        Set Test Variable    ${MAIL_FORMATTED_START_TIME}    ${formatted_start_time}
        Set Test Variable    ${MAIL_FORMATTED_END_TIME}    ${formatted_end_time}
        Log    ✓ Stored mail test data as test variables (fallback)
    END

Get Mail Test Data
    [Documentation]    Retrieves mail-related test data for verification

    ${status}=    Run Keyword And Return Status    Get Parallel Value For Key    MAIL_RESERVATION_NUMBER
    IF    ${status}
        ${reservation_number}=    Get Parallel Value For Key    MAIL_RESERVATION_NUMBER
        ${reservation_time}=    Get Parallel Value For Key    MAIL_RESERVATION_TIME
        ${unit_name}=    Get Parallel Value For Key    MAIL_UNIT_NAME
        ${formatted_start_time}=    Get Parallel Value For Key    MAIL_FORMATTED_START_TIME
        ${formatted_end_time}=    Get Parallel Value For Key    MAIL_FORMATTED_END_TIME
        Log    ✓ Retrieved mail test data using PabotLib
    ELSE
        ${reservation_number}=    Get Variable Value    ${MAIL_RESERVATION_NUMBER}    ${EMPTY}
        ${reservation_time}=    Get Variable Value    ${MAIL_RESERVATION_TIME}    ${EMPTY}
        ${unit_name}=    Get Variable Value    ${MAIL_UNIT_NAME}    ${EMPTY}
        ${formatted_start_time}=    Get Variable Value    ${MAIL_FORMATTED_START_TIME}    ${EMPTY}
        ${formatted_end_time}=    Get Variable Value    ${MAIL_FORMATTED_END_TIME}    ${EMPTY}
        Log    ✓ Retrieved mail test data from test variables (fallback)
    END

    RETURN    ${reservation_number}    ${reservation_time}    ${unit_name}    ${formatted_start_time}    ${formatted_end_time}

# =============================================================================
# BACKWARD COMPATIBILITY KEYWORDS
# =============================================================================

Store Test Data Variable
    [Documentation]    For value sets, use Set Parallel Value For Key instead
    [Arguments]    ${variable_name}    ${value}
    ${status}=    Run Keyword And Return Status    Set Parallel Value For Key    ${variable_name}    ${value}
    IF    ${status}
        Log    Stored ${variable_name} = ${value} in value set
    ELSE
        Set Test Variable    ${${variable_name}}    ${value}
        Log    Stored ${variable_name} = ${value} as test variable (fallback)
    END

Get Test Data Variable
    [Documentation]    Gets a variable value from value sets or fallback to suite variable
    [Arguments]    ${variable_name}    ${default_value}=${EMPTY}
    Log    DEBUG: Getting variable '${variable_name}' with default '${default_value}'
    ${status}=    Run Keyword And Return Status    Get Parallel Value For Key    ${variable_name}
    IF    ${status}
        ${value}=    Get Parallel Value For Key    ${variable_name}
        Log    DEBUG: PabotLib returned value '${value}' for '${variable_name}'
        # If PabotLib returns an empty value, fall back to the default
        IF    "${value}" == ""
            ${value}=    Get Variable Value    ${${variable_name}}    ${default_value}
            Log    DEBUG: PabotLib value was empty, using fallback value '${value}' for '${variable_name}'
        END
        RETURN    ${value}
    ELSE
        ${value}=    Get Variable Value    ${${variable_name}}    ${default_value}
        Log    DEBUG: PabotLib not available, using fallback value '${value}' for '${variable_name}'
        RETURN    ${value}
    END
