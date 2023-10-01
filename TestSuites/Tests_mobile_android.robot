*** Settings ***
Documentation       Iphone webkit tests

Resource            ${CURDIR}/../PO/App/app_common.robot

Test Setup          User opens android chrome to landing Page


*** Test Cases ***
User logs in with suomi_fi android
    app_common.User logs in with suomi_fi mobile
