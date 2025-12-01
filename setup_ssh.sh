#!/bin/bash

# --- Configuration ---
KEY_FILE="id_rsa_netval"
PUBLIC_KEY_FILE="${KEY_FILE}.pub"
INVENTORY_FILE="inventory.yaml"

# Check for ssh-copy-id availability
if ! command -v ssh-copy-id &> /dev/null
then
    echo "ERROR: ssh-copy-id could not be found. Please install it (e.g., sudo apt install openssh-client)."
    exit 1
fi

# 1. Generate an RSA SSH key without a passphrase
echo "--- 1. Generating RSA SSH key pair: ${KEY_FILE} and ${PUBLIC_KEY_FILE} ---"

# -t rsa: Key type is RSA
# -b 4096: Key size is 4096 bits (recommended)
# -N "": No passphrase (empty string)
# -f ${KEY_FILE}: Output filename
# -q: Quiet mode (suppress progress bar)
# -m PEM: Force PEM format for maximum compatibility
ssh-keygen -t rsa -b 4096 -N "" -f "${KEY_FILE}" -q -m PEM

if [ $? -ne 0 ]; then
    echo "ERROR: Failed to generate SSH key. Exiting."
    exit 1
fi

echo "Key generation complete. Key files are: ${KEY_FILE} and ${PUBLIC_KEY_FILE}"
echo ""

# 2. Key content is no longer needed as ssh-copy-id reads the file directly.

# 3. Start SSH Agent
echo "--- 3. Starting SSH agent ---"

# Check if SSH_AUTH_SOCK is set (i.e., agent is running or connected)
if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "Starting ssh-agent..."
    # 'eval' captures the environment variables (SSH_AUTH_SOCK and SSH_AGENT_PID)
    eval "$(ssh-agent -s)"
else
    echo "SSH agent is already running."
fi
echo ""

# 4. Add the generated private key to the ssh-agent
echo "--- 4. Adding private key (${KEY_FILE}) to ssh-agent ---"
# Since the key has no password, it will be added immediately.
ssh-add "${KEY_FILE}" > /dev/null 2>&1

if [ $? -ne 0 ]; then
    echo "WARNING: Failed to add private key to ssh-agent."
else
    echo "Private key added to agent successfully."
fi
echo ""

# 5. Use ssh-copy-id to install the public key on the remote hosts
echo "--- 5. Installing public key using ssh-copy-id on remote hosts ---"
echo "NOTE: You will be prompted for the remote 'root' user's password for each host."

# --- Parsing Inventory ---
# Extracts the remote user from the inventory file
REMOTE_USER=$(grep 'ansible_user:' "${INVENTORY_FILE}" | awk '{print $2}')
# Extracts the host IPs from the inventory file
HOST_IPS=$(grep 'ansible_host:' "${INVENTORY_FILE}" | awk '{print $2}')

if [ -z "$REMOTE_USER" ]; then
    echo "ERROR: Could not find 'ansible_user' in ${INVENTORY_FILE}. Please check the file format."
    exit 1
fi

echo "Remote User detected: ${REMOTE_USER}"

KEY_INSTALL_SUCCESS=0
for HOST_IP in $HOST_IPS; do
    echo "Attempting to install key on ${REMOTE_USER}@${HOST_IP}..."

    # ssh-copy-id handles:
    # 1. Reading the key content (-i flag specifies our custom key file).
    # 2. Connecting to the host (it will prompt for the password).
    # 3. Creating .ssh/ if necessary.
    # 4. Appending the key to authorized_keys (checking for duplicates).
    # 5. Setting correct permissions.

    # We use StrictHostKeyChecking=no and UserKnownHostsFile=/dev/null to handle
    # first-time connections without a manual prompt.
    ssh-copy-id -i "${PUBLIC_KEY_FILE}" \
        -o StrictHostKeyChecking=no \
        -o UserKnownHostsFile=/dev/null \
        "${REMOTE_USER}@${HOST_IP}"

    if [ $? -eq 0 ]; then
        echo "Successfully installed key on ${HOST_IP}."
        KEY_INSTALL_SUCCESS=$((KEY_INSTALL_SUCCESS + 1))
    else
        echo "WARNING: Failed to install key on ${HOST_IP}. Check password and connectivity."
    fi
done
echo ""

if [ "$KEY_INSTALL_SUCCESS" -gt 0 ]; then
    echo "--- Public key successfully installed on ${KEY_INSTALL_SUCCESS} hosts. ---"
    echo "Future connections will use the new key."
    echo ""
    echo "You can now test SSH access using:"
    echo "ssh -i ${KEY_FILE} ${REMOTE_USER}@172.20.20.2"
else
    echo "--- Key installation failed for all hosts. Please check connectivity and credentials. ---"
fi


# 6. Set restrictive permissions on the private key
# This is a security best practice for private keys.
chmod 600 "${KEY_FILE}"
echo "Permissions set to 600 for the private key: ${KEY_FILE}"