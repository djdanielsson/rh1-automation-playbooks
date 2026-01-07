#!/bin/bash

# validate-playbooks.sh
# Validate all playbooks for syntax and basic structure

set -e

echo "🔍 Validating playbooks..."

# Check if ansible-playbook is available
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ ansible-playbook not found. Please install Ansible."
    exit 1
fi

# Validate each playbook
for playbook in playbooks/*.yml; do
    echo "📋 Checking $playbook..."
    ansible-playbook --syntax-check "$playbook"
    echo "✅ $playbook syntax OK"
done

echo "🎉 All playbooks validated successfully!"
