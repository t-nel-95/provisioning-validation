*** Settings ***
Documentation    Test to verify that the access switch can successfully ping the core switch.
Library          SSHLibrary

*** Variables ***
# Credentials for the access switch container
${ACCESS_SW_HOST}      127.0.0.1
${SSH_USERNAME}        root  # The user is still 'root'
${SSH_PORT}            2223

# Target to be pinged
${CORE_SW_TARGET}      core_sw

# Path to the private key for SSH authentication
${SSH_KEY_PATH}        %{HOME}/.ssh/id_ed25519
${SSH_PASSWORD}        ansible

*** Test Cases ***
Access Switch Pings Core Switch Successfully
    [Documentation]    Log in to the access switch and ping the core switch by hostname.
    [Tags]             Ping    Connectivity

    ## 1. Connect to the Access Switch ##
    Open Connection    ${ACCESS_SW_HOST}    port=${SSH_PORT}
    # Use password authentication as a diagnostic step.
    # Login    ${SSH_USERNAME}    ${SSH_PASSWORD}
    Login With Public Key    ${SSH_USERNAME}    ${SSH_KEY_PATH}

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