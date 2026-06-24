#!/bin/bash
set -e
echo "=== AHR Bootstrap ==="
cd "$(dirname "$0")/.."
echo "Installing Ansible dependencies..."
ansible-galaxy collection install -r ansible/requirements.yml
echo "Running restore playbook..."
ansible-playbook ansible/playbooks/restore.yml "$@"
echo "=== Bootstrap Complete ==="
