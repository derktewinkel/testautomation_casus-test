*** Settings ***
Library         DataDriver   file=../../Resources/DataDriverCSV/get_tests.csv   handle_template_tags=DefaultTags
Resource        ../Resources/common.robot

Test Template   Token Tests Template
Test Setup      Set Headers

*** Variables ***
${host}         http://localhost:8080

*** Test Cases ***
Run Token Tests
    [Tags]      get_tests_dd

*** Keywords ***
Token Tests Template
    [Arguments]         ${username}
    ...                 ${password}
    ...                 ${expected_status}
    ...                 ${expected_message}
    ...                 ${endpoint}
    ...                 ${params}

    IF  '${username}' != '' and '${password}' != ''
        Set Token               ${username}  ${password}
    END
    Get Method DataDriver   ${expected_status}    ${expected_message}   ${endpoint}     ${params}


Get Method DataDriver
    [Arguments]         ${expected_status}    ${expected_message}   ${endpoint}     ${params}
    ${response}         GET Method              ${expected_status}  ${endpoint}     params=${params}
    Should Contain      ${response.text}        ${expected_message}


