#!/bin/bash
set -euo pipefail

echo "[INFO] Creating Ansible private vars file"

# Determine the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define the path to the private varss file (inventory is one folder above the script)
declare -A VAR_FILES
VAR_FILES["cluster"]="${SCRIPT_DIR}/../inventory/group_vars/cluster/private_vars.yml"
VAR_FILES["services"]="${SCRIPT_DIR}/../inventory/group_vars/services/private_vars.yml"
VAR_FILES["all"]="${SCRIPT_DIR}/../inventory/group_vars/all/private_vars.yml"

for key in "${!VAR_FILES[@]}"; do
  FILE="${VAR_FILES[$key]}"

  # Ensure the directory exists
  mkdir -p "$(dirname "${FILE}")"

  # Start with an empty file
  : > "${FILE}"

  VAR_USER="${key}_user"
  if [[ -n "${!VAR_USER:-}" ]]; then
    echo "ansible_user: \"${!VAR_USER}\"" >> "${FILE}"
  fi

  VAR_PASS="${key}_password"
  if [[ -n "${!VAR_PASS:-}" ]]; then
    echo "ansible_password: \"${!VAR_PASS}\"" >> "${FILE}"
  fi

  VAR_DOM="${key}_domain"
  if [[ -n "${!VAR_DOM:-}" ]]; then
    echo "domain: \"${!VAR_DOM}\"" >> "${FILE}"
  fi

  echo "[INFO] Private vars file created successfully at ${FILE}"
done