*** Settings ***
# INFO ABOUT MOBILE DEVICES
# https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/server/deviceDescriptorsSource.json
Library     Browser
Library     Dialogs
Resource    variables.robot
# DEVNOTE viewport=${None} for laptop UI


*** Variables ***
${BROWSER}              chromium
${BROWSER_FOR_MAIL}     firefox
${LOCALE}               en-US


*** Keywords ***
Set up chromium desktop browser and open url
    [Arguments]    ${input_URL}    ${DOWNLOAD_DIR}
    New Browser    ${BROWSER}    headless=true    downloadsPath=${DOWNLOAD_DIR}
    Sleep    500ms
    New Context
    ...    viewport={'width': 1920, 'height': 1080}
    ...    acceptDownloads=True
    ...    locale=${LOCALE}
    ...    timezoneId=Europe/Helsinki
    ...    ignoreHTTPSErrors=true
    New Page    ${input_URL}
    Wait For Load State    load    timeout=30s
    Set Browser Timeout    30s

Set up firefox desktop browser and open url
    [Arguments]    ${input_URL}    ${DOWNLOAD_DIR}
    New Browser    ${BROWSER_FOR_MAIL}    headless=true    downloadsPath=${DOWNLOAD_DIR}
    Sleep    500ms
    New Context
    ...    viewport={'width': 1920, 'height': 1080}
    ...    acceptDownloads=True
    ...    locale=${LOCALE}
    ...    timezoneId=Europe/Helsinki
    ...    ignoreHTTPSErrors=false
    ...    javaScriptEnabled=True
    New Page    ${input_URL}
    Wait For Load State    load    timeout=30s
    Set Browser Timeout    30s

Set up iphone 14 and open url
    [Arguments]    ${input_URL}
    ${iphone}=    Get Device    iPhone 14

    # Open the browser
    New Browser    browser=webkit    headless=true
    Sleep    500ms

    # Create a new context with the iPhone 14 device configuration and ignore HTTPS errors
    New Context    &{iphone}    isMobile=true    locale=${LOCALE}    ignoreHTTPSErrors=true    deviceScaleFactor=1

    New Page    ${input_URL}
    Wait For Load State    load    timeout=30s

    ${viewport}=    Get Viewport Size    # should return { "width": 390, "height": 664 }
    # Validate the width
    Should Be Equal As Integers    ${viewport["width"]}    390
    # Validate the height
    Should Be Equal As Integers    ${viewport["height"]}    664
    Set Browser Timeout    30s

Set up android pixel 5 and open url
    [Arguments]    ${input_URL}
    ${pixel}=    Get Device    Pixel 5

    # Open the browser
    New Browser    headless=true    browser=Chromium
    Sleep    500ms

    # Create a new context with the Pixel 5 device configuration
    New context    &{pixel}    isMobile=true    locale=${LOCALE}

    New Page    ${input_URL}
    Wait For Load State    load    timeout=30s

    ${viewport}=    Get Viewport Size    # returns { "width": 393, "height": 727 }
    # Validate the width
    Should Be Equal As Integers    ${viewport["width"]}    393    msg=The viewport width is not as expected.
    # Validate the height
    Should Be Equal As Integers    ${viewport["height"]}    727    msg=The viewport height is not as expected.

    Set Browser Timeout    30s
