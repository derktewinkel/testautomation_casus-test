*** Keywords ***
GET Method
    [Arguments]     ${expected_status}  ${endpoint}  ${params}=''
    ${response}     GET         ${host}${endpoint}
    ...                             headers=${headers}  expected_status=${expected_status}  params=${params}
    [Return]        ${response}

POST Method
    [Arguments]     ${expected_status}  ${endpoint}  ${data}
    ${response}     POST        ${host}${endpoint}
        ...                         headers=${headers}  expected_status=${expected_status}  json=${data}
    [Return]        ${response}

PUT Method
    [Arguments]     ${expected_status}  ${endpoint}  ${data}
    ${response}     PUT        ${host}${endpoint}
    ...                             headers=${headers}  expected_status=${expected_status}  json=${data}
    [Return]        ${response}

DELETE Method
    [Arguments]     ${expected_status}  ${endpoint}
    ${response}     DELETE      ${host}${endpoint}
    ...                             headers=${headers}  expected_status=${expected_status}
    [Return]        ${response}

Check User Attribute
    [Arguments]     ${username}  ${attribute_name}  ${expected}
    ${value}            Get User Attribute    200   ${username}   ${attribute_name}
    Should Be Equal     ${value}  ${expected}
    ...                     msg=The attribute '${attribute_name}' was not '${expected}' as expected but '${value}'

Get User Attribute
    [Arguments]    ${expected_status}  ${username}  ${attribute_name}
    ${response}     GET         ${host}/v1/proxy/users/${username}
    ...                             headers=${headers}  expected_status=${expected_status}
    ${attribute}    Get From Dictionary  ${response.json()}       ${attribute_name}
    [Return]        ${attribute}

