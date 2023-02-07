*** Settings ***
Resource            ../Resources/common.robot
Force Tags          proxy_user

Suite Setup         Set Headers

*** Variables ***
${username}         testuser
${password}         user

${new_username}     newuser
${new_password}     password

${new_admin_name}   newadmin
${new_admin_pass}   admin_pass

${movie_name}       A Million Ways to Die in the West
${new_movie_name}   New Movie Name User

*** Test Cases ***
Set User Token
    [Tags]    token     token_user  set_user_token
    Set Token           ${username}  ${password}

Validate User Token
    [Tags]    token     token_user  val_user_token
    ${expected_status}  Set Variable            200

    ${response}         GET Method              ${expected_status}  /v1/proxy/tokens
    Should Contain      ${response.text}        ${username} - you saw me!

Validate Against Admin Endpoint
    [Tags]    token     token_user  val_user_admin_token
    ${expected_status}  Set Variable            403

    ${response}         GET Method              ${expected_status}  /v1/proxy/tokens/admin
    Should Contain      ${response.text}        Forbidden for this user

Get All Movies
    [Tags]    movie     movie_user  all_movies_user
    ${expected_status}  Set Variable            200

    ${response}         Get Method              ${expected_status}  /v1/proxy/movies
    Should Contain      ${response.text}        ${movie_name}

Get Movie As Admin
    [Tags]    movie     movie_user  movie_as_admin_user
    ${expected_status}  Set Variable            403

    ${response}         Get Method              ${expected_status}  /v1/proxy/movies/admin
    Should Contain      ${response.text}        Forbidden for this user

Search Movie By Name
    [Tags]    movie     movie_user  search_movie_user
    ${expected_status}  Set Variable            200

    ${response}         GET Method              ${expected_status}   /v1/proxy/movies/searches  params=query=${movie_name}
    ${response_json}    Evaluate                json.loads(json.dumps(${response.json()[0]}))
    ${res_name}         Get From Dictionary     ${response_json}   title
    Should Be Equal     ${movie_name}           ${res_name}
    ${movie_id}         Get From Dictionary     ${response_json}   imdb
    Set Suite Variable  ${movie_id}

Search Movie By ID
    [Tags]    movie     movie_user  search_movie_user
    ${expected_status}  Set Variable            200

    ${response}         GET Method              ${expected_status}  /v1/proxy/movies/${movie_id}  params=query=${movie_id}
    ${response_json}    Evaluate                json.loads(json.dumps(${response.json()}))
    ${res_name}         Get From Dictionary     ${response_json}   title
    Should Be Equal     ${movie_name}           ${res_name}

Create New Movie
    [Tags]    movie     movie_user  create_movie_user
    ${expected_status}  Set Variable            403

    ${data}             Create Dictionary       imdb=${new_movie_name}  title=some title  type=movie  year=${2021}

    ${response}         POST Method             ${expected_status}   /v1/proxy/movies   ${data}
    Should Contain      ${response.text}        Forbidden for this user

Get All Users
    [Tags]    user      user_user  get_user_user
    ${expected_status}  Set Variable            200

    ${response}         Get Method              ${expected_status}  /v1/proxy/users
    Should Contain      ${response.text}        allUsers

Create New User
    [Tags]    user      user_user  create_user_user
    ${expected_status}  Set Variable    200

    ${random}           Generate Random String  6   0123456789
    ${new_username}     Set Variable            ${new_username}_${random}
    Set Suite Variable  ${new_username}
    ${data}             Create Dictionary       password=${new_password}  username=${new_username}

    ${response}         POST Method             ${expected_status}  /v1/proxy/users     ${data}
    Should Contain      ${response.text}        "username":"${new_username}"

Create New Admin
    [Tags]    user      user_user  create_amdin_user
    ${expected_status}  Set Variable    403

    ${random}           Generate Random String  6   0123456789
    ${new_admin_name}   Set Variable            ${new_admin_name}_${random}
    Set Suite Variable  ${new_admin_name}
    ${data}             Create Dictionary       password=${new_admin_pass}  username=${new_admin_name}

    ${response}         POST Method             ${expected_status}  /v1/proxy/users/admins     ${data}
    Should Contain      ${response.text}        Forbidden for this user

Update User
    [Tags]    user      user_user  update_user_user
    ${expected_status}  Set Variable    403

    ${data}             Create Dictionary       active=${False}
    ${user_id}          Get User Attribute      200     ${username}    id

    ${response}         PUT Method              ${expected_status}  /v1/proxy/users/${user_id}  ${data}
    Should Contain      ${response.text}        Forbidden for this user

Check User Attribute
    [Tags]    user      user_user  check_user_user
    Check User Attribute    ${username}  attribute_name=active  expected=${True}

Delete User
    [Tags]    user      user_user  delete_user_user
    ${expected_status}  Set Variable            403

    ${user_id}          Get User Attribute      200     ${username}    id

    ${response}         DELETE Method           ${expected_status}  /v1/proxy/users/${user_id}
    Should Contain      ${response.text}        Forbidden for this user


