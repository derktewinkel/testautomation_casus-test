*** Settings ***
Library         OperatingSystem
Library         String

Suite Setup     Run INIT

*** Keywords ***
Run INIT
    [Documentation]         This __init__ file is run before other initilizations so the variables can be used while
    ...                     importing libraries and such.

    ${project_dir}          ${x}    Split Path      ${CURDIR}
    Set Global Variable     ${project_dir}

    Import Variables        ${project_dir}/Variables/variables.py
    Set Global Variable     ${host}

