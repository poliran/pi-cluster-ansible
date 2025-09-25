#!/bin/bash

echo "Fixing remaining ansible-lint issues..."

# Fix FQCN issues - replace common module names with FQCN
find roles/ -name "*.yml" -exec sed -i '' 's/^  apt:/  ansible.builtin.apt:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  systemd:/  ansible.builtin.systemd:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  file:/  ansible.builtin.file:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  template:/  ansible.builtin.template:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  copy:/  ansible.builtin.copy:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  shell:/  ansible.builtin.shell:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  command:/  ansible.builtin.command:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  user:/  ansible.builtin.user:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  lineinfile:/  ansible.builtin.lineinfile:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  get_url:/  ansible.builtin.get_url:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  npm:/  community.general.npm:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  mysql_user:/  community.mysql.mysql_user:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^  mysql_db:/  community.mysql.mysql_db:/g' {} \;

# Fix indented FQCN issues
find roles/ -name "*.yml" -exec sed -i '' 's/^    apt:/    ansible.builtin.apt:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    systemd:/    ansible.builtin.systemd:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    file:/    ansible.builtin.file:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    template:/    ansible.builtin.template:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    copy:/    ansible.builtin.copy:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    shell:/    ansible.builtin.shell:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    command:/    ansible.builtin.command:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    user:/    ansible.builtin.user:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    lineinfile:/    ansible.builtin.lineinfile:/g' {} \;
find roles/ -name "*.yml" -exec sed -i '' 's/^    get_url:/    ansible.builtin.get_url:/g' {} \;

# Remove extra blank lines from meta files
find roles/*/meta/ -name "main.yml" -exec sed -i '' '/^$/N;/^\n$/d' {} \;

echo "FQCN and formatting fixes applied."
echo "Note: Variable naming issues need manual fixing in defaults/main.yml files"
echo "Run 'make lint' to check remaining issues."
