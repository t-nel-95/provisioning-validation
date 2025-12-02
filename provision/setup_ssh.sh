#!/bin/bash

echo "--- Installing public SSH key on lab nodes using ssh-copy-id ---"
echo "You will be prompted for the 'root' password, which is 'ansible'."
echo ""

# Unset HOSTS to prevent errors if the script is sourced multiple times
unset HOSTS

# Define the hosts and their SSH ports from docker-compose.yml
declare -A HOSTS
HOSTS["core_sw"]="2222"
HOSTS["access_sw_1"]="2223"

USER="root"
IP="127.0.0.1"

for NAME in "${!HOSTS[@]}"; do
    PORT=${HOSTS[$NAME]}
    echo "--- Installing key on ${NAME} (${USER}@${IP}:${PORT}) ---"
    # ssh-copy-id will use your default public key (~/.ssh/id_ed25519.pub)
    # It will prompt for the password 'ansible'
    ssh-copy-id -p "${PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "${USER}@${IP}"

    if [ $? -eq 0 ]; then
        echo "Successfully installed key on ${NAME}."
    else
        echo "WARNING: Failed to install key on ${NAME}."
    fi
done

echo "--- Key installation complete. ---"
