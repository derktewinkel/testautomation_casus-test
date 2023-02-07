*** Settings ***
Library     ../Resources/pythonlib/GetBearerToken.py
            ...    endpoint=http://localhost:8080/v1/proxy/tokens/

Library     RequestsLibrary
Library     Collections
Library     String

Resource    ../Resources/keywords/token.robot
Resource    ../Resources/keywords/proxy_api.robot

Variables   ../Variables/variables.py

*** Keywords ***
Set Headers
    Set Suite Variable    &{headers}    Content-Type=application/json  accept=application/json