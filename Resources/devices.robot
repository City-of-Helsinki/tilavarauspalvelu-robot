*** Settings ***
# INFO ABOUT MOBILE DEVICES
# https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/server/deviceDescriptorsSource.json
Library     Browser
Resource    Resources/variables.robot


*** Variables ***
${BROWSER}=     chromium


*** Keywords ***
Set up chromium desktop browser and open url
    [Arguments]    ${input_URL}
    New Browser    ${BROWSER}    headless=False
    New Context    viewport={'width': 1920, 'height': 1080}
    New Page    ${input_URL}

Set up iphone 13 and open url
    [Arguments]    ${input_URL}
    ${iphone}=    Get Device    iPhone 13
    New Browser    headless=False    browser=Webkit
    New context    &{iphone}    isMobile=true
    New Page    ${input_URL}
    ${viewport}=    Get Viewport Size    # returns { "width": 390, "height": 664 }
    # Validate the width
    Should Be Equal As Integers    ${viewport["width"]}    390    msg=The viewport width is not as expected.
    # Validate the height
    Should Be Equal As Integers    ${viewport["height"]}    664    msg=The viewport height is not as expected.

Set up android pixel 5 and open url
    [Arguments]    ${input_URL}
    ${pixel}=    Get Device    Pixel 5
    New Browser    headless=False    browser=Chromium
    New context    &{pixel}    isMobile=true
    New Page    ${input_URL}
    ${viewport}=    Get Viewport Size    # returns { "width": 393, "height": 727 }
    # Validate the width
    Should Be Equal As Integers    ${viewport["width"]}    393    msg=The viewport width is not as expected.
    # Validate the height
    Should Be Equal As Integers    ${viewport["height"]}    727    msg=The viewport height is not as expected.
