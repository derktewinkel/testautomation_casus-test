*** Settings ***
Resource            ../Resources/common.robot
Force Tags          proxy_open

Suite Setup         Set Headers

*** Variables ***
${new_username}     newuser
${new_password}     password

${movie_name}       A Million Ways to Die in the West

*** Test Cases ***
Validate No Token
    [Tags]    token     token_open
    ${expected_status}  Set Variable            401
    ${response}         GET Method              ${expected_status}  /v1/proxy/tokens
    Should Contain      ${response.text}        Missing Authorization Header

Validate Against Admin Endpoint
    [Tags]    token     token_open
    ${expected_status}  Set Variable            401
    ${response}         GET Method              ${expected_status}  /v1/proxy/tokens/admin
    Should Contain      ${response.text}        Missing Authorization Header

Get All Movies
    [Tags]    movie     get_movies_open
    ${expected_status}  Set Variable            200

    ${response}         GET Method              ${expected_status}  /v1/proxy/movies
    Should Contain      ${response.text}        ${movie_name}

Create New User
    [Tags]    user      create_user_open
    ${expected_status}  Set Variable            200

    ${random}           Generate Random String  6   0123456789
    ${new_username}     Set Variable            ${new_username}_${random}
    Set Suite Variable  ${new_username}
    ${data}             Create Dictionary       password=${new_password}  username=${new_username}

    ${response}         POST Method             ${expected_status}  /v1/proxy/users     ${data}
    Should Contain      ${response.text}        "username":"${new_username}"

Create New User Error Case
    [Tags]    user      create_user_open
    ${expected_status}  Set Variable            400

    ${data}             Create Dictionary       password=${new_password}  username=${new_username}
    ${response}         POST Method             ${expected_status}  /v1/proxy/users     ${data}
    Should Contain      ${response.text}        ${new_username} already exists


