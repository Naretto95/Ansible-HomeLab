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

## Project Structure

```
├── playbooks/           # Main playbooks
├── roles/              # Ansible roles for specific tasks
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

- `packages`: System package management
- `dns_setup`: DNS configuration
- `docker_containers`: Docker container lifecycle
- `docker_images`: Docker image building
- `gitlab_setup`: GitLab installation and configuration
- `proxmox_cluster`: Proxmox cluster management
- `wireguard`: VPN setup
- And more...

## Configuration

Customize deployments through:
- `inventory/group_vars/`: Environment-specific variables
- `inventory/host_vars/`: Host-specific variables
- `vars/setup.yml`: Global setup variables
- Role defaults in `roles/*/defaults/main.yml`

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.