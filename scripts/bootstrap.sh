#!/bin/bash
set -e

echo "=== AHR Bootstrap ==="
cd "$(dirname "$0")/.."
echo "Installing Ansible dependencies..."
ansible-galaxy collection install -r ansible/requirements.yml

# --- Kopia SFTP & server credentials ---
# Priority: env vars > prompt > empty (skip restore)
EXTRA_VARS=""

if [ -n "$KOPIA_REPO_PASSWORD" ]; then
    EXTRA_VARS="$EXTRA_VARS kopia_repo_password=$KOPIA_REPO_PASSWORD"
else
    read -sp "Enter Kopia SFTP repository password (or press Enter to skip restore): " KOPIA_REPO_PASS_PROMPT
    echo ""
    if [ -n "$KOPIA_REPO_PASS_PROMPT" ]; then
        EXTRA_VARS="$EXTRA_VARS kopia_repo_password=$KOPIA_REPO_PASS_PROMPT"
    fi
fi

if [ -n "$KOPIA_SERVER_PASS" ]; then
    EXTRA_VARS="$EXTRA_VARS kopia_server_pass=$KOPIA_SERVER_PASS"
else
    read -sp "Enter Kopia server UI password (or press Enter to skip): " KOPIA_SRV_PASS_PROMPT
    echo ""
    if [ -n "$KOPIA_SRV_PASS_PROMPT" ]; then
        EXTRA_VARS="$EXTRA_VARS kopia_server_pass=$KOPIA_SRV_PASS_PROMPT"
    fi
fi

if [ -n "$KOPIA_RESTORE_DIR" ]; then
    EXTRA_VARS="$EXTRA_VARS kopia_restore_dir=$KOPIA_RESTORE_DIR"
else
    read -rp "Restore from Kopia? Enter restore path (or press Enter for fresh install): " KOPIA_RESTORE_PROMPT
    echo ""
    if [ -n "$KOPIA_RESTORE_PROMPT" ]; then
        EXTRA_VARS="$EXTRA_VARS kopia_restore_dir=$KOPIA_RESTORE_PROMPT"
    fi
fi

echo ""
echo "Running restore playbook..."
# shellcheck disable=SC2086
ansible-playbook ansible/playbooks/restore.yml $EXTRA_VARS "$@"
echo ""
echo "=== Bootstrap Complete ==="
