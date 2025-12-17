*** Settings ***
# INFO ABOUT MOBILE DEVICES
# https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/server/deviceDescriptorsSource.json
Library     Browser
Library     DateTime
Library     OperatingSystem
Library     String
Library     Collections
Library     pabot.PabotLib
Resource    variables.robot
Resource    har_recording.robot
# NOTE: viewport=${None} for laptop UI


*** Variables ***
${BROWSER}                      chromium
${BROWSER_FOR_MAIL}             firefox
${LOCALE}                       en-US
${ENABLE_FIRST_NAV_GATE}        ${TRUE}

# Set WAF_BYPASS_SECRET in .env or disable via ${ENABLE_WAF_BYPASS_HEADER}
${ENABLE_WAF_BYPASS_HEADER}     ${TRUE}
${WAF_BYPASS_HEADER_NAME}       X-Test-Secret
# ${WAF_BYPASS_SECRET} loaded from env_loader.py


*** Keywords ***
Gate First Navigation With PabotLib
    [Documentation]    Only one worker performs the initial open + CSRF bootstrap; others wait briefly.
    [Arguments]    ${input_URL}

    ${enabled}=    Get Variable Value    ${ENABLE_FIRST_NAV_GATE}    ${TRUE}
    IF    not ${enabled}    RETURN    ${False}

    ${done}=    Get Parallel Value For Key    FIRST_NAV_DONE
    IF    "${done}" == "true"
        ${jitter}=    Evaluate    random.uniform(0.8, 1.6)    random
        Sleep    ${jitter}s
        RETURN    ${False}
    END

    Acquire Lock    FIRST_NAV_BOOTSTRAP
    ${done2}=    Get Parallel Value For Key    FIRST_NAV_DONE
    ${did_nav}=    Set Variable    ${False}
    IF    "${done2}" != "true"
        Log    🌐 Gated first navigation by this worker
        Go To    ${input_URL}
        Wait For Load State    networkidle    timeout=45s
        ${post_nav_sleep}=    Evaluate    random.uniform(0.6, 0.9)    random
        Sleep    ${post_nav_sleep}s
        Set Parallel Value For Key    FIRST_NAV_DONE    true
        ${did_nav}=    Set Variable    ${True}
    END
    Release Lock    FIRST_NAV_BOOTSTRAP

    IF    not ${did_nav}
        ${jitter}=    Evaluate    random.uniform(0.8, 1.6)    random
        Sleep    ${jitter}s
    END

    RETURN    ${did_nav}

Check First Nav Done
    ${val}=    Get Parallel Value For Key    FIRST_NAV_DONE
    Should Be Equal As Strings    ${val}    true

Apply Global Header To Context Config
    [Documentation]    Adds WAF bypass headers to context config when enabled
    [Arguments]    ${context_config}

    ${waf_header_enabled}=    Get Variable Value    ${ENABLE_WAF_BYPASS_HEADER}    ${TRUE}
    IF    ${waf_header_enabled}
        # Suppress logging
        ${original_log_level}=    Set Log Level    NONE
        ${waf_secret}=    Get Variable Value    ${WAF_BYPASS_SECRET}    ${EMPTY}
        Set Log Level    ${original_log_level}

        IF    "${waf_secret}" != ""
            # Re-suppress logging
            ${original_log_level}=    Set Log Level    NONE
            VAR    &{headers}    ${WAF_BYPASS_HEADER_NAME}=${waf_secret}
            Set To Dictionary    ${context_config}    extraHTTPHeaders=${headers}
            Set Log Level    ${original_log_level}

            Log    🛡️ Added global WAF bypass header to browser context config
        ELSE
            Log
            ...    ENABLE_WAF_BYPASS_HEADER is True but WAF_BYPASS_SECRET not found in .env file
            ...    WARN
        END
    END

    RETURN    ${context_config}

