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

# OPTIONAL: Global extra HTTP header for all page requests (e.g. WAF bypass)
# - Enable by setting ${ENABLE_WAF_BYPASS_HEADER} to ${TRUE}
# - Header name defaults to X-Test-Secret
# - Secret can be provided via ${WAF_BYPASS_SECRET} or env var WAF_BYPASS_SECRET
# NOTE: WAF_BYPASS_SECRET should be provided via environment variable for security
${ENABLE_WAF_BYPASS_HEADER}     ${TRUE}
${WAF_BYPASS_HEADER_NAME}       X-Test-Secret
${WAF_BYPASS_SECRET}            ${EMPTY}


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
        # Temporarily suppress logging to prevent secret from being logged
        ${original_log_level}=    Set Log Level    NONE
        ${secret_from_env}=    Get Environment Variable    WAF_BYPASS_SECRET    default=${EMPTY}
        ${secret}=    Set Variable If    "${WAF_BYPASS_SECRET}"!=""    ${WAF_BYPASS_SECRET}    ${secret_from_env}
        Set Log Level    ${original_log_level}

        IF    "${secret}" == ""
            Log
            ...    ENABLE_WAF_BYPASS_HEADER is True but no secret provided in ${WAF_BYPASS_SECRET} nor env WAF_BYPASS_SECRET
            ...    WARN
        ELSE
            # Temporarily suppress logging to prevent secret from being logged
            ${original_log_level}=    Set Log Level    NONE
            ${headers}=    Create Dictionary    ${WAF_BYPASS_HEADER_NAME}=${secret}
            Set To Dictionary    ${context_config}    extraHTTPHeaders=${headers}
            Set Log Level    ${original_log_level}

            Log    🛡️ Added global WAF bypass header to browser context config
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
    IF    $download_dir
        Log    📂 Download Dir: ${download_dir}
    END

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

Set up chromium desktop browser and open url
    [Documentation]    Sets up Chromium desktop browser
    [Arguments]    ${input_URL}    ${DOWNLOAD_DIR}

    Apply Staggered Startup Strategy    CHROMIUM DESKTOP    ${input_URL}    ${DOWNLOAD_DIR}

    @{chrome_args}=    Create List
    ...    --no-default-browser-check
    ...    --disable-background-timer-throttling
    ...    --disable-renderer-backgrounding
    ...    --disable-backgrounding-occluded-windows
    ...    --password-store=basic
    ...    --use-mock-keychain
    ...    --disable-component-extensions-with-background-pages
    ...    --disable-default-apps
    ...    --disable-extensions
    ...    --no-sandbox
    ...    --disable-dev-shm-usage
    ...    --no-first-run
    ...    --disable-sync
    ...    --disable-translate
    ...    --disable-features=TranslateUI
    ...    --disable-popup-blocking
    ...    --disable-prompt-on-repost
    ...    --disable-hang-monitor
    ...    --disable-blink-features=AutomationControlled
    ...    --disable-web-security

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
    ${context_config}=    Create Dictionary
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

    Set Browser Timeout    40s    scope=Global
    ${did_nav}=    Gate First Navigation With PabotLib    ${input_URL}
    IF    not ${did_nav}
        Go To    ${input_URL}
        Wait For Load State    load    timeout=30s
    END

    ${cookies_after}=    Get Cookies    return_type=string
    Log    "🍪 Post-navigation cookies: ${cookies_after}"

    Log current time
    Log    🎉 BROWSER SETUP COMPLETED

