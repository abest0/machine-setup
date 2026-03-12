# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an Ansible playbook project that provisions a cloud EC2 instance as a fully configured development machine. It is used as a submodule of `dev-environment-wizard` and is meant to be run from a local machine against a remote host over SSH.

## Commands

```bash
# Install Python/Ansible dependencies (first time only)
uv sync

# Install Ansible Galaxy roles and collections (first time, or after requirements.yml changes)
uv run ansible-galaxy install -r requirements.yml --force

# Run the full playbook against a target machine
uv run ansible-playbook playbook.yml -i <HOST_IP_OR_INSTANCE_ID>, -u <USER>

# Use the convenience wrapper script (sets user from $dev_user env var, defaults to ec2-user)
./scripts/machine-setup.sh <machine_name> [extra ansible-playbook args...]
# Example:
./scripts/machine-setup.sh i-0abc123 -e dev_user=dev -u ubuntu

# Run only specific tagged tasks
uv run ansible-playbook playbook.yml -i <HOST>, --tags "packages,docker"
```

**Note:** The trailing comma after the host address is required when passing a single host inline (e.g., `-i 192.168.1.1,`).

## Architecture

### Execution flow

`playbook.yml` is the single entry point. It runs as `root` (`become: yes`) and:

1. Loads `vars/defaults.yml` (shared defaults for all distros)
2. Conditionally loads `vars/<ansible_distribution|lower>-vars.yml` (e.g., `amazon-vars.yml` or `ubuntu-vars.yml`) to set OS-specific package lists and the default `user` variable
3. Runs tasks inline and delegates to task files in `tasks/`

### Variable precedence

- `vars/defaults.yml` — shared defaults: dotfiles repo URL, Node.js version, npm config, `node_packages`, `backup_files`
- `vars/amazon-vars.yml` — sets `user: ec2-user`, Amazon Linux package list
- `vars/ubuntu-vars.yml` — sets `user: ubuntu`, Ubuntu/Debian package list
- `dev_user` — the non-root user to configure; defaults to the distro `user` value; can be overridden via `-e dev_user=<name>`

### Task files and their tags

| File | Tags | Purpose |
|------|------|---------|
| `tasks/user.yml` | `user` | Creates `dev_user` group/user, adds to `sudo`/`wheel` |
| `tasks/awscli-2.yml` | *(inline)* | Installs AWS CLI v2 |
| `tasks/dev-tools.yml` | `dev-tools`, `python`, `node` | Installs `uv` and `pnpm` via install scripts |
| `tasks/vim.yml` | `vim`, `dev` | Builds vim from source |
| `tasks/dev-pro.yml` | `q` | Installs `q` (AWS CLI query tool) |
| `tasks/home.yml` | `dotfiles`, `backup`, `home_env`, `ssh` | Installs pyenv, clones dotfiles repo, creates symlinks, sets up SSH |
| `tasks/auto-shutdown.yml` | `shutdown` | Installs OS-specific inactivity shutdown script as a systemd timer |

### Notable behaviors

- **Dotfiles**: `tasks/home.yml` clones `https://github.com/abest0/dotfiles` into `~/dotfiles`, backs up existing dotfiles to `~/backup_dotfiles/`, then symlinks them from `~/dotfiles/<name>` to `~/.<name>` for each item in `backup_files`.
- **Auto-shutdown**: Copies `files/amazon-stop-if-inactive.sh` or `files/ubuntu-stop-if-inactive.sh` based on `ansible_distribution`, sets up a systemd timer (enabled) and service (disabled by default).
- **Node.js**: Uses `geerlingguy.nodejs` role for non-Amazon Linux 2023; uses direct `npm` module for Amazon Linux 2023 (version `"2023"`).
- **Docker**: Installed via a custom role at `git+https://github.com/abest0/ansible-role-docker.git`; `dev_user` is added to the docker group.

### Galaxy dependencies (`requirements.yml`)

- `geerlingguy.repo-epel` (1.3.0) — EPEL repo for RedHat-family
- `geerlingguy.nodejs` — Node.js installation
- `abest0/ansible-role-docker` — Docker installation (from GitHub)
- `amazon.aws` collection
