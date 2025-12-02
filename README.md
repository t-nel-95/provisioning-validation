# Provisioning Validation Lab

This repository contains the necessary files and scripts to deploy a simple two-node network topology using **Docker Compose**, build a custom Docker image for the nodes, establish secure SSH access, and validate the setup using **Robot Framework**.

## Prerequisites

Ensure you have the following software installed and configured:

1. **Docker:** Required for running containerized network nodes.
2. **Python & Robot Framework:** Required for running the validation tests. You can install the necessary libraries using the `requirements.txt` file in the `robot_tests` directory.
   ```bash
   pip install -r robot_tests/requirements.txt
   ```
3. **OpenSSH Client & Key Pair:**
   - The `ssh-copy-id` utility must be available on your host system.
   - You must have a pre-existing SSH key pair in your `~/.ssh/` directory (e.g., `id_ed25519` and `id_ed25519.pub`). The setup script is configured to use `id_ed25519` by default.

## Project Files

| **File** | **Description** | 
|---|---|
| `provision/Dockerfile` | Defines the `ubuntu-ansible-node:latest` image, including Python, SSH server, and setting the root password to 'ansible'. | 
| `provision/docker-compose.yml` | Defines the services, network, and port mappings for the lab environment. |
| `provision/docker_build.sh` | Shell script to build the custom Docker image. | 
| `provision/lab_up.sh` | Shell script to deploy the Docker Compose environment. | 
| `provision/setup_ssh.sh` | **CRITICAL:** Installs your existing public SSH key (`~/.ssh/id_ed25519.pub`) on the lab nodes using `ssh-copy-id`. | 
| `provision/lab_down.sh` | Shell script to destroy the Docker Compose environment and clean up resources. |
| `robot_tests/successful_ping_test.robot` | Robot Framework test suite to validate connectivity and configuration of the lab nodes. |
| `robot_tests/requirements.txt` | Lists the Python dependencies required for the Robot Framework tests (e.g., `robotframework-sshlibrary`). |

## Quick Start Workflow

Follow these steps sequentially to deploy the lab, set up SSH, and run the Ansible playbook.

### Step 1: Build the Custom Docker Image

This step creates the `ubuntu-ansible-node:latest` image required by the Containerlab topology.

```bash
cd provision
./docker_build.sh
cd ..
```

### Step 2: Deploy the Docker Compose

This step starts the two containers and creates the network link between them.

```bash
./lab_up.sh
```

### Step 3: Configure SSH Key-Based Access

This script adds your ssh key to the deployed containers. Note: you may need to change the path.

**Note:** You will be prompted to enter the **remote user's password** (`ansible`) for each host on this first run.

```bash
./setup_ssh.sh
```

### Step 4: Run the Ansible Playbook

Once key access is set up, you can execute your provisioning logic defined in `playbook.yaml`.

```bash
./ansible_run.sh
```

### Step 5: Run the Robot Framework test

You can now run the robot test, which has one host ping the other, using pingutils provisioned by the Ansible playbook.

First create a venv and install the dependencies:

```bash
cd ../robot_tests
python3 -m venv venv
. venv/bin/activate
pip install -r requirements.txt
```

You can now execute the test:

```bash
robot successful_ping_test.robot 
```

## Cleanup

When you are finished with the lab, use the following command to stop and remove all containers and associated network bridges created by Docker Compose.

```bash
cd ../provision
sudo ./lab_down.sh
```