# Project Context

## Development Environment
- **Provisioning:** Run `make .venv` to set up the virtual environment and install required dependencies (including `ansible-lint`).
- **Tool Paths:** Use the absolute path `/home/jzieleznicki/.local/bin/ansible-playbook` for playbook execution; it is not in the default system `PATH`.

### Ansible & Environment
- `ansible_python_interpreter` - Force `/usr/bin/python3.11` on rhel8/opensuse-leap.

### Patterns
- `community.general.cargo` - Preferred over `ansible.builtin.command` loops for Rust crates.
- `deb822_repository` - Preferred over deprecated `apt_key` / `apt_repository`.

### Workflow
- Verification - MUST run `make test-smoke` and `make test-full` before finishing development.

## Coding Patterns
- **Membership Testing:** Prefer native collection methods (e.g., `item in list`, `list.includes(item)`) over manual `for`/`each` loops for membership testing.
