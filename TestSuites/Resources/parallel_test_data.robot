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
Initialize Test Data From Tags
    [Documentation]    Tag-based test data initialization
    ...
    ...    Determines data type and value set from test tags:
    ...    - Data set tag: desktop-test-data-set-0, admin-test-data-set-2, etc.
    ...    - Falls back to single user mode if no data set tag found
    ...    Single user mode uses:
    ...    - Regular user: Ande AutomaatioTesteri (BASIC_USER_MALE)
    ...    - Admin user: TirehtööriPääkäytäjä Tötterstrom (BASIC_ADMIN_MALE)
    ...    - Django admin (permissions): Kari Kekkonen (BASIC_DJANGO_ADMIN)
    ...    - Permission target admin: Marika Salminen (BASIC_PERMISSION_TARGET_ADMIN)
    ...
    ...    PARALLEL MODE: Uses PabotLib to acquire value sets by tag
    ...    SINGLE MODE: Uses basic users from users.robot
    ...
    ...    EXAMPLE TAGS:
    ...    [Tags]    desktop-test-data-set-0    desktop-suite    smoke
    ...    [Tags]    admin-test-data-set-2    admin-suite    permissions

    # Get test context
    ${test_name}=    Get Variable Value    ${TEST NAME}    unknown_test
    ${suite_name}=    Get Variable Value    ${SUITE NAME}    unknown_suite
    ${process_id}=    Get Variable Value    ${PABOTEXECUTIONPOOLID}    ${NONE}
    ${test_tags}=    Get Variable Value    ${TEST TAGS}    []

    Log    🏷️ Initializing test data from tags for: ${test_name}
    Log    📋 Suite: ${suite_name}
    Log    🏷️ Tags: ${test_tags}
    Log    🔧 Process ID: ${process_id}

    # Parse all tags and set flags
    ${value_set_name}    ${has_admin}    ${has_combined}    ${has_permissions}    ${has_user}=
    ...    Parse Test Tags    ${test_tags}

    IF    '${value_set_name}' == '${NONE}'
        Log    ⚠️ No data set tag found, using single user mode fallback
        Use Single User Mode From Parsed Tags    ${has_admin}    ${has_combined}    ${has_permissions}    ${has_user}
        RETURN
    END

    Log    🎯 Found data set tag: ${value_set_name}

    # Check if we should force single user mode
    ${force_single}=    Get Variable Value    ${FORCE_SINGLE_USER}    ${FALSE}
    IF    ${force_single}
        Log    Using FORCE_SINGLE_USER mode - using basic users from users.robot
        Use Single User Mode From Parsed Tags    ${has_admin}    ${has_combined}    ${has_permissions}    ${has_user}
        RETURN
    END

    # Check if running without pabot (Code editor, single execution)
    IF    '${process_id}' == '${NONE}'
        Log    Non-parallel execution detected - using single user mode
        Use Single User Mode From Parsed Tags    ${has_admin}    ${has_combined}    ${has_permissions}    ${has_user}
        RETURN
    END

    # PARALLEL MODE: Acquire value set by name
    Log    Attempting to acquire PabotLib value set: ${value_set_name}
    ${status}=    Run Keyword And Return Status    Acquire Value Set    ${value_set_name}

    IF    ${status}
        Set Test Variable    ${CURRENT_VALUE_SET}    ${value_set_name}
        Log    ✓ Successfully acquired PabotLib value set: ${value_set_name}

        # Import variables based on pre-parsed tag flags
        TRY
            IF    ${has_combined}
                # COMBINED tests: Load both user and admin variables
                Set User Variables From Value Set
                Set Admin Variables From Value Set
                Log    ✓ Both user and admin variables set from value set
            ELSE IF    ${has_admin}
                # ADMIN tests: Load admin variables (or Django admin for permissions)
                IF    ${has_permissions}
                    # Permission test: Load only Django admin and permission target
                    Log    Permission test detected - loading Django admin and permission target only
                    Set Django Admin Variables From Value Set
                    Set Permission Target Admin Variables From Value Set
                    Log    ✓ Permission test: Django admin and permission target variables set
                ELSE
                    # Normal admin test: Load only standard admin variables
                    Set Admin Variables From Value Set
                    Log    ✓ Admin variables set from value set
                END
            ELSE IF    ${has_user}
                # USER tests: Load only user variables
                Set User Variables From Value Set
                Log    ✓ User variables set from value set
            ELSE
                Log    ⚠️ WARNING: No valid test type detected, using user variables as fallback
                Set User Variables From Value Set
            END
        EXCEPT    AS    ${error}
            Log    ⚠️ WARNING: Failed to get variables from value set: ${error}
            Log    Falling back to single user mode
            Use Single User Mode From Parsed Tags
            ...    ${has_admin}
            ...    ${has_combined}
            ...    ${has_permissions}
            ...    ${has_user}
        END
    ELSE
        Log    ⚠️ WARNING: Value set ${value_set_name} not available
        Log    Falling back to single user mode
        Use Single User Mode From Parsed Tags    ${has_admin}    ${has_combined}    ${has_permissions}    ${has_user}
    END

