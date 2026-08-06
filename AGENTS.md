# AGENTS.md

## Layout

- `main.yml` - top-level playbook (roles: `server` tagged `dotfiles`, `terraform` tagged `virtools`)
- `roles/` - Ansible roles (`server`, `terraform`, `nerd-font`)
- `molecule/` - Molecule scenarios (`smoke`, `full`) + `requirements.yml`
- `dockerfiles/` - base container image definitions used by the molecule scenarios
- `Makefile` - orchestration of dependency setup, image builds, and test runs

## Testing

Molecule tests run against podman containers. Two scenarios:

- `smoke`: creates a container per distro and only verifies base packages exist (no converge).
- `full`: converges `main.yml` (with `--skip-tags virtools`, since that tag needs
  systemd/libvirtd unavailable in containers) and verifies installed packages/artifacts.

Commands:

```bash
make deps        # venv + Molecule + galaxy collections
make images      # build the distro container images
make test-smoke  # molecule test -s smoke
make test-full   # molecule test -s full
make converge    # molecule converge -s full (debug against running container)
```

Always run `make test-smoke` and `make test-full` before finishing; they must
pass on all 10 platforms:

- fedora-newest (fedora:41), fedora-previous (fedora:40)
- rhel8 (rockylinux:8 - a full-RHEL8-like free stand-in), centos-stream, rocky, alma, oracle (EL9 family)
- rocky-10 (EL10 family; dnf-based, python 3.12 native)
- opensuse (Tumbleweed), opensuse-leap (Leap 15.6)

## Conventions

- Containers run as root, so `zsh_user`/`username`/`user` resolve to `root`
  (paths mix `/home/root/...` for role-derived homes and `/root/...` for `~`).
- The Air `ansible_python_interpreter` is forced to `/usr/bin/python3.11` on the
  `rhel8` and `opensuse-leap` platforms because their default `python3` is 3.6.
- Verify uses `rpm -q --whatprovides <pkg>` (works across rpm/SUSE) rather than
  `package_facts` to avoid rpm python-binding/interpreter issues.
- Driver is Molecule's `containers` plugin using the `podman` CLI backend.