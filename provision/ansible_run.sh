#!/bin/bash
# Use our new static inventory file.
ansible-playbook -i inventory.ini playbook.yaml