Parse Test Tags
    [Documentation]    Parse test tags and return all relevant information
    ...    Returns: data_set_name, has_admin_tag, has_combined_tag, has_permissions_tag, has_user_tag
    ...    Example:
    ...    Tags: ['admin-suite', 'admin-test-data-set-2', 'permissions']
    ...    Returns: 'admin-test-data-set-2', True, False, True, False
    [Arguments]    ${tags}

    # Initialize all flags
    ${data_set_name}=    Set Variable    ${NONE}
    ${has_admin_tag}=    Set Variable    ${FALSE}
    ${has_combined_tag}=    Set Variable    ${FALSE}
    ${has_permissions_tag}=    Set Variable    ${FALSE}
    ${has_user_tag}=    Set Variable    ${FALSE}

    # Single pass through all tags
    FOR    ${tag}    IN    @{tags}
        ${is_data_set}=    Run Keyword And Return Status
        ...    Should Match Regexp
        ...    ${tag}
        ...    ^(desktop-test-data|admin-test-data|mobile-android-data|mobile-iphone-data|combined-test-data)-set-\\d+$
        IF    ${is_data_set}
            ${data_set_name}=    Set Variable    ${tag}
        END

        # Check for suite type tags
        ${is_admin}=    Run Keyword And Return Status    Should Start With    ${tag}    admin-test-data
        IF    ${is_admin}
            ${has_admin_tag}=    Set Variable    ${TRUE}
        END

        ${is_combined}=    Run Keyword And Return Status    Should Start With    ${tag}    combined-test-data
        IF    ${is_combined}
            ${has_combined_tag}=    Set Variable    ${TRUE}
        END

        ${is_desktop}=    Run Keyword And Return Status    Should Start With    ${tag}    desktop-test-data
        ${is_mobile_android}=    Run Keyword And Return Status    Should Start With    ${tag}    mobile-android-data
        ${is_mobile_iphone}=    Run Keyword And Return Status    Should Start With    ${tag}    mobile-iphone-data
        IF    ${is_desktop} or ${is_mobile_android} or ${is_mobile_iphone}
            ${has_user_tag}=    Set Variable    ${TRUE}
        END

        # Check for special tags
        ${is_permissions}=    Run Keyword And Return Status    Should Start With    ${tag}    permissions
        IF    ${is_permissions}
            ${has_permissions_tag}=    Set Variable    ${TRUE}
        END
    END

    # Log parsed results for easy debugging
    Log
    ...    📊 Parsed tags: data_set='${data_set_name}', admin=${has_admin_tag}, combined=${has_combined_tag}, permissions=${has_permissions_tag}, user=${has_user_tag}

    RETURN    ${data_set_name}    ${has_admin_tag}    ${has_combined_tag}    ${has_permissions_tag}    ${has_user_tag}

