#!/bin/bash
set -euo pipefail

echo "[INFO] Creating Ansible private vars file"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

declare -A VAR_FILES
VAR_FILES["cluster"]="${SCRIPT_DIR}/../inventory/group_vars/cluster/private_vars.yml"
VAR_FILES["services"]="${SCRIPT_DIR}/../inventory/group_vars/services/private_vars.yml"
VAR_FILES["all"]="${SCRIPT_DIR}/../inventory/group_vars/all/private_vars.yml"
VAR_FILES["django-app"]="${SCRIPT_DIR}/../inventory/host_vars/django-app/private_vars.yml"

VAR_GROUPS=("cluster" "services" "all" "django-app")

for key in "${!VAR_FILES[@]}"; do
  FILE="${VAR_FILES[$key]}"
  mkdir -p "$(dirname "${FILE}")"
  : > "${FILE}"
  echo "[INFO] Initialized ${FILE}"
done

for VAR_NAME in  $(compgen -e); do
  for group in "${VAR_GROUPS[@]}"; do
    prefix="${group}_"
    if [[ "${VAR_NAME}" == "${prefix}"* ]]; then
      var_key="${VAR_NAME#"${prefix}"}"
      value="${!VAR_NAME}"

      if [[ -n "${value}" ]]; then
        FILE="${VAR_FILES[$group]}"
        echo "${var_key}: ${value}" >> "${FILE}"
        echo "[INFO] Wrote ${var_key} to ${FILE}"
      fi

    fi
  done
done

echo "[INFO] Private vars files updated successfully"