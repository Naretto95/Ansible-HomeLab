# Ansible Infrastructure Automation

This Ansible project provides automated setup and deployment of infrastructure components, including Proxmox clusters, Docker containers, GitLab CI/CD, WireGuard VPN, and various server configurations. It supports both local development environments and remote server provisioning.

## Features

- **Server Setup**: Automated configuration of servers with DNS, packages, power policies, and GPU management
- **Proxmox Integration**: Cluster creation, customizations, and LXC container management
- **Docker Ecosystem**: Container and image management with Docker Compose support
- **GitLab Deployment**: Complete GitLab setup with project creation and CI/CD pipelines
- **Networking**: WireGuard VPN configuration for secure connections
- **Monitoring & Management**: System monitoring, user management, and Terraform integration

## Prerequisites

- Ansible 2.9+
- SSH access to target hosts
- Python 3 on control and managed nodes
- Required Ansible collections (install via `ansible-galaxy collection install -r requirements.yml`)

## Quick Start

1. **Install dependencies**:
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

2. **Configure inventory**:
   Edit `inventory/hosts.ini` and `inventory/group_vars/` files to match your environment.

3. **Run playbooks**:
   - Local setup: `ansible-playbook playbooks/setup_local.yml`
   - Server setup: `ansible-playbook playbooks/setup_servers.yml`
   - Deploy services: `ansible-playbook playbooks/deploy_services.yml`

4. **Prepare private variables**:
   - Export private values using environment variables with prefixes: `cluster_`, `services_`, or `all_`
   - Run `./scripts/setup_vars.sh` to create or update `inventory/group_vars/<group>/private_vars.yml`

## Project Structure

```
├── playbooks/           # Main playbooks
├── roles/              # Ansible roles organized by category
│   ├── common/         # Common system roles (packages, DNS, role_guard)
│   ├── infrastructure/ # Infrastructure management roles
│   ├── local/          # Local development roles
│   └── services/       # Service deployment roles
├── inventory/          # Host inventories and variables
├── vars/               # Global variables
├── scripts/            # Utility scripts
├── ansible.cfg         # Ansible configuration
└── requirements.yml    # Required collections
```

## Key Playbooks

- `setup_local.yml`: Configures local environment with Docker containers and GitLab
- `setup_servers.yml`: Applies basic server configurations and Proxmox setup
- `deploy_services.yml`: Deploys services on configured clusters

## Roles Overview

### Common Roles
- `common/packages`: System package management
- `common/dns_setup`: DNS configuration
- `common/role_guard`: Pre-deployment checks
- `common/os_detect`: Operating system detection

### Local Roles
- `local/disable_motd`: Disable message of the day
- `local/docker_containers`: Docker container lifecycle
- `local/docker_images`: Docker image building
- `local/gitlab_setup`: GitLab installation and configuration

### Infrastructure Roles
- `infrastructure/gpu_manager`: GPU management
- `infrastructure/power_policy`: Power management policies
- `infrastructure/proxmox_cluster`: Proxmox cluster management
- `infrastructure/proxmox_customizations`: Proxmox customizations

### Services Roles
- `services/install_wireguard`: WireGuard VPN setup
- `services/lxc_containers`: LXC container management
- `services/terraform`: Terraform integration
- `services/user_management`: User management

## Configuration

Customize deployments through:
- `inventory/group_vars/`: Environment-specific variables
- `inventory/host_vars/`: Host-specific variables
- `vars/setup.yml`: Global setup variables
- `scripts/setup_vars.sh`: Generates private variable files from environment variables
- Role defaults in `roles/*/defaults/main.yml`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 💡 Pipeline Variables

| Variable Name               | Description |
|-----------------------------|-------------|
| `all_domain`                | The main domain used for all deployed services. |
| `deploy_services`           | Boolean flag (`true`/`false`) to control whether service deployment should run. |
| `services_ansible_user`     | Username for services authentication. |
| `services_ansible_password` | Password for services authentication. |
| `cluster_ansible_user`      | Username for cluster management (e.g., Kubernetes/Ansible). |
| `cluster_ansible_password`  | Password for cluster management. |
| `setup_infra`               | Boolean flag (`true`/`false`) to control whether infrastructure setup should run. |

> 🔒 **Note:** All passwords and sensitive credentials are stored securely in GitLab CI/CD as protected variables and are not stored in the repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.