Use Single User Mode From Parsed Tags
    [Documentation]    Sets test variables based on pre-parsed tag flags in single user mode    ...
    ...    Arguments:
    ...    - has_admin: Boolean indicating admin test
    ...    - has_combined: Boolean indicating combined test
    ...    - has_permissions: Boolean indicating permission test
    ...    - has_user: Boolean indicating user test
    [Arguments]    ${has_admin}    ${has_combined}    ${has_permissions}    ${has_user}

    # Set user variables for user and combined tests
    IF    not ${has_admin} or ${has_combined}
        Log    Using single user mode: ${BASIC_USER_MALE_FULLNAME}
        Set Test Variable    ${CURRENT_USER_EMAIL}    ${BASIC_USER_MALE_EMAIL}
        Set Test Variable    ${CURRENT_USER_HETU}    ${BASIC_USER_MALE_HETU}
        Set Test Variable    ${CURRENT_USER_PHONE}    ${BASIC_USER_MALE_PHONE}
        Set Test Variable    ${CURRENT_USER_FIRST_NAME}    ${BASIC_USER_MALE_FIRSTNAME}
        Set Test Variable    ${CURRENT_USER_LAST_NAME}    ${BASIC_USER_MALE_LASTNAME}
        Set Test Variable    ${CURRENT_USER_FULLNAME}    ${BASIC_USER_MALE_FIRSTNAME} ${BASIC_USER_MALE_LASTNAME}
        Set Test Variable    ${CURRENT_PASSWORD}    ${BASIC_USER_MALE_PASSWORD}
    END

    # Set admin variables for admin and combined tests
    IF    ${has_admin} or ${has_combined}
        IF    ${has_permissions}
            Log    Permission test detected - loading Django admin and permission target only
            Use Single Django And Permission Admin Mode
            Log    ✓ Permission test: Django admin and permission target variables set
        ELSE
            # Normal admin test: Load only standard admin
            Use Single Admin User Mode
            Log    ✓ Single admin mode: Admin variables set
        END
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

Use Single Django And Permission Admin Mode
    [Documentation]    Sets admin variables for permission tests in single mode
    ...
    ...    Sets two groups of variables:
    ...    1. DJANGO_ADMIN_* (Kari Kekkonen - performs permission changes)
    ...    2. PERMISSION_TARGET_ADMIN_* (Marika Salminen - whose permissions are modified)
    ...
    ...    Note: Does NOT set ADMIN_CURRENT_USER_*
    ...    Permission tests explicitly use PERMISSION_TARGET_ADMIN_* for login
    Log    Using single Django and permission admin mode

    # Set Django admin (Kari Kekkonen) - performs permission changes
    Log    Loading Django admin: ${BASIC_DJANGO_ADMIN_FULLNAME}
    Set Test Variable    ${DJANGO_ADMIN_EMAIL}    ${BASIC_DJANGO_ADMIN_EMAIL}
    Set Test Variable    ${DJANGO_ADMIN_HETU}    ${BASIC_DJANGO_ADMIN_HETU}
    Set Test Variable    ${DJANGO_ADMIN_FIRST_NAME}    ${BASIC_DJANGO_ADMIN_FIRSTNAME}
    Set Test Variable    ${DJANGO_ADMIN_LAST_NAME}    ${BASIC_DJANGO_ADMIN_LASTNAME}
    Set Test Variable    ${DJANGO_ADMIN_FULLNAME}    ${BASIC_DJANGO_ADMIN_FULLNAME}
    Set Test Variable    ${DJANGO_ADMIN_PASSWORD}    ${BASIC_DJANGO_ADMIN_PASSWORD}

    # Set permission target admin (Marika Salminen) - whose permissions are modified
    Log    Loading permission target admin: ${BASIC_PERMISSION_TARGET_ADMIN_FULLNAME}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_EMAIL}    ${BASIC_PERMISSION_TARGET_ADMIN_EMAIL}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_HETU}    ${BASIC_PERMISSION_TARGET_ADMIN_HETU}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_FIRST_NAME}    ${BASIC_PERMISSION_TARGET_ADMIN_FIRSTNAME}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_LAST_NAME}    ${BASIC_PERMISSION_TARGET_ADMIN_LASTNAME}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_FULLNAME}    ${BASIC_PERMISSION_TARGET_ADMIN_FULLNAME}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_PASSWORD}    ${BASIC_PERMISSION_TARGET_ADMIN_PASSWORD}

    Log    ✓ Permission test admin variables set (Django admin and permission target)

