*** Settings ***
Documentation       A resource file with keywords.

Resource            ../PO/User/reservation_unit.robot
Resource            ../PO/User/reservation_unit.robot
Resource            variables.robot
Library             Browser


*** Keywords ***
Click element by role with text
    [Arguments]    ${Element}    ${Text}
    Log    ${Element}
    Log    ${Text}
    ${Click_element}=    Get Element By Role    ${Element}    name=${Text}
    Click    ${Click_element}

Check elements text
    [Arguments]    ${Element}    ${Expected text}
    Log    ${Element}
    Log    ${Expected text}
    ${Element text}=    Get Element By Role    ${Element}    name=${Expected text}
    Should Be Equal    ${Element text}    ${Expected text}

Get Finnish Formatted Date
    [Arguments]    ${TIME_OF_SECOND_FREE_SLOT}
    Log    ${TIME_OF_SECOND_FREE_SLOT}

    ${result}=    Evaluate JavaScript
    ...    ${None}
    ...    function() {
    ...    const currentDate = new Date();
    ...    currentDate.setHours(currentDate.getHours() + 3);
    ...    const daysInFinnish = ['Su', 'Ma', 'Ti', 'Ke', 'To', 'Pe', 'La'];
    ...    const finnishDay = daysInFinnish[currentDate.getDay()];
    ...    const day = currentDate.getDate();
    ...    const month = currentDate.getMonth() + 1;
    ...    const year = currentDate.getFullYear();
    ...    const finnishDate = day + "." + month + "." + year;
    ...    const [hour, minute] = arguments[0].split(':');
    ...    const hourInt = parseInt(hour, 10);
    ...    const formattedHour = hourInt.toString();
    ...    const endHour = (hourInt + 1) % 24;
    ...    const formattedDate = finnishDay + " " + day + "." + month + "." + year + " klo " + formattedHour + ":" + minute + "-" + endHour + ":" + minute + ", 1 t";
    ...    return {formattedDate: formattedDate, finnishDate: finnishDate};
    ...    }
    ...    arg=${TIME_OF_SECOND_FREE_SLOT}
    ${formattedDateFromResult}=    Set Variable    ${result}[formattedDate]
    Set Suite Variable    ${TIME_OF_QUICK_RESERVATION}    ${formattedDateFromResult}

    Log    ${TIME_OF_QUICK_RESERVATION}
    Log    ${result['finnishDate']}
