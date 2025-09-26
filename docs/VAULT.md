# Ansible Vault Usage

## Overview
Sensitive data like passwords are encrypted using Ansible Vault in `group_vars/all/vault.yml`.

## Usage

### Deploy with vault
```bash
make deploy
# Or manually:
ansible-playbook playbooks/site.yml --ask-vault-pass
```

### Edit vault file
```bash
ansible-vault edit group_vars/all/vault.yml
```

### View vault contents
```bash
ansible-vault view group_vars/all/vault.yml
```

### Change vault password
```bash
ansible-vault rekey group_vars/all/vault.yml
```

## Variables
- `vault_db_password`: Database user password
- `vault_mysql_root_password`: MySQL root password
