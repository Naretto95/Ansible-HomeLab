# Ansible HomeLab

Ansible automation for a self-hosted homelab: Proxmox cluster bootstrap, LXC/VM provisioning, a self-hosted GitLab instance with CI/CD, WireGuard VPN, and a full Django app deployment (PostgreSQL, gunicorn, nginx, Let's Encrypt).

## Overview

This repo drives a small Proxmox cluster end to end:

- **Cluster nodes** (`server1`, `server2`) are bootstrapped with DNS, packages, power policy, GPU passthrough, and Proxmox customizations, then joined into a cluster.
- **Proxmox templates** are built and used to provision **LXC containers and VMs** for each service host (`wireguard`, `web`, `django-app`, `django-db`).
- **GitLab CI/CD** (self-hosted, deployed by this same repo) runs the pipeline that applies these playbooks against the cluster on a schedule.
- A **Django application** is deployed on its own host with a dedicated PostgreSQL VM, gunicorn + nginx, automatic Let's Encrypt certificates, and a systemd-timer based scheduler.

## Features

- **Cluster bootstrap**: DNS, package/repo management, power policy, GPU passthrough, Proxmox customizations and clustering
- **Proxmox provisioning**: template builds and LXC container / VM lifecycle management, with drift reconciliation against existing instances
- **Self-hosted GitLab**: installation, project/mirror setup, and CI runner registration
- **WireGuard VPN**: server setup with per-client config and QR code generation
- **Django app deployment**: pyenv-managed Python, virtualenv, migrations, gunicorn + nginx, Let's Encrypt via certbot, systemd-timer scheduler, hCaptcha config
- **Supporting infrastructure**: PostgreSQL provisioning, LVM storage setup, SSH/user management, private GitHub repo deployment

## Prerequisites

- Ansible 2.9+
- SSH access to target hosts
- Python 3 on control and managed nodes (bootstrapped automatically on cluster nodes via `common/bootstrap`)
- Required Ansible collections (install via `ansible-galaxy collection install -r requirements.yml`)

## Quick Start

1. **Install dependencies**:
   ```bash
   ansible-galaxy collection install -r requirements.yml
   ```

2. **Configure inventory**:
   Edit `inventory/hosts.ini` and `inventory/group_vars/` / `inventory/host_vars/` files to match your environment.

3. **Prepare private variables**:
   - Copy [.env.example](.env.example) to `.env` and fill in real values (see the prefix table below for where each variable ends up).
   - Run `ENV_FILE=.env ./scripts/setup_vars.sh` to generate `inventory/group_vars/<group>/private_vars.yml` and `inventory/host_vars/django-app/private_vars.yml`.

4. **Run playbooks**:
   - Local dev environment: `ansible-playbook playbooks/setup_local.yml`
   - Cluster bootstrap: `ansible-playbook -i inventory/hosts.ini playbooks/setup_servers.yml`
   - Deploy services: `ansible-playbook -i inventory/hosts.ini playbooks/deploy_services.yml`

## Project Structure

```
├── playbooks/           # Entry-point playbooks
├── roles/
│   ├── common/          # Shared bootstrap roles (packages, DNS, repos, OS detection)
│   ├── infrastructure/  # Proxmox cluster + host-level infrastructure roles
│   ├── local/           # Local dev environment roles (Docker, GitLab)
│   └── services/        # Per-service deployment roles (Django, Postgres, WireGuard, ...)
├── inventory/           # Hosts, group_vars, host_vars (private_vars.yml is generated, not committed)
├── vars/                # Global setup variables
├── scripts/              # setup_vars.sh: turns ENV_FILE into private_vars.yml files
├── ansible.cfg
├── requirements.yml      # Required Ansible collections
├── .env.example          # Template for the variables setup_vars.sh expects
└── .gitlab-ci.yml         # Scheduled pipeline that runs setup_servers.yml / deploy_services.yml
```

## Playbooks

- `setup_local.yml`: Sets up a local dev environment — disables MOTD, builds Docker images, and installs a self-hosted GitLab instance in containers.
- `setup_servers.yml`: Bootstraps the Proxmox cluster nodes (DNS, repos, packages, power policy, GPU, Proxmox customizations) and forms the cluster.
- `deploy_services.yml`: Provisions LXC containers/VMs from templates, then deploys per-host services (WireGuard, PostgreSQL, Django app) onto them.

## Roles Overview

### Common
- `common/bootstrap`: Ensure Python 3 is present before Ansible facts can be gathered
- `common/os_detect`: Detect Proxmox vs. plain Debian hosts
- `common/dns_setup`: Configure DNS resolvers
- `common/repositories`: Manage apt and deb822 package repositories (Debian and Proxmox sources)
- `common/packages`: Install/remove system packages
- `common/role_guard`: Pre-flight OS/group checks before a role runs

### Infrastructure
- `infrastructure/proxmox_cluster`: Create and join Proxmox cluster nodes
- `infrastructure/proxmox_customizations`: Remove the subscription nag, tweak lid-switch/logind behavior
- `infrastructure/power_policy`: CPU power policy and battery handling
- `infrastructure/gpu_manager`: Mount/unmount GPU devices from the PCI bus

### Local
- `local/disable_motd`: Disable the message of the day
- `local/docker_images`: Build local Docker images
- `local/docker_containers`: Manage local Docker container lifecycle
- `local/gitlab_setup`: Install and configure a self-hosted GitLab instance, mirror images, register the CI runner

### Services
- `services/proxmox_templates`: Build and maintain Proxmox LXC/VM templates
- `services/proxmox_instances`: Create and remove Proxmox LXC containers and VMs
- `services/terraform`: Reconcile existing Proxmox VMs/LXCs against inventory (drift detection)
- `services/storage`: Configure LVM partitions and logical volumes on VM storage disks
- `services/user_management`: Manage users and SSH access on containers and VMs
- `services/github_repositories`: Clone/update private GitHub repositories
- `services/install_wireguard`: WireGuard VPN server setup with per-client config and QR codes
- `services/postgresql`: Provision a PostgreSQL database and user
- `services/nginx`: Reverse proxy and static file serving for deployed apps
- `services/ssl_certbot`: Automate Let's Encrypt certificate issuance and renewal
- `services/django_app`: Deploy the Django app — pyenv-managed Python, virtualenv, migrations, gunicorn, systemd-timer scheduler, hCaptcha config

## Configuration

Customize deployments through:
- `inventory/group_vars/` and `inventory/host_vars/`: environment- and host-specific variables
- `vars/setup.yml`: global setup variables
- `scripts/setup_vars.sh`: generates private variable files from an `ENV_FILE` (see below)
- Role defaults in `roles/*/defaults/main.yml`

## Pipeline Environment Variables

The pipeline reads deployment variables from an external `ENV_FILE` provided at runtime (a GitLab CI file-type variable in production; a local file path when run manually).

Each variable is automatically extracted and written into the appropriate Ansible `private_vars.yml` file based on its prefix:

| Prefix | Target Ansible Variables File |
|--------|-------------------------------|
| `all_` | `inventory/group_vars/all/private_vars.yml` |
| `cluster_` | `inventory/group_vars/cluster/private_vars.yml` |
| `services_` | `inventory/group_vars/services/private_vars.yml` |
| `django-app_` | `inventory/host_vars/django-app/private_vars.yml` |

See [.env.example](.env.example) for the full list of expected variables and their prefixes.

## CI/CD

`.gitlab-ci.yml` defines a two-stage pipeline (`setup_infra`, `deploy_services`) that only runs on a schedule or manual web trigger — never on every push. Each stage is independently gated by a `setup_infra` / `deploy_services` CI variable and runs against hosts selected with `$ANSIBLE_LIMIT`.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