Apply Staggered Startup Strategy
    [Documentation]    Staggers browser startup to prevent resource conflicts in parallel execution
    [Arguments]    ${browser_type}    ${input_URL}    ${download_dir}=${EMPTY}

    ${test_name}=    Get Variable Value    ${TEST NAME}    unknown_test
    ${suite_name}=    Get Variable Value    ${SUITE NAME}    unknown_suite

    Log    🚀 STARTING ${browser_type} SETUP
    Log    📋 Test: ${test_name}
    Log    📁 Suite: ${suite_name}
    Log    🌐 URL: ${input_URL}
    IF    $download_dir    Log    📂 Download Dir: ${download_dir}

    # Staggered startup strategy for parallel execution
    ${pool_id}=    Get Variable Value    ${PABOTEXECUTIONPOOLID}    ${NONE}
    IF    '${pool_id}' != '${NONE}'
        # Progressive delay: 0s, 8s, 16s, 24s, 32s, 40s, etc.
        ${base_delay}=    Evaluate    int(${pool_id}) * 8
        # Add small random component to prevent perfect synchronization
        ${random_offset}=    Evaluate    random.uniform(2.0, 4.0)    random
        ${total_delay}=    Evaluate    ${base_delay} + ${random_offset}
        ${formatted_delay}=    Evaluate    f"{${total_delay}:.1f}"
        ${random_offset_fmt}=    Evaluate    f"{${random_offset}:.1f}"
        Log    "⏱️ Worker ${pool_id}: Staggering ${browser_type} startup by ${formatted_delay} seconds"
        Log    "📊 Delay breakdown: Base=${base_delay}s + Random=${random_offset_fmt}s = Total=${formatted_delay}s"
        Sleep    ${total_delay}s
        Log    "✅ Stagger delay completed for Worker ${pool_id}"
    ELSE
        # Single execution - small random delay to avoid system resource conflicts
        ${random_delay}=    Evaluate    random.uniform(0.5, 1.5)    random
        ${random_delay_fmt}=    Evaluate    f"{${random_delay}:.1f}"
        Log    "⏱️ Single execution: Adding ${random_delay_fmt}s random delay"
        Sleep    ${random_delay}s
        Log    "✅ Single execution delay completed"
    END

Set Up Chromium Desktop Browser And Open Url
    [Documentation]    Sets up Chromium desktop browser
    [Arguments]    ${input_URL}    ${DOWNLOAD_DIR}

    Apply Staggered Startup Strategy    CHROMIUM DESKTOP    ${input_URL}    ${DOWNLOAD_DIR}

    VAR    @{chrome_args}    --no-default-browser-check    # Disables default browser check dialog
    ...    --disable-background-timer-throttling    # Prevents throttling of timer tasks from background pages
    ...    --disable-renderer-backgrounding    # Prevents renderer process backgrounding
    ...    --disable-backgrounding-occluded-windows    # Disables backgrounding renders for occluded windows
    ...    --password-store=basic    # Uses basic password storage backend (kwallet/kwallet5/kwallet6/gnome-libsecret/basic)
    ...    --use-mock-keychain    # Uses mock keychain for testing
    ...    --disable-component-extensions-with-background-pages    # Disables default component extensions with background pages
    ...    --disable-default-apps    # Disables installation of default apps on first run
    ...    --disable-extensions    # Disables all extensions
    ...    --no-sandbox    # Disables sandbox for all process types (testing only)
    ...    --disable-dev-shm-usage    # Workaround for small /dev/shm in VM environments
    ...    --no-first-run    # Skips First Run tasks and dialogs
    ...    --disable-sync    # Disables sync functionality
    ...    --disable-translate    # Disables translate functionality
    ...    --disable-features=TranslateUI    # Disables Translate UI feature
    ...    --disable-popup-blocking    # Disables pop-up blocking
    ...    --disable-prompt-on-repost    # Disables prompt when navigating to POST result pages
    ...    --disable-hang-monitor    # Suppresses hang monitor dialogs in renderer processes
    ...    --disable-blink-features=AutomationControlled    # Disables AutomationControlled blink feature
    ...    --disable-web-security    # Disables same-origin policy (testing only)

    Log    🔧 Chrome Arguments: ${chrome_args}
    Log    🌍 Locale: ${LOCALE}

    Log    🔄 Creating new browser...
    ${browserId}=    New Browser
    ...    browser=${BROWSER}
    ...    headless=true
    ...    devtools=false
    ...    args=@{chrome_args}
    ...    reuse_existing=False

    # Create context with optional HAR recording (controlled by ENABLE_HAR_RECORDING variable)
    VAR    &{context_config}
    ...    viewport={'width': 1440, 'height': 900}
    ...    acceptDownloads=True
    ...    locale=${LOCALE}
    ...    timezoneId=Europe/Helsinki
    ...    ignoreHTTPSErrors=true
    ...    deviceScaleFactor=1

    ${context_config}=    Apply Global Header To Context Config    ${context_config}
    ${contextId}=    Create Context With Optional HAR    ${context_config}    CHROMIUM

    ${pageDetails}=    New Page

    Log    🆔 Browser ID: ${browserId}
    Log    🆔 Context ID: ${contextId}
    Log    📄 Page Details: ${pageDetails}

    # Check for cookies before navigation to verify clean state
    ${fresh_cookies}=    Get Cookies    return_type=string
    Log    "🔍 Fresh context cookies: ${fresh_cookies}"

    Set Browser Timeout    ${BROWSER_TIMEOUT_GLOBAL}    scope=Global
    ${did_nav}=    Gate First Navigation With PabotLib    ${input_URL}
    IF    not ${did_nav}
        Go To    ${input_URL}
        Wait For Load State    load    timeout=30s
    END

    ${cookies_after}=    Get Cookies    return_type=string
    Log    "🍪 Post-navigation cookies: ${cookies_after}"

    Log Current Time
    Log    🎉 BROWSER SETUP COMPLETED

