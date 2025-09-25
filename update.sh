#!/bin/bash
set -e

echo "=== Quick Application Update ==="

# Only update web application
ansible-playbook -i inventories/production/hosts playbooks/site.yml --tags "webapp"

echo "=== Update completed ==="