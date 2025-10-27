#!/bin/bash
set -euo pipefail

echo "[INFO] Creating Ansible credentials file"

# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the path to the credentials file (inventory is one folder above the script)
declare -A CREDENTIAL_FILES
CREDENTIAL_FILES["cluster"]="${SCRIPT_DIR}/../inventory/group_vars/cluster/credentials.yml"
CREDENTIAL_FILES["services"]="${SCRIPT_DIR}/../inventory/group_vars/services/credentials.yml"

for key in "${!CREDENTIAL_FILES[@]}"; do
  FILE="${CREDENTIAL_FILES[$key]}"

  # Ensure the directory exists
  mkdir -p "$(dirname "${FILE}")"

  # Start with an empty file
  : > "${FILE}"

  # Write ansible_user only if defined
  VAR_USER="${key}_user"
  if [[ -n "${!VAR_USER:-}" ]]; then
    echo "ansible_user: \"${!VAR_USER}\"" >> "${FILE}"
  fi

  # Write ansible_password only if defined
  VAR_PASS="${key}_password"
  if [[ -n "${!VAR_PASS:-}" ]]; then
    echo "ansible_password: \"${!VAR_PASS}\"" >> "${FILE}"
  fi

  echo "[INFO] Credentials file created successfully at ${FILE}"
done