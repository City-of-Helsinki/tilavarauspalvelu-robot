*** Settings ***
Documentation       Iphone webkit tests

Resource            ${CURDIR}/../PO/App/app_common.robot
Resource            ${CURDIR}/../PO/App/app_user.robot

Test Setup          User opens iphone webkit to landing Page


*** Test Cases ***
# User logs in with suomi_fi iphone
# app_common.User logs in with suomi_fi mobile

User can make a free single booking mobile
    app_common.User logs in with suomi_fi mobile
    app_user.User navigates to single booking page mobile
    app_user.User uses search to find right unit
    app_user.User selects the time and fills the reservation info
    app_user.User checks the reservation info is right
