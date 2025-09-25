# Pi Cluster Ansible

Ansible automation for Raspberry Pi cluster deployment and management.

## Architecture

- **Load Balancer**: nginx reverse proxy
- **Web Servers**: Node.js applications (3 nodes)
- **Database Server**: Database backend

## Prerequisites

- Ansible 2.9+
- SSH access to all Pi nodes
- Python 3 on target hosts

## Quick Start

1. Install dependencies:
   ```bash
   ansible-galaxy install -r requirements.yml
   ```

2. Update inventory with your Pi IP addresses:
   ```bash
   vi inventories/production/hosts
   ```

3. Deploy the cluster:
   ```bash
   ./deploy.sh
   ```

## Inventory Structure

```
inventories/
└── production/
    └── hosts          # Production inventory
```

## Roles

- `common`: Base system configuration
- `database`: Database server setup
- `nodejs`: Node.js runtime installation
- `webapp`: Web application deployment
- `nginx`: Load balancer configuration

## Usage

Deploy all services:
```bash
ansible-playbook playbooks/site.yml
```

Deploy specific role:
```bash
ansible-playbook playbooks/site.yml --tags database
```

Update system packages:
```bash
./update.sh
```

## Configuration

Edit variables in:
- `group_vars/all.yml` - Global settings
- `group_vars/[group].yml` - Group-specific settings
- `host_vars/[host].yml` - Host-specific settings
