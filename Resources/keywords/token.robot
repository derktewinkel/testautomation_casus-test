*** Settings ***
Resource   ../Resources/common.robot

*** Keywords ***
Set Token
    [Arguments]    ${username}  ${password}

    ${user_id}              Get User Attribute      200     ${username}      id
    ${response}  ${token}   Get Bearer Token        ${headers}  ${user_id}  ${username}  ${password}
    Should Be Equal As Integers         ${response.status_code}     200   msg=${response.text}

    Set To Dictionary       ${headers}  Authorization=Bearer ${token}
    Set Suite Variable      ${headers}