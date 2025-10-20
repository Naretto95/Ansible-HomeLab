#!/bin/bash
set -euo pipefail

echo "[INFO] Creating Ansible credentials file"

# Start with an empty file
: > ./inventory/group_vars/cluster/credentials.yml

# Write ansible_user only if defined
if [[ -n "${cluster_user:-}" ]]; then
  echo "ansible_user: \"${cluster_user}\"" >> ./inventory/group_vars/cluster/credentials.yml
fi

# Write ansible_password only if defined
if [[ -n "${cluster_password:-}" ]]; then
  echo "ansible_password: \"${cluster_password}\"" >> ./inventory/group_vars/cluster/credentials.yml
fi

echo "[INFO] Credentials file created successfully"