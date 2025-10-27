#!/usr/bin/env bash
set -euo pipefail
chmod -R o-w "$(dirname "$0")"

# --- Variables ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAYBOOK="${SCRIPT_DIR}/../playbooks/setup_local.yml"
INVENTORY="${SCRIPT_DIR}/../inventory/hosts.ini"
REQUIREMENTS_FILE="${SCRIPT_DIR}/../requirements.yml"

# --- Detect OS & Install Ansible ---
echo "[INFO] Detecting operating system..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_ID=$ID
else
    echo "[ERROR] Cannot detect OS. Aborting."
    exit 1
fi

echo "[INFO] Installing Ansible on $OS_ID..."

case "$OS_ID" in
    ubuntu)
        sudo apt-get update -y
        sudo apt-get install -y software-properties-common curl git python3 python3-pip
        sudo add-apt-repository --yes --update ppa:ansible/ansible
        sudo apt-get install -y ansible
        ;;
    debian)
        sudo apt-get update -y
        sudo apt-get install -y software-properties-common curl git python3 python3-pip
        sudo apt-get install -y ansible
        ;;
    centos|rhel|rocky|almalinux)
        sudo yum install -y epel-release
        sudo yum install -y ansible python3 git
        ;;
    *)
        echo "[ERROR] Unsupported OS: $OS_ID. Please install Ansible manually."
        exit 1
        ;;
esac

# --- Verify installation ---
if ! command -v ansible >/dev/null 2>&1; then
    echo "[ERROR] Ansible installation failed."
    exit 1
fi

echo "[INFO] Ansible installed successfully: $(ansible --version | head -n1)"

# --- Install Ansible Collections (requirements.yml) ---
if [ -f "$REQUIREMENTS_FILE" ]; then
    echo "[INFO] Installing Ansible collections from requirements.yml..."
    ansible-galaxy collection install -r "$REQUIREMENTS_FILE" --force
else
    echo "[WARN] No requirements.yml found at $REQUIREMENTS_FILE. Skipping."
fi

# --- Run Playbook ---
if [ -f "$PLAYBOOK" ]; then
    echo "[INFO] Running playbook: $PLAYBOOK"
    ansible-playbook -i "$INVENTORY" "$PLAYBOOK"
else
    echo "[ERROR] Playbook $PLAYBOOK not found."
    exit 1
fi
