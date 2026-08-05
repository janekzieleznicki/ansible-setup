# Ansible linux setup

Ansible playbook to provision a Linux workstation (packages + dotfiles) with
Molecule-based tests that run against container images via **podman**.

## Run on localhost

```bash
ansible-playbook -e user=$USER  --skip-tags="virtools" --connection=local --inventory localhost, -K main.yml
```

## Testing with Molecule + podman

Two test scenarios live under `molecule/`, each covering all supported
distributions in podman containers:

- **smoke** — create a container for each distro and verify the base-image
  packages the role/prerequisites depend on are present. No playbook converges.
- **full** — converge the whole `main.yml` playbook (skipping the `virtools`
  tag, since it needs systemd/libvirtd that containers lack), then verify that
  everything the role installs is actually present.

Supported distribution images:

| Platform        | Base image                               |
|-----------------|------------------------------------------|
| fedora-newest   | `fedora:41`                              |
| fedora-previous | `fedora:40`                              |
| rhel8           | `rockylinux:8` (full RHEL8 stand-in)     |
| centos-stream   | `centos:stream9`                         |
| rocky           | `rockylinux:9`                           |
| alma            | `almalinux:9`                            |
| oracle          | `oraclelinux:9`                          |
| opensuse        | `opensuse/tumbleweed`                    |
| opensuse-leap   | `opensuse/leap:15.6`                     |

### Prerequisites

- `podman` (rootless)
- `make`
- `python3` with virtualenv support

First time setup (creates `.venv`, installs Molecule and Ansible collections):

```bash
make deps
```

Build the container images used by both scenarios:

```bash
make images
```

Run the suites:

```bash
make test-smoke          # smoke scenario (fast)
make test-full           # full scenario (slow: compiles alacritty/ripgrep per distro)
make test                # both
```

Helper targets: `make converge` (converge the full scenario to debug a running
container), `make destroy`, `make clean` (destroy containers and remove images).