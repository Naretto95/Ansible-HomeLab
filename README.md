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

## 💡 Pipeline Environment Variables

The pipeline reads deployment variables from an external `ENV_FILE` provided at runtime.

Each variable is automatically extracted and written into the appropriate Ansible `private_vars.yml` file based on its prefix:

| Prefix | Target Ansible Variables File |
|--------|-------------------------------|
| `all_` | `inventory/group_vars/all/private_vars.yml` |
| `cluster_` | `inventory/group_vars/cluster/private_vars.yml` |
| `services_` | `inventory/group_vars/services/private_vars.yml` |
| `django-app_` | `inventory/host_vars/django-app/private_vars.yml` |

### Example `ENV_FILE`

```env
all_lan_prefix=143.8 (first 2 digits)
all_domain=example.com

services_ansible_user=service
services_ansible_password=<secret>
services_github_token=<secret>

cluster_ansible_user=cluster
cluster_ansible_password=<secret>

django-app_django_secret_key=<secret>
django-app_django_api_key=<secret>
django-app_django_email_password=<secret>
django-app_django_email=<email>

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.