Set Up Firefox Desktop Browser And Open Url
    # DEVNOTE: This is used for permission tests
    [Documentation]    Sets up Firefox browser for permission tests - separate session from Django admin and Admin UI
    [Arguments]    ${input_URL}    ${DOWNLOAD_DIR}

    Apply Staggered Startup Strategy    FIREFOX DESKTOP    ${input_URL}    ${DOWNLOAD_DIR}

    # Firefox arguments
    VAR    @{firefox_args}    --no-remote    # Prevents Firefox from connecting to a running instance

    Log    🔧 Firefox Arguments: ${firefox_args}
    Log    🌍 Locale: ${LOCALE}

    # Create new browser and independent context for session isolation
    Log    🔄 Creating new Firefox browser...
    ${browserId}=    New Browser
    ...    browser=${BROWSER_FOR_MAIL}
    ...    headless=true
    ...    args=@{firefox_args}
    ...    reuse_existing=False

    Log    🔄 Creating independent Firefox context for session isolation...

    VAR    &{context_config}
    ...    viewport={'width': 1440, 'height': 900}
    ...    acceptDownloads=True
    ...    locale=${LOCALE}
    ...    timezoneId=Europe/Helsinki
    ...    ignoreHTTPSErrors=true

    ${context_config}=    Apply Global Header To Context Config    ${context_config}
    ${contextId}=    Create Context With Optional HAR    ${context_config}    FIREFOX

    Log    🔄 Creating new Firefox page...
    ${pageDetails}=    New Page

    Log    ✅ Firefox Context Created

    # Navigate to the test URL - this will generate HAR network activity
    Set Browser Timeout    ${BROWSER_TIMEOUT_GLOBAL}    scope=Global
    Log    🌐 Navigating to: ${input_URL}
    ${did_nav}=    Gate First Navigation With PabotLib    ${input_URL}
    IF    not ${did_nav}
        Go To    ${input_URL}
        Wait For Load State    load    timeout=30s
    END
    Log    ✅ Page loaded successfully

    Log Current Time
    Log    🎉 BROWSER SETUP COMPLETED

Set Up Iphone 14 And Open Url
    [Documentation]    Sets up iPhone 14 simulation
    [Arguments]    ${input_URL}
    ${iphone}=    Get Device    iPhone 14

    Apply Staggered Startup Strategy    IPHONE 14    ${input_URL}

    # WebKit arguments for iPhone simulation
    VAR    @{webkit_args}    @{EMPTY}

    Log    🔧 WebKit Arguments: ${webkit_args} (empty - WebKit has limited CLI support)
    Log    📱 Device: iPhone 14
    Log    📺 Expected Viewport: 390x664
    Log    🌍 Locale: ${LOCALE}

    Log    🔄 Creating new WebKit browser...
    ${browserId}=    New Browser
    ...    browser=webkit
    ...    headless=true
    ...    args=@{webkit_args}
    ...    reuse_existing=False

    Log    🔄 Creating independent iPhone context for session isolation...

    # Create context with optional HAR recording (controlled by ENABLE_HAR_RECORDING variable)
    VAR    &{device_config}
    ...    isMobile=true
    ...    locale=${LOCALE}
    ...    ignoreHTTPSErrors=true
    ...    deviceScaleFactor=1
    # Merge iPhone device properties into config
    Set To Dictionary    ${device_config}    &{iphone}

    ${device_config}=    Apply Global Header To Context Config    ${device_config}
    ${contextId}=    Create Context With Optional HAR    ${device_config}    IPHONE_14

    Log    🔄 Creating new iPhone page...
    ${pageDetails}=    New Page

    Log    ✅ iPhone 14 Context Created

    Set Browser Timeout    ${BROWSER_TIMEOUT_GLOBAL}    scope=Global
    Log    🌐 Navigating to: ${input_URL}
    ${did_nav}=    Gate First Navigation With PabotLib    ${input_URL}
    IF    not ${did_nav}
        Go To    ${input_URL}
        Wait For Load State    load    timeout=30s
    END

    ${viewport}=    Get Viewport Size    # should return { "width": 390, "height": 664 }
    Log    📏 Actual Viewport: ${viewport["width"]}x${viewport["height"]}

    Should Be Equal As Integers    ${viewport["width"]}    390
    Should Be Equal As Integers    ${viewport["height"]}    664
    Log    ✅ Viewport validation passed: 390x664

    Log Current Time
    Log    ================================================================================
    Log    🎉 IPHONE 14 SETUP COMPLETED
    Log    ================================================================================

