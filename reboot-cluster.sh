#!/bin/bash

# Reboot Pi Cluster - Proper reboot sequence
# Usage: ./reboot-cluster.sh

echo "Rebooting Pi Cluster..."

# Reboot web servers first
echo "Rebooting web servers..."
ansible web_servers -i inventories/production/hosts -m shell -a "sudo reboot" -b

# Wait for web servers to reboot
sleep 15

# Reboot database server
echo "Rebooting database server..."
ansible database_servers -i inventories/production/hosts -m shell -a "sudo reboot" -b

# Wait for database to reboot
sleep 15

# Reboot load balancer last
echo "Rebooting load balancer..."
ansible load_balancers -i inventories/production/hosts -m shell -a "sudo reboot" -b

echo "Cluster reboot initiated. All nodes should be restarting."
