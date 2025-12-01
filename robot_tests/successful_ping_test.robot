*** Settings ***
Documentation    Test to verify that the access switch can successfully ping the core switch.
Library          SSHLibrary

*** Variables ***
# Credentials for the access switch container (clab-netval-topo-access_sw_1)
${ACCESS_SW_HOST}      clab-netval-topo-access_sw_1
${SSH_USERNAME}        root
${SSH_PASSWORD}        ansible
${SSH_PORT}            22

# Target to be pinged (the core switch)
${CORE_SW_TARGET}      clab-netval-topo-core_sw

*** Test Cases ***
Access Switch Pings Core Switch Successfully
    [Documentation]    Log in to the access switch and ping the core switch by hostname.
    [Tags]             Ping    Connectivity

    ## 1. Connect to the Access Switch ##
    Open Connection    ${ACCESS_SW_HOST}    port=${SSH_PORT}
    Login    ${SSH_USERNAME}    ${SSH_PASSWORD}

    ## 2. Execute Ping Command ##
    # We will run a ping with a limited count (e.g., 3 packets)
    ${PING_CMD}=    Set Variable    ping -c 3 ${CORE_SW_TARGET}
    Log    Running command: ${PING_CMD}

    # Execute the command and capture the output and return code
    ${OUTPUT}    ${RC}=    Execute Command    ${PING_CMD}    return_stdout=True    return_rc=True

    ## 3. Verify the Result ##
    
    # Check if the return code is 0, which indicates command success
    Should Be Equal As Integers    ${RC}    0    msg=Ping command failed. Return code was ${RC}.
    
    # Check if the output contains the string "0% packet loss"
    Should Contain    ${OUTPUT}    0% packet loss    msg=Ping output did not show 0% packet loss. Full output: ${OUTPUT}

    ## 4. Disconnect ##
    Close Connection