Set Up Android Pixel 5 And Open Url
    [Documentation]    Sets up Android Pixel 5 simulation
    [Arguments]    ${input_URL}
    ${pixel}=    Get Device    Pixel 5

    Apply Staggered Startup Strategy    ANDROID PIXEL 5    ${input_URL}

    VAR    @{chrome_args}    --no-default-browser-check    # Disables default browser check dialog
    ...    --disable-background-timer-throttling    # Prevents throttling of timer tasks from background pages
    ...    --disable-renderer-backgrounding    # Prevents renderer process backgrounding
    ...    --disable-backgrounding-occluded-windows    # Disables backgrounding renders for occluded windows
    ...    --password-store=basic    # Uses basic password storage backend (kwallet/kwallet5/kwallet6/gnome-libsecret/basic)
    ...    --use-mock-keychain    # Uses mock keychain for testing
    ...    --disable-component-extensions-with-background-pages    # Disables default component extensions with background pages
    ...    --disable-default-apps    # Disables installation of default apps on first run
    ...    --disable-extensions    # Disables all extensions
    ...    --no-sandbox    # Disables sandbox for all process types (testing only)
    ...    --disable-dev-shm-usage    # Workaround for small /dev/shm in VM environments
    ...    --no-first-run    # Skips First Run tasks and dialogs
    ...    --disable-sync    # Disables sync functionality
    ...    --disable-translate    # Disables translate functionality
    ...    --disable-features=TranslateUI    # Disables Translate UI feature
    ...    --disable-popup-blocking    # Disables pop-up blocking
    ...    --disable-web-security    # Disables same-origin policy (testing only)
    ...    --disable-blink-features=AutomationControlled    # Disables AutomationControlled blink feature

    Log    🔧 Chrome Arguments: ${chrome_args}
    Log    📱 Device: Pixel 5
    Log    📺 Expected Viewport: 393x727
    Log    🌍 Locale: ${LOCALE}

    Log    🔄 Creating new Chromium browser...
    ${browserId}=    New Browser
    ...    browser=Chromium
    ...    headless=true
    ...    args=@{chrome_args}
    ...    reuse_existing=False

    Log    🔄 Creating independent Android context for session isolation...

    # Create context with optional HAR recording (controlled by ENABLE_HAR_RECORDING variable)
    VAR    &{device_config}
    ...    isMobile=true
    ...    locale=${LOCALE}
    # Merge Pixel device properties into config
    Set To Dictionary    ${device_config}    &{pixel}

    ${device_config}=    Apply Global Header To Context Config    ${device_config}
    ${contextId}=    Create Context With Optional HAR    ${device_config}    PIXEL_5

    Log    🔄 Creating new Android page...
    ${pageDetails}=    New Page

    Log    ✅ Android Pixel 5 Context Created

    Set Browser Timeout    ${BROWSER_TIMEOUT_GLOBAL}    scope=Global
    Log    🌐 Navigating to: ${input_URL}
    ${did_nav}=    Gate First Navigation With PabotLib    ${input_URL}
    IF    not ${did_nav}
        Go To    ${input_URL}
        Wait For Load State    load    timeout=30s
    END

    ${viewport}=    Get Viewport Size    # returns { "width": 393, "height": 727 }
    Log    📏 Actual Viewport: ${viewport["width"]}x${viewport["height"]}

    Should Be Equal As Integers    ${viewport["width"]}    393    msg=The viewport width is not as expected.
    Should Be Equal As Integers    ${viewport["height"]}    727    msg=The viewport height is not as expected.
    Log    ✅ Viewport validation passed: 393x727

    Log Current Time
    Log    ================================================================================
    Log    🎉 ANDROID PIXEL 5 SETUP COMPLETED
    Log    ================================================================================

Log Current Time
    # Log only current local time (HH:MM:SS)
    ${now_ts}=    Get Current Date
    ${current_time}=    Convert Date    ${now_ts}    result_format=%H:%M:%S
    Log    Current local time: ${current_time}

Log Current Cookies
    Sleep    4s
    ${fresh_cookies}=    Get Cookies    return_type=string
    Log    "🔍 cookies: ${fresh_cookies}"

Teardown Browser With HAR Finalization
    [Documentation]    Properly closes browser and finalizes HAR recording for pabot tests

    Log    🔄 Starting browser teardown...

    TRY
        Close Browser
        Log    ✅ Browser closed successfully
    EXCEPT    AS    ${error}
        Log    ⚠️ Error closing browser: ${error}
    END

    Log    🎉 Browser teardown completed

# HAR recording is automatically enabled for all browser contexts
