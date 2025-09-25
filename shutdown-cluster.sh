#!/bin/bash

# Shutdown Pi Cluster - Proper shutdown sequence
# Usage: ./shutdown-cluster.sh

echo "Shutting down Pi Cluster..."

# Shutdown web servers first
echo "Shutting down web servers..."
ansible web_servers -i inventories/production/hosts -m shell -a "sudo shutdown -h now" -b

# Wait for web servers to shutdown
sleep 10

# Shutdown database server
echo "Shutting down database server..."
ansible database_servers -i inventories/production/hosts -m shell -a "sudo shutdown -h now" -b

# Wait for database to shutdown
sleep 10

# Shutdown load balancer last
echo "Shutting down load balancer..."
ansible load_balancers -i inventories/production/hosts -m shell -a "sudo shutdown -h now" -b

echo "Cluster shutdown initiated. All nodes should be powering down."
