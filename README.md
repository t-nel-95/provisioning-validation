# Provisioning Validation Lab

This repository contains the necessary files and scripts to deploy a simple two-node network topology using **Containerlab**, build a custom Docker image for the nodes, establish secure SSH access via key exchange, and validate the setup using **Ansible**.

## Prerequisites

Ensure you have the following software installed and configured:

1. **Docker:** Required for running containerized network nodes.

2. **Containerlab (`clab`):** Required for deploying the network topology defined in `netval-topo.clab.yml`.

3. **Ansible:** Required for provisioning the nodes using `ansible-playbook`.

4. **OpenSSH Client Utilities:** Specifically, the `ssh-copy-id` utility must be available on your host system.

## Project Files

| **File** | **Description** | 
|---|---|
| `Dockerfile` | Defines the `ubuntu-ansible-node:latest` image, including Python, netaddr, SSH server, and setting the root password to 'ansible'. | 
| `netval-topo.clab.yml` | Containerlab topology definition creating two nodes: `core_sw` and `access_sw_1`. | 
| `inventory.yaml` | Ansible inventory defining the IP addresses and credentials for the lab nodes. | 
| `playbook.yaml` | The main Ansible playbook used to run configurations or tests on the lab nodes. | 
| `docker_build.sh` | Shell script to build the custom Docker image. | 
| `lab_up.sh` | Shell script to deploy the Containerlab topology. | 
| `setup_ssh.sh` | **CRITICAL:** Generates an SSH key pair (`id_rsa_netval`) and installs the public key on the remote nodes using `ssh-copy-id`. | 
| `ansible_run.sh` | Shell script to execute the main Ansible playbook. |
| `lab_down.sh` | Shell script to destroy the Containerlab topology and clean up resources. |

## Quick Start Workflow

Follow these steps sequentially to deploy the lab, set up SSH, and run the Ansible playbook.

Start by changing to the `provision` directory:

```bash
cd provision
```

### Step 1: Build the Custom Docker Image

This step creates the `ubuntu-ansible-node:latest` image required by the Containerlab topology.

```bash
./docker_build.sh
```

### Step 2: Deploy the Containerlab Topology

This step starts the two containers and creates the network link between them. This command requires `sudo`.

```bash
sudo ./lab_up.sh
```

### Step 3: Configure SSH Key-Based Access

This script generates a new, passwordless RSA key pair (`id_rsa_netval`) and uses `ssh-copy-id` to install the public key on both remote nodes.

**Note:** You will be prompted to enter the **remote user's password** (`ansible`) for each host on this first run.

```bash
./setup_ssh.sh
```

### Step 4: Run the Ansible Playbook

Once key access is set up, you can execute your provisioning logic defined in `playbook.yaml`.

```bash
./ansible_run.sh
```

## Cleanup

When you are finished with the lab, use the following command to stop and remove all containers and associated network bridges created by Containerlab. This command requires `sudo`.

```bash
sudo ./lab_down.sh
```