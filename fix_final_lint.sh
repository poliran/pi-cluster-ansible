#!/bin/bash

# Fix file permissions by adding mode parameter
find roles/ -name "*.yml" -exec sed -i '' '/ansible.builtin.template:/,/^[[:space:]]*[^[:space:]]/ { /mode:/! { /ansible.builtin.template:/a\
    mode: "0644"
} }' {} \;

# Fix partial-become issues by adding become: true where become_user exists
find roles/ -name "*.yml" -exec sed -i '' '/become_user:/i\
  become: true' {} \;

# Fix no-changed-when for shell/command tasks in handlers and tasks
find roles/ -name "*.yml" -exec sed -i '' '/ansible.builtin.shell:/,/^[[:space:]]*[^[:space:]]/ { /changed_when:/! { /ansible.builtin.shell:/a\
  changed_when: true
} }' {} \;

echo "Final lint fixes applied."