Release Test Data
    [Documentation]    Releases the PabotLib value set when test is finished
    ${status}=    Run Keyword And Return Status    Release Value Set
    IF    ${status}
        Log    ✓ Released PabotLib value set
    ELSE
        Log    No PabotLib value set to release (single user mode or non-parallel execution)
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

Set Django Admin Variables From Value Set
    [Documentation]    Sets Django admin variables from the PabotLib value set (for permission tests)
    ${django_email}=    Get Value From Set    DJANGO_ADMIN_EMAIL
    ${django_first_name}=    Get Value From Set    DJANGO_ADMIN_FIRST_NAME
    ${django_last_name}=    Get Value From Set    DJANGO_ADMIN_LAST_NAME
    ${django_hetu}=    Get Value From Set    DJANGO_ADMIN_HETU
    ${django_fullname}=    Get Value From Set    DJANGO_ADMIN_FULLNAME
    ${django_password}=    Get Value From Set    DJANGO_ADMIN_PASSWORD

    Set Test Variable    ${DJANGO_ADMIN_EMAIL}    ${django_email}
    Set Test Variable    ${DJANGO_ADMIN_FIRST_NAME}    ${django_first_name}
    Set Test Variable    ${DJANGO_ADMIN_LAST_NAME}    ${django_last_name}
    Set Test Variable    ${DJANGO_ADMIN_HETU}    ${django_hetu}
    Set Test Variable    ${DJANGO_ADMIN_FULLNAME}    ${django_fullname}
    Set Test Variable    ${DJANGO_ADMIN_PASSWORD}    ${django_password}

