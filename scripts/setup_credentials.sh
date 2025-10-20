#!/bin/bash
set -euo pipefail

echo "[INFO] Creating Ansible credentials file"

mkdir -p ./inventory/group_vars/cluster

: > ./inventory/group_vars/cluster/credentials.yml

if [[ -n "${CLUSTER_USER:-}" ]]; then
  echo "ansible_user: \"${CLUSTER_USER}\"" >> ./inventory/group_vars/cluster/credentials.yml
else
  echo "[WARNING] CLUSTER_USER is not set"
fi

if [[ -n "${CLUSTER_PASSWORD:-}" ]]; then
  echo "ansible_password: \"${CLUSTER_PASSWORD}\"" >> ./inventory/group_vars/cluster/credentials.yml
else
  echo "[WARNING] CLUSTER_PASSWORD is not set"
fi

echo "[INFO] Contents of credentials.yml:"
cat ./inventory/group_vars/cluster/credentials.yml