Set up firefox desktop browser and open url
    # DEVNOTE: This is used for mail testing and is not currently used
    [Documentation]    Sets up Firefox browser
    [Arguments]    ${input_URL}    ${DOWNLOAD_DIR}

    Apply Staggered Startup Strategy    FIREFOX DESKTOP    ${input_URL}    ${DOWNLOAD_DIR}

    # Firefox arguments
    @{firefox_args}=    Create List
    ...    --no-remote

    Log    🔧 Firefox Arguments: ${firefox_args}
    Log    🖥️    Viewport: 1920x1080
    Log    🌍 Locale: ${LOCALE}

    # Create new browser and independent context for session isolation
    Log    🔄 Creating new Firefox browser...
    ${browserId}=    New Browser
    ...    browser=${BROWSER_FOR_MAIL}
    ...    headless=true
    ...    args=@{firefox_args}
    ...    reuse_existing=False

    Log    🔄 Creating independent Firefox context for session isolation...

    ${firefox_prefs}=    Create Dictionary
    ...    browser.sessionstore.resume_from_crash=${FALSE}
    ...    datareporting.policy.dataSubmissionEnabled=${FALSE}
    ...    toolkit.telemetry.reportingpolicy.firstRun=${FALSE}

    ${context_config}=    Create Dictionary
    ...    viewport={'width': 1920, 'height': 1080}
    ...    acceptDownloads=True
    ...    locale=${LOCALE}
    ...    timezoneId=Europe/Helsinki
    ...    ignoreHTTPSErrors=true
    ...    javaScriptEnabled=True
    ...    firefoxUserPrefs=${firefox_prefs}

    ${context_config}=    Apply Global Header To Context Config    ${context_config}
    ${contextId}=    Create Context With Optional HAR    ${context_config}    FIREFOX

    Log    🔄 Creating new Firefox page...
    ${pageDetails}=    New Page

    Log    ✅ Firefox Context Created

    # Navigate to the test URL - this will generate HAR network activity
    Set Browser Timeout    40s    scope=Global
    Log    🌐 Navigating to: ${input_URL}
    ${did_nav}=    Gate First Navigation With PabotLib    ${input_URL}
    IF    not ${did_nav}
        Go To    ${input_URL}
        Wait For Load State    load    timeout=30s
    END
    Log    ✅ Page loaded successfully

    Log current time
    Log    ================================================================================
    Log    🎉 FIREFOX SETUP COMPLETED
    Log    ================================================================================

Set up iphone 14 and open url
    [Documentation]    Sets up iPhone 14 simulation
    [Arguments]    ${input_URL}
    ${iphone}=    Get Device    iPhone 14

    Apply Staggered Startup Strategy    IPHONE 14    ${input_URL}

    # WebKit arguments for iPhone simulation
    @{webkit_args}=    Create List

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
    ${device_config}=    Create Dictionary
    ...    &{iphone}
    ...    isMobile=true
    ...    locale=${LOCALE}
    ...    ignoreHTTPSErrors=true
    ...    deviceScaleFactor=1

    ${device_config}=    Apply Global Header To Context Config    ${device_config}
    ${contextId}=    Create Context With Optional HAR    ${device_config}    IPHONE_14

    Log    🔄 Creating new iPhone page...
    ${pageDetails}=    New Page

    Log    ✅ iPhone 14 Context Created

    Set Browser Timeout    40s    scope=Global
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

    Log current time
    Log    ================================================================================
    Log    🎉 IPHONE 14 SETUP COMPLETED
    Log    ================================================================================

Set up android pixel 5 and open url
    [Documentation]    Sets up Android Pixel 5 simulation
    [Arguments]    ${input_URL}
    ${pixel}=    Get Device    Pixel 5

    Apply Staggered Startup Strategy    ANDROID PIXEL 5    ${input_URL}

    @{chrome_args}=    Create List
    ...    --no-default-browser-check
    ...    --disable-background-timer-throttling
    ...    --disable-renderer-backgrounding
    ...    --disable-backgrounding-occluded-windows
    ...    --password-store=basic
    ...    --use-mock-keychain
    ...    --disable-component-extensions-with-background-pages
    ...    --disable-default-apps
    ...    --disable-extensions
    ...    --no-sandbox
    ...    --disable-dev-shm-usage
    ...    --no-first-run
    ...    --disable-sync
    ...    --disable-translate
    ...    --disable-features=TranslateUI
    ...    --disable-popup-blocking
    ...    --disable-web-security
    ...    --disable-blink-features=AutomationControlled

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
    ${device_config}=    Create Dictionary
    ...    &{pixel}
    ...    isMobile=true
    ...    locale=${LOCALE}

    ${device_config}=    Apply Global Header To Context Config    ${device_config}
    ${contextId}=    Create Context With Optional HAR    ${device_config}    PIXEL_5

    Log    🔄 Creating new Android page...
    ${pageDetails}=    New Page

    Log    ✅ Android Pixel 5 Context Created

    Set Browser Timeout    40s    scope=Global
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

    Log current time
    Log    ================================================================================
    Log    🎉 ANDROID PIXEL 5 SETUP COMPLETED
    Log    ================================================================================

Log current time
    # Log only current local time (HH:MM:SS)
    ${now_ts}=    Get Current Date
    ${current_time}=    Convert Date    ${now_ts}    result_format=%H:%M:%S
    Log    Current local time: ${current_time}

Log current cookies
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
