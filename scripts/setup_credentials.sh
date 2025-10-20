#!/bin/bash
set -euo pipefail

echo "[INFO] Creating Ansible credentials file"

# Start with an empty file
: > ./inventory/group_vars/cluster/credentials.yml

# Write ansible_user only if defined
if [[ -n "${CLUSTER_USER:-}" ]]; then
  echo "ansible_user: \"${CLUSTER_USER}\"" >> ./inventory/group_vars/cluster/credentials.yml
fi

# Write ansible_password only if defined
if [[ -n "${CLUSTER_PASSWORD:-}" ]]; then
  echo "ansible_password: \"${CLUSTER_PASSWORD}\"" >> ./inventory/group_vars/cluster/credentials.yml
fi

echo "[INFO] Credentials file created successfully"
cat ./inventory/group_vars/cluster/credentials.yml