# 🚀 Project: Ansible Network Validation & Provisioning Audit (NETVAL)

## Introduction

This project demonstrates expertise in **network provisioning, configuration management, and test automation** using **Ansible** and a **Docker-based** network emulation environment (Arista cEOS).

The core goal is to deploy a new VLAN configuration across simulated switches and then rigorously validate the operational state to ensure the network is configured exactly as intended.

---

## 🎯 Technical Showcase

This repository is built to demonstrate competence in the following areas crucial for a Test Automation Engineer:

* **Test-Driven Automation:** Clear separation of provisioning logic (`1_provision_vlan.yml`) from validation logic (`2_validate_vlan.yml`).
* **State Validation:** Using the **`ansible.builtin.assert`** module to check the *operational state* of the network, not just the configuration file.
* **Idempotency:** Using Ansible network modules to ensure configurations are only applied when necessary (`changed=0` on repeated runs).
* **Modular Design:** Utilizing Ansible **Roles** (`network_setup`) to create reusable and maintainable configuration and testing logic.
* **Environment as Code (EaC):** Utilizing **Docker Compose** to create a self-contained, repeatable, and portable virtual network topology.

---

## ⚙️ How to Run the Demo

### Prerequisites

To run this demo, you must have the following installed locally:

1.  **Docker & Docker Compose**
2.  **Python 3.x**
3.  **Ansible:** Installed via `pipx` (recommended) or `pip`.
4.  **Network Collection:** The Ansible collection for Arista EOS is required:
    ```bash
    ansible-galaxy collection install arista.eos
    ```

### Step 1: Start the Virtual Network

Navigate to the project root directory and start the two cEOS containers defined in `docker-compose.yml`.

```bash
docker compose up -d
```

Wait 30-60 seconds for the network operating systems (NOS) to boot and the SSH service to start.

### Step 2: Verify Initial Connectivity

Run a simple Ansible command to ensure the controller can connect to the Docker containers via the mapped ports (`2200` and `2201`).

```bash
ansible all -i inventory/hosts.yml -m arista.eos.eos_facts -a "gather_subset=hardware"
```

### Step 3: Provision the VLAN (The Action)

Run the provisioning playbook. By default, this creates VLAN 100 and assigns it to the access ports, using the parameters defined in `group_vars/all.yml`.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/1_provision_vlan.yml
```

### Step 4: Validate the Configuration (The Test)

Run the test automation playbook. This playbook executes network commands, gathers structured output, and uses assertions to verify the presence, correct naming, and port assignment of the new VLAN.

```bash
ansible-playbook -i inventory/hosts.yml playbooks/2_validate_vlan.yml
```

**Testing Idempotency**: If you run the provisioning playbook (Step 3) again, it should report changed=0 for all tasks, demonstrating that the network state was already correct.

### Step 5: Clean Up

When finished, shut down the network containers and remove the custom bridge network:

```bash
docker compose down
```

## 📂 Project Structure

```
netval/
├── docker-compose.yml              # Defines 2 cEOS switches and custom network topology.
├── .gitignore                      # Excludes Venvs, logs, and sensitive files.
├── inventory/
│   └── hosts.yml                   # Defines target hosts (127.0.0.1:22XX) and connection details.
├── group_vars/
│   └── all.yml                     # Centralizes all changeable parameters (vlan_id: 100, vlan_name, credentials).
├── playbooks/
│   ├── 1_provision_vlan.yml        # High-level playbook: Calls the 'network_setup/provision' role tasks.
│   └── 2_validate_vlan.yml         # High-level playbook: Calls the 'network_setup/validate' role tasks.
└── roles/
    └── network_setup/              # The core, reusable automation logic.
        ├── tasks/
        │   ├── provision.yml       # VLAN creation and interface config tasks (tagged: 'provision').
        │   └── validate.yml        # Fact gathering and ASSERTION tasks (tagged: 'validate').
        └── handlers/
            └── main.yml            # Task to save the running configuration.
```