*** Settings ***
Documentation     GraphQL API commands for interacting with Varaamo backend
Resource          variables.robot
Library           Browser
Library           RequestsLibrary
Library           Collections
Library           String


*** Keywords ***
Make GraphQL Request
    [Documentation]    Requires user to be logged in (uses existing cookies from Browser)
    [Arguments]    ${graphql_query}    ${variables}={}

    # Get CSRF token and cookies from Browser
    ${cookies}=    Get Cookies
    ${csrf_token}=    Evaluate    next((c['value'] for c in ${cookies} if c['name'] == 'csrftoken'), None)
    ${sessionid}=    Evaluate    next((c['value'] for c in ${cookies} if c['name'] == 'sessionid'), None)

    # Build request body
    ${body}=    Evaluate    json.dumps({"query": """${graphql_query}""", "variables": ${variables}})    json

    # Build headers
    ${origin}=    Evaluate    "${URL_TEST}".rstrip('/')
    VAR    &{headers}
    ...    Content-Type=application/json
    ...    x-csrftoken=${csrf_token}
    ...    Cookie=csrftoken=${csrf_token}; sessionid=${sessionid}
    ...    Referer=${URL_TEST}kasittely/notifications
    ...    Origin=${origin}

    # Make GraphQL request using RequestsLibrary
    ${response}=    POST    ${URL_TEST}graphql/    data=${body}    headers=${headers}    expected_status=any

    RETURN    ${response}

Get All Banner Notifications
    [Documentation]    Retrieves all banner notifications regardless of state
    ...                Returns all notifications (DRAFT, ACTIVE, SCHEDULED, etc.)

    # Query all notifications without filter
    # Include message fields for pattern matching
    ${query}=    Set Variable    query { bannerNotifications { edges { node { pk name state draft activeFrom activeUntil target level messageFi messageEn messageSv } } } }
    ${response}=    Make GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    RETURN    ${response}

Get Filtered Banner Notifications
    [Documentation]    Retrieves banner notifications filtered by state
    ...                Queries all notifications and filters in Robot Framework code
    [Arguments]    @{states}

    ${response}=    Get All Banner Notifications
    ${response_json}=    Set Variable    ${response.json()}
    ${all_notifications}=    Set Variable    ${response_json}[data][bannerNotifications][edges]

    # Convert states varargs to list for evaluation
    VAR    @{states_list}    @{states}

    # Filter notifications by state
    VAR    @{filtered_edges}
    FOR    ${edge}    IN    @{all_notifications}
        ${node}=    Set Variable    ${edge}[node]
        ${state}=    Set Variable    ${node}[state]
        ${state_matches}=    Evaluate    $state in $states_list
        IF    ${state_matches}    Append To List    ${filtered_edges}    ${edge}
    END

    RETURN    ${filtered_edges}

Draft All Banner Notifications
    [Documentation]    Sets ALL banner notifications to DRAFT state
    ...                Requires user to be logged in as admin

    Log    Drafting all banner notifications...    console=True
    ${notifications}=    Get Filtered Banner Notifications    DRAFT    ACTIVE    SCHEDULED
    ${notification_count}=    Get Length    ${notifications}

    # Counter for drafted notifications
    ${drafted_count}=    Set Variable    ${0}

    # Loop through each notification and set to draft
    FOR    ${edge}    IN    @{notifications}
        ${node}=    Set Variable    ${edge}[node]
        ${pk}=    Set Variable    ${node}[pk]
        ${name}=    Set Variable    ${node}[name]
        ${current_state}=    Set Variable    ${node}[state]

        Log    Processing notification ${pk}: "${name}" (${current_state})    level=DEBUG

        # Only update if not already in draft
        IF    '${current_state}' != 'DRAFT'
            # Make the GraphQL mutation to set draft=true
            ${mutation}=    Set Variable    mutation UpdateBannerNotification($input: BannerNotificationUpdateMutationInput!) { updateBannerNotification(input: $input) { pk name } }
            ${variables}=    Evaluate    {"input": {"pk": ${pk}, "draft": True}}
            ${result}=    Make GraphQL Request    ${mutation}    ${variables}
            ${drafted_count}=    Evaluate    ${drafted_count} + 1
            Log    Drafted notification ${pk}    level=DEBUG
        END
    END

    Log    ✓ Drafted ${drafted_count} notifications (${notification_count} total)    console=True

Delete Notifications By Name Pattern
    [Documentation]    Deletes all banner notifications that contain the specified pattern in their name or message
    ...                Checks name, messageFi, messageEn, and messageSv fields
    ...                Includes both DRAFT and ACTIVE notifications in the deletion
    ...                Requires user to be logged in as admin
    [Arguments]    ${name_pattern}

    Log    Deleting notifications with pattern: "${name_pattern}"    console=True
    ${notifications}=    Get Filtered Banner Notifications    DRAFT    ACTIVE
    ${notification_count}=    Get Length    ${notifications}

    # Counter for deleted notifications
    ${deleted_count}=    Set Variable    ${0}

    # Loop through each notification and delete if name or message matches pattern
    FOR    ${edge}    IN    @{notifications}
        ${node}=    Set Variable    ${edge}[node]
        ${pk}=    Set Variable    ${node}[pk]
        ${name}=    Set Variable    ${node}[name]
        ${message_fi}=    Get From Dictionary    ${node}    messageFi    default=${EMPTY}
        ${message_en}=    Get From Dictionary    ${node}    messageEn    default=${EMPTY}
        ${message_sv}=    Get From Dictionary    ${node}    messageSv    default=${EMPTY}

        # Check if pattern appears in name or any message field (case-insensitive)
        ${pattern_upper}=    Evaluate    """${name_pattern}""".upper()
        ${name_upper}=    Evaluate    """${name}""".upper()
        ${message_fi_upper}=    Evaluate    """${message_fi}""".upper()
        ${message_en_upper}=    Evaluate    """${message_en}""".upper()
        ${message_sv_upper}=    Evaluate    """${message_sv}""".upper()

        ${in_name}=    Evaluate    """${pattern_upper}""" in """${name_upper}"""
        ${in_fi}=    Evaluate    """${pattern_upper}""" in """${message_fi_upper}"""
        ${in_en}=    Evaluate    """${pattern_upper}""" in """${message_en_upper}"""
        ${in_sv}=    Evaluate    """${pattern_upper}""" in """${message_sv_upper}"""
        ${contains}=    Evaluate    ${in_name} or ${in_fi} or ${in_en} or ${in_sv}

        IF    ${contains}
            Log    Deleting: ${pk} - "${name}"    level=DEBUG

            # Make the GraphQL mutation to delete the notification
            ${mutation}=    Set Variable    mutation DeleteBannerNotification($input: BannerNotificationDeleteMutationInput!) { deleteBannerNotification(input: $input) { deleted } }
            ${variables}=    Evaluate    {"input": {"pk": ${pk}}}
            ${result}=    Make GraphQL Request    ${mutation}    ${variables}

            ${deleted_count}=    Evaluate    ${deleted_count} + 1
        ELSE
            Log    Skipping: ${pk} - "${name}"    level=DEBUG
        END
    END

    Log    ✓ Deleted ${deleted_count} notifications (${notification_count} total checked)    console=True
