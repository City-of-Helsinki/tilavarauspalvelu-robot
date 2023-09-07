*** Settings ***
Library     Browser
Resource    ../Resources/variables.robot


*** Keywords ***
Set up iphone 13 and open url
    [Arguments]    ${input_URL}
    # INFO ABOUT MOBILE DEVICES
    # https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/server/deviceDescriptorsSource.json

    ${iphone}=    Get Device    iPhone 13
    New Browser    headless=False    browser=Webkit
    New context    &{iphone}    isMobile=true
    New Page    ${input_URL}
    ${viewport}=    Get Viewport Size    # returns { "width": 375, "height": 812 }
    # Validate the width
    Should Be Equal As Integers    ${viewport["width"]}    390    msg=The viewport width is not as expected.
    # Validate the height
    Should Be Equal As Integers    ${viewport["height"]}    664    msg=The viewport height is not as expected.

Set up android pixel 5 and open url
    [Arguments]    ${input_URL}
    # INFO ABOUT MOBILE DEVICES
    # https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/server/deviceDescriptorsSource.json

    ${pixel}=    Get Device    Pixel 5
    New Browser    headless=False    browser=Chromium
    New context    &{pixel}    isMobile=true
    New Page    ${input_URL}
    ${viewport}=    Get Viewport Size    # returns { "width": 393, "height": 727 }
    # Validate the width
    Should Be Equal As Integers    ${viewport["width"]}    393    msg=The viewport width is not as expected.
    # Validate the height
    Should Be Equal As Integers    ${viewport["height"]}    727    msg=The viewport height is not as expected.
