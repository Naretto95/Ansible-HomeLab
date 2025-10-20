#!/bin/bash
set -euo pipefail

echo "[INFO] Creating Ansible credentials file"

cat > ./inventory/group_vars/cluster/credentials.yml <<EOF
ansible_user: "${CLUSTER_USER}"
ansible_password: "${CLUSTER_PASSWORD}"
EOF

echo "[INFO] Credentials file created successfully"