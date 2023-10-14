*** Settings ***
Resource    ../../Resources/users.robot
Library     Browser


*** Keywords ***
Login Suomi_fi
    [Arguments]    ${input_hetu}
    Click    css=.login-method.login-method-heltunnistussuomifi
    Wait For Elements State    css=#li_fakevetuma2    visible
    Click    css=#li_fakevetuma2
    Type Text    css=#hetu_input    ${input_hetu}
    Click    css=#tunnistaudu
    Click    css=#continue-button

Login Suomi_fi mobile
    [Arguments]    ${input_hetu}
    Click    css=.login-method.login-method-heltunnistussuomifi
    Wait For Elements State    css=#li_fakevetuma2    visible
    Click    css=#li_fakevetuma2
    Type Text    css=#hetu_input    ${input_hetu}
    Click    css=#tunnistaudu
    Click    css=#continue-button
