*** Settings ***
Resource    ../../Resources/users.robot
Library     Browser
Library     Dialogs


*** Keywords ***
Login Suomi_fi
    [Arguments]    ${input_hetu}
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=social-suomi_fi    visible    timeout=10s
    Click    id=social-suomi_fi
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=li_fakevetuma2    visible    timeout=10s
    Click    css=#li_fakevetuma2
    Wait For Load State    load    timeout=15s
    Type Text    css=#hetu_input    ${input_hetu}
    Click    css=#tunnistaudu
    Sleep    1s
    Click    css=#continue-button
    Sleep    1s
    Wait For Load State    load    timeout=15s

Login Suomi_fi mobile
    [Arguments]    ${input_hetu}
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=social-suomi_fi    visible    timeout=15s
    Click    id=social-suomi_fi
    Wait For Load State    load    timeout=15s
    Wait For Elements State    id=li_fakevetuma2    visible    timeout=15s
    Click    nav >> id=li_fakevetuma2
    Wait For Load State    load    timeout=15s
    Type Text    css=#hetu_input    ${input_hetu}
    Click    css=#tunnistaudu
    Sleep    1s
    Click    css=#continue-button
    Sleep    1s
    Wait For Load State    load    timeout=15s
