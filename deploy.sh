#!/bin/bash
set -e

echo "=== Pi Cluster Deployment ==="

# Run the main playbook
ansible-playbook -i inventories/production/hosts playbooks/site.yml

echo "=== Deployment completed ==="

# Run health checks
echo "=== Health Check ==="
for i in 101 102 103; do
    echo -n "Pi $i: "
    curl -s http://192.168.254.$i/health || echo "FAILED"
done