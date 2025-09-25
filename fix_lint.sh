#!/bin/bash

# Fix common ansible-lint issues

echo "Fixing common linting issues..."

# Add newlines to files that need them
find roles/ -name "*.yml" -exec sh -c 'if [ "$(tail -c1 "$1")" != "" ]; then echo "" >> "$1"; fi' _ {} \;
find playbooks/ -name "*.yml" -exec sh -c 'if [ "$(tail -c1 "$1")" != "" ]; then echo "" >> "$1"; fi' _ {} \;

# Fix yes/no to true/false in YAML files
find . -name "*.yml" -exec sed -i '' 's/: yes$/: true/g' {} \;
find . -name "*.yml" -exec sed -i '' 's/: no$/: false/g' {} \;

echo "Basic fixes applied. Run 'make lint' to see remaining issues."
