*** Settings ***
Resource    ${CURDIR}/../Resources/devices.robot
Resource    ${CURDIR}/../Resources/variables.robot


*** Test Cases ***
Verify H1 Text On The Site
    # When A Webkit Browser Is Opened to the site
    # Then I Should See text ${EXPECTED_H1_TEXT}
    #    variables.Set up iphone 13 and open url
    Log To Console    toimii


*** Keywords ***
A Webkit Browser Is Opened to the site
    # new    ${URL}    browser=chromium
    New Browser    browser=Webkit    headless=False
    # New Page    ${URL}

I Should See text ${EXPECTED_H1_TEXT}
    ${EXPECTED_H1}=    Get Text    css=h1
    Should Contain    ${EXPECTED_H1}    ${EXPECTED_H1_TEXT}

# Set up iphone 13
    # INFO ABOUT MOBILE DEVICES
    # https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/server/deviceDescriptorsSource.json
 #    ${iphone}=    Get Device    iPhone 13
    # New Browser    headless=False    # browser=Webkit
    #    New context    &{iphone}    # isMobile=true
    # New Page    ${URL}
    # ${viewport}=    Get Viewport Size    # returns { "width": 375, "height": 812 }
    # Validate the width
    # Should Be Equal As Integers    ${viewport["width"]}    390    msg=The viewport width is not as expected.
    # Validate the height
    # Should Be Equal As Integers    ${viewport["height"]}    664    msg=The viewport height is not as expected.

# Set up android pixel 5
    # INFO ABOUT MOBILE DEVICES
    # https://github.com/microsoft/playwright/blob/main/packages/playwright-core/src/server/deviceDescriptorsSource.json
 #    ${pixel}=    Get Device    iPhone 13
    # New Browser    headless=False    # browser=Webkit
    #    New context    &{pixel}    # isMobile=true
    # New Page    ${URL}
    # ${viewport}=    Get Viewport Size    # returns { "width": 393, "height": 727 }
    # Validate the width
    # Should Be Equal As Integers    ${viewport["width"]}    393    msg=The viewport width is not as expected.
    # Validate the height
    # Should Be Equal As Integers    ${viewport["height"]}    727    msg=The viewport height is not as expected.
