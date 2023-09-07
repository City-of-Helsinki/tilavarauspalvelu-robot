*** Settings ***
Documentation       A test suite with a single test for opening Chrome and navigating to YouTube.
# Library    AppiumLibrary


*** Variables ***
# appium --allow-insecure chromedriver_autodownload
${LOCAL_URL}                    http://localhost:4723/wd/hub
${ANDROID_AUTOMATION_NAME}      UIAutomator2
${URL}                          https://www.examble.com
${PLATFORM_NAME}                Android
# ${DEVICE_NAME}    Pixel_3a_testirobo
${DEVICE_NAME}                  Pixel_3_wanharobo
${PLATFORM_VERSION}             11
${BROWSER_NAME}                 Chrome
${APP}                          C:\Users\RistomattiRinne\AndroidStudioProjects\Robot_test\app\build\outputs\apk\debug\app-debug.apk


*** Test Cases ***
# Open Chrome And Navigate To YouTube
 #    Open Browser To YouTube
#    Navigate website


*** Keywords ***
# Open Browser To YouTube
 #    [Documentation]    Open Chrome Browser And Navigate To YouTube
 #    Open Application
...    ${LOCAL_URL}
...    automationName=${ANDROID_AUTOMATION_NAME}
...    platformName=${PLATFORM_NAME}
...    platformVersion=${PLATFORM_VERSION}
...    deviceName=${DEVICE_NAME}
...    browserName=${BROWSER_NAME}
Navigate website
    #    Go To Url    https://www.example.com
    Sleep    10s    # Wait for a few seconds to view the website
    # ...    app=${APP}
    # ...    ensureWebviewsHavePages=True
