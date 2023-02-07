*** Settings ***
Library         DataDriver   file=../../Resources/DataDriverCSV/post_tests.csv    handle_template_tags=DefaultTags
Resource        ../Resources/common.robot

Test Template   Token Tests Template
Test Setup      Set Headers

*** Test Cases ***
Run Token Tests
    [Tags]      post_tests_dd

*** Keywords ***
Token Tests Template
    [Arguments]         ${username}
    ...                 ${password}
    ...                 ${expected_status}
    ...                 ${expected_message}
    ...                 ${endpoint}
    ...                 ${data}

    IF  '${username}' != '' or '${password}' != ''
        Set Token               ${username}  ${password}
    END
    POST Method DataDriver   ${expected_status}    ${expected_message}   ${endpoint}     ${data}


POST Method DataDriver
    [Arguments]         ${expected_status}    ${expected_message}   ${endpoint}     ${data}
    ${data}             Set Data To Dictionary  ${data}
    ${response}         POST Method             ${expected_status}  ${endpoint}     data=${data}
    Should Contain      ${response.text}        ${expected_message}

Set Data To Dictionary
    [Arguments]         ${data}
    ${item_list}        Split String    ${data}  ,
    ${dict}             Create Dictionary

    FOR  ${key_value}  IN  @{item_list}
        ${key_value}    Split String    ${key_value}   =
        Set To Dictionary    ${dict}    ${key_value}[0]  ${key_value}[1]
    END
    [Return]    ${dict}
