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
    [Documentation]    Retrieves all banner notifications with their state

    ${query}=    Set Variable    query { bannerNotifications { edges { node { pk name state draft activeFrom activeUntil target level } } } }
    ${response}=    Make GraphQL Request    ${query}
    Should Be Equal As Strings    ${response.status_code}    200
    RETURN    ${response}

Draft All Banner Notifications
    [Documentation]    Sets ALL banner notifications to DRAFT state
    ...                This is useful for test data cleanup/reset
    ...                Requires user to be logged in as admin

    Log    Drafting all banner notifications...    console=True
    ${response}=    Get All Banner Notifications

    # Parse the response to get all notification PKs
    ${response_json}=    Set Variable    ${response.json()}
    ${notifications}=    Set Variable    ${response_json}[data][bannerNotifications][edges]
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
    [Documentation]    Deletes all banner notifications that contain the specified pattern in their name
    ...                Useful for cleaning up test data created by robots
    ...                Requires user to be logged in as admin
    [Arguments]    ${name_pattern}

    Log    Deleting notifications with pattern: "${name_pattern}"    console=True
    ${response}=    Get All Banner Notifications

    # Parse the response to get all notification PKs
    ${response_json}=    Set Variable    ${response.json()}
    ${notifications}=    Set Variable    ${response_json}[data][bannerNotifications][edges]
    ${notification_count}=    Get Length    ${notifications}

    # Counter for deleted notifications
    ${deleted_count}=    Set Variable    ${0}

    # Loop through each notification and delete if name matches pattern
    FOR    ${edge}    IN    @{notifications}
        ${node}=    Set Variable    ${edge}[node]
        ${pk}=    Set Variable    ${node}[pk]
        ${name}=    Set Variable    ${node}[name]

        # Check if name contains the pattern (case-insensitive)
        ${name_upper}=    Evaluate    """${name}""".upper()
        ${pattern_upper}=    Evaluate    """${name_pattern}""".upper()
        ${contains}=    Evaluate    """${pattern_upper}""" in """${name_upper}"""

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
