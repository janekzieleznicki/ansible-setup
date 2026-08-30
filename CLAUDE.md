# Project Context

## Development Environment
- **Provisioning:** Run `make .venv` to set up the virtual environment and install required dependencies (including `ansible-lint`).
- **Tool Paths:** Use the absolute path `/home/jzieleznicki/.local/bin/ansible-playbook` for playbook execution; it is not in the default system `PATH`.

## Coding Patterns
- **Membership Testing:** Prefer native collection methods (e.g., `item in list`, `list.includes(item)`) over manual `for`/`each` loops for membership testing.
