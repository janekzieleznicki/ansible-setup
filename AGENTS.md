# AGENTS.md

## Layout

- `main.yml` - top-level playbook (roles: `server` tagged `dotfiles`, `terraform` tagged `virtools`)
- `roles/` - Ansible roles (`server`, `terraform`, `nerd-font`)
- `molecule/` - Molecule scenarios (`smoke`, `full`) + `requirements.yml`
- `Makefile` - orchestration of dependency setup, image builds, and test runs

## Testing

Molecule tests run against podman containers. Two scenarios:

- `smoke`: creates a container per distro and only verifies base packages exist (no converge).
- `full`: converges `main.yml` (with `--skip-tags virtools`, since that tag needs
  systemd/libvirtd unavailable in containers) and verifies installed packages/artifacts.

Commands:

```bash
make deps        # venv + Molecule + galaxy collections
make test-smoke  # molecule test -s smoke
make test-full   # molecule test -s full
make converge    # molecule converge -s full (debug against running container)
```

Always run `make test-smoke` and `make test-full` before finishing; they must
pass on all 8 platforms:

- fedora-newest (fedora:latest)
- rhel8 (rockylinux:8)
- rocky (rockylinux:9)
- alma (almalinux:latest)
- rocky-10 (rockylinux/rockylinux:10)
- oracle-10 (oraclelinux:10)
- opensuse (opensuse/tumbleweed:latest)
- opensuse-leap (opensuse/leap:latest)

## Conventions

- Containers run as root, so `zsh_user`/`username`/`user` resolve to `root`
  (paths mix `/home/root/...` for role-derived homes and `/root/...` for `~`).
- The Air `ansible_python_interpreter` is forced to `/usr/bin/python3.11` on the
  `rhel8` and `opensuse-leap` platforms because their default `python3` is 3.6.
- Verify uses `rpm -q --whatprovides <pkg>` (works across rpm/SUSE) rather than
  `package_facts` to avoid rpm python-binding/interpreter issues.
- Driver is Molecule's `containers` plugin using the `podman` CLI backend.