Set Permission Target Admin Variables From Value Set
    [Documentation]    Sets permission target admin variables from the PabotLib value set (for permission tests)
    ...    These are the admin user whose permissions will be modified
    ${target_email}=    Get Value From Set    PERMISSION_TARGET_ADMIN_EMAIL
    ${target_first_name}=    Get Value From Set    PERMISSION_TARGET_ADMIN_FIRST_NAME
    ${target_last_name}=    Get Value From Set    PERMISSION_TARGET_ADMIN_LAST_NAME
    ${target_hetu}=    Get Value From Set    PERMISSION_TARGET_ADMIN_HETU
    ${target_fullname}=    Get Value From Set    PERMISSION_TARGET_ADMIN_FULLNAME
    ${target_password}=    Get Value From Set    PERMISSION_TARGET_ADMIN_PASSWORD

    Set Test Variable    ${PERMISSION_TARGET_ADMIN_EMAIL}    ${target_email}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_FIRST_NAME}    ${target_first_name}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_LAST_NAME}    ${target_last_name}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_HETU}    ${target_hetu}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_FULLNAME}    ${target_fullname}
    Set Test Variable    ${PERMISSION_TARGET_ADMIN_PASSWORD}    ${target_password}

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
        # If PabotLib returns an empty value, use the default value (key doesn't exist yet)
        IF    "${value}" == ""
            Log
            ...    DEBUG: PabotLib value was empty (key doesn't exist), using default value '${default_value}' for '${variable_name}'
            RETURN    ${default_value}
        ELSE
            RETURN    ${value}
        END
    ELSE
        ${value}=    Get Variable Value    ${${variable_name}}    ${default_value}
        Log    DEBUG: PabotLib not available, using fallback value '${value}' for '${variable_name}'
        RETURN    ${value}
    END

# =============================================================================
# SYNCHRONIZATION KEYWORDS FOR MAIL TEST
# =============================================================================

Mark Paid Booking Test Started
    [Documentation]    Marks that the paid booking test has started execution
    Store Test Data Variable    PAID_BOOKING_STARTED    True
    Log    Marked paid booking test as started

Mark Paid Booking Test Completed
    [Documentation]    Marks that the paid booking test has completed successfully
    Store Test Data Variable    PAID_BOOKING_COMPLETED    True
    Log    Marked paid booking test as completed

Mark Paid Booking Test Failed
    [Documentation]    Marks that the paid booking test has failed
    Store Test Data Variable    PAID_BOOKING_FAILED    True
    Log    Marked paid booking test as failed

Wait For Paid Booking Completion
    [Documentation]    Waits for the paid booking test to complete (success or failure)
    [Arguments]    ${timeout}=300

    Log    Checking if paid booking test has started...

    # Poll for up to 120 seconds to see if paid booking test starts (accounts for browser setup time)
    ${start_check_timeout}=    Evaluate    time.time() + 120    modules=time
    ${started}=    Set Variable    ${EMPTY}

    WHILE    "${started}" == ""
        ${current_time}=    Evaluate    time.time()    modules=time

        IF    ${current_time} > ${start_check_timeout}
            Log    Paid booking test has not started within 120 seconds - it may not be part of this test run
            RETURN    NOT_STARTED
        END

        ${started}=    Get Test Data Variable    PAID_BOOKING_STARTED    ${EMPTY}
        Log    DEBUG: PAID_BOOKING_STARTED value: '${started}'

        IF    "${started}" == ""    Sleep    0.5s
    END

    Log    Paid booking test has started, now waiting for completion...

    # Use progressive polling for completion
    ${end_time}=    Evaluate    time.time() + ${timeout}    modules=time
    ${check_count}=    Set Variable    0
    ${start_time}=    Evaluate    time.time()    modules=time

    WHILE    True
        ${current_time}=    Evaluate    time.time()    modules=time
        ${elapsed}=    Evaluate    ${current_time} - ${start_time}
        ${check_count}=    Evaluate    ${check_count} + 1

        IF    ${current_time} > ${end_time}
            Log    Timeout after ${check_count} checks
            RETURN    TIMEOUT
        END

        # Check for successful completion (BOOKING_NUM_FOR_MAIL is set)
        ${booking_num}=    Get Test Data Variable    BOOKING_NUM_FOR_MAIL    ${EMPTY}
        ${has_booking_data}=    Run Keyword And Return Status    Should Not Be Empty    ${booking_num}

        IF    ${has_booking_data}
            ${elapsed_formatted}=    Evaluate    f"{${elapsed}:.1f}"
            Log    Test completed successfully after ${check_count} checks (${elapsed_formatted}s)
            RETURN    COMPLETED
        END

        # Check if test has explicitly marked completion (even if failed)
        ${completed}=    Get Test Data Variable    PAID_BOOKING_COMPLETED    ${EMPTY}
        ${failed}=    Get Test Data Variable    PAID_BOOKING_FAILED    ${EMPTY}

        IF    "${completed}" == "True"
            ${elapsed_formatted}=    Evaluate    f"{${elapsed}:.1f}"
            Log    Test marked as completed after ${check_count} checks (${elapsed_formatted}s)
            RETURN    COMPLETED
        ELSE IF    "${failed}" == "True"
            ${elapsed_formatted}=    Evaluate    f"{${elapsed}:.1f}"
            Log    Test failed after ${check_count} checks (${elapsed_formatted}s)
            RETURN    FAILED
        END

        # Progressive polling intervals
        IF    ${elapsed} < 180    # First 3 minutes
            Sleep    5s    # Check every 5 seconds
        ELSE IF    ${elapsed} < 240    # 3-4 minutes
            Sleep    2s    # Check every 2 seconds (getting close)
        ELSE    # After 4 minutes
            Sleep    1s    # Check every second (should complete soon)
        END
    END
