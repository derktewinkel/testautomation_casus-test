*** Settings ***
Resource            ../Resources/common.robot
Force Tags          proxy_admin

Suite Setup         Set Headers

*** Variables ***
${username}         testadmin
${password}         admin

${new_username}     newuser
${new_password}     password

${new_admin_name}   newadmin
${new_admin_pass}   admin_pass

${movie_name}       A Million Ways to Die in the West
${new_movie_name}   New Movie Name Admin

*** Test Cases ***
Get Admin Token
    [Tags]    token     token_admin
    Set Token           ${username}  ${password}

Validate Admin Token
    [Tags]    token     token_admin
    ${expected_status}  Set Variable            200
    ${response}         GET Method              ${expected_status}  /v1/proxy/tokens
    Should Contain      ${response.text}        ${username} - you saw me!

Validate Against Admin Endpoint
    [Tags]    token     token_admin
    ${expected_status}  Set Variable            200
    ${response}         GET Method              ${expected_status}  /v1/proxy/tokens/admin
    Should Contain      ${response.text}        You are a super cool admin

Get All Movies
    [Tags]    movie     movie_admin  all_movies_user
    ${expected_status}  Set Variable            200
    ${response}         GET Method              ${expected_status}  /v1/proxy/movies
    Should Contain      ${response.text}        description

Get Movie As Admin
    [Tags]    movie     movie_admin  movie_as_admin_user
    ${expected_status}  Set Variable            200
    ${response}         GET Method              ${expected_status}  /v1/proxy/movies/admin
    Should Contain      ${response.text}        You are a super cool admin

Search Movie By Name
    [Tags]    movie     movie_admin  search_movie_admin
    ${expected_status}  Set Variable            200

    ${response}         GET Method              ${expected_status}   /v1/proxy/movies/searches  params=query=${movie_name}
    ${response_json}    Evaluate                json.loads(json.dumps(${response.json()[0]}))
    ${res_name}         Get From Dictionary     ${response_json}   title
    Should Be Equal     ${movie_name}           ${res_name}
    ${movie_id}         Get From Dictionary     ${response_json}   imdb
    Set Suite Variable  ${movie_id}

Search Movie By ID
    [Tags]    movie     movie_admin  search_movie_admin
    ${expected_status}  Set Variable            200
    ${response}         GET Method              ${expected_status}   /v1/proxy/movies/${movie_id}  params=query=${movie_id}

    ${response_json}    Evaluate                json.loads(json.dumps(${response.json()}))

    ${res_name}         Get From Dictionary     ${response_json}   title
    Should Be Equal     ${movie_name}           ${res_name}

Create New Movie
    [Tags]    movie     movie_admin  create_movie_admin
    ${expected_status}  Set Variable            201
    ${data}             Create Dictionary       imdb=${new_movie_name}  title=${new_movie_name}  type=movie  year=${2021}

    ${response}         POST Method             ${expected_status}   /v1/proxy/movies   ${data}
    Should Contain      ${response.text}        has been inserted

Search New Movie By Name
    [Tags]    movie     movie_admin  search_new_movie_admin
    ${expected_status}  Set Variable            200

    ${response}         GET Method              ${expected_status}   /v1/proxy/movies/searches  params=query=${new_movie_name}
    ${response_json}    Evaluate                json.loads(json.dumps(${response.json()[0]}))
    ${res_name}         Get From Dictionary     ${response_json}    title
    Should Be Equal     ${new_movie_name}       ${res_name}

Get All Users
    [Tags]    user      user_admin  get_user_admin
    ${expected_status}  Set Variable            200

    ${response}         GET Method              ${expected_status}  /v1/proxy/users
    Should Contain      ${response.text}        allUsers

Create New User
    [Tags]    user      user_admin  create_user_admin
    ${expected_status}  Set Variable            200

    ${random}           Generate Random String  6   0123456789
    ${new_username}     Set Variable            ${new_username}_${random}
    Set Suite Variable  ${new_username}

    ${data}             Create Dictionary       password=${new_password}  username=${new_username}

    ${response}         POST Method             ${expected_status}  /v1/proxy/users     ${data}
    Should Contain      ${response.text}        "username":"${new_username}"

Create New Admin
    [Tags]    user      user_user  create_amdin_user
    ${expected_status}  Set Variable    200

    ${random}           Generate Random String  6   0123456789
    ${new_admin_name}   Set Variable            ${new_admin_name}_${random}
    Set Suite Variable  ${new_admin_name}
    ${data}             Create Dictionary       password=${new_admin_pass}  username=${new_admin_name}

    ${response}         POST Method             ${expected_status}  /v1/proxy/users/admins     ${data}
    Should Contain      ${response.text}        "username":"${new_admin_name}"

Update User
    [Tags]    user      user_admin  update_user_admin
    ${expected_status}  Set Variable            204

    ${data}             Create Dictionary       active=${False}
    ${user_id}          Get User Attribute      200     ${username}    id

    ${response}         PUT Method              ${expected_status}  /v1/proxy/users/${user_id}  ${data}
    Should Contain      ${response.text}        User was updated

Check User Attribute
    [Tags]    user      user_admin  check_user_admin
    Check User Attribute    ${username}  attribute_name=active  expected=${False}

Delete User
    [Tags]    user      user_admin  delete_user_admin
    ${expected_status}  Set Variable            200
    ${user_id}          Get User Attribute      200     ${username}    id

    ${response}         DELETE Method           ${expected_status}  /v1/proxy/users/${user_id}
    Should Contain      ${response.text}        User successfully accessed the content.
