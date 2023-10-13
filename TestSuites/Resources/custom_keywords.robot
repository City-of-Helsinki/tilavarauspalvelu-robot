*** Settings ***
Documentation       A resource file with keywords.

Resource            ../PO/User/quick_reservation.robot
Resource            ../PO/User/quick_reservation.robot
Resource            variables.robot
Resource            texts_FI.robot
Library             Browser


*** Keywords ***
Find and click element with text
    [Arguments]    ${element_with_text}    ${wanted_text}
    ${elements_with_text}=    Get Elements    ${element_with_text}
    FOR    ${element}    IN    @{elements_with_text}
        ${el_text}=    Get Text    ${element}
        Log    ${el_text}
        IF    "${el_text}" == "${wanted_text}"
            Click    ${element}
            Log    Element with text "${wanted_text}" clicked.
            BREAK
        END
    END

Normalize string
    [Arguments]    ${string}
    log    '${string}'
    ${normalize_string}=    Evaluate JavaScript
    ...    ${None}
    ...    function() {
    ...    return arguments[0].replace(/\xa0/g, ' ');
    ...    }
    ...    arg=${string}

    ${normalized_string}=    Set variable    ${normalize_string}
    Set Suite Variable    ${normalized_string}
    log    '${normalized_string}'

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
