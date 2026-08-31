# Project Context

## Development Environment
- **Provisioning:** Run `make .venv` to set up the virtual environment and install required dependencies (including `ansible-lint`).
- **Tool Paths:** Use the absolute path `/home/jzieleznicki/.local/bin/ansible-playbook` for playbook execution; it is not in the default system `PATH`.

### Ansible & Environment
- `ansible_python_interpreter` - Force `/usr/bin/python3.11` on rhel8/opensuse-leap.

### Patterns
- `community.general.cargo` - Preferred over `ansible.builtin.command` loops for Rust crates.
- `deb822_repository` - Preferred over deprecated `apt_key` / `apt_repository`.

### Molecule / Testing
- **crun raw limitation:** Multiline raw tasks fail with `executable file 'if' not found`; use single-line `/bin/sh -c 'if ...; then ...; fi'` forms only
- **YAML `|` block scalar:** Use for inline Python/shell scripts; `>` folds newlines into spaces causing `SyntaxError`
- **unarchive module:** Requires gzip on all platforms + xz for .tar.xz; install in bootstrap or use Python tarfile instead
- **Python tarfile extraction:** `tarfile` module detects compression by magic bytes — handles both `.tar.gz` and `.tar.xz` without external binaries
- **Bootstrap tag mismatch:** Tasks tagged `install` do NOT run during converge (uses `base` tag); role must be self-sufficient
- **Package verification:** Use `rpm -q --whatprovides <pkg>` (works across rpm/SUSE) rather than `package_facts` to avoid rpm python-binding issues
- **openSUSE Tumbleweed:** GitHub CDN may serve `.tar.xz` even for `.tar.gz` requested URL — Python tarfile magic-byte detection is the workaround
- **Fedora DNS:** NetworkManager config in `/etc/NetworkManager/conf.d/`; use `ip -4 route show dev {{ ansible_default_ipv4.interface }}` for gateway
- **Package availability:** `python3-setuptools` not on openSUSE; `python3-neovim` is pip on Debian (not apt)

## Coding Patterns
- **Membership Testing:** Prefer native collection methods (e.g., `item in list`, `list.includes(item)`) over manual `for`/`each` loops for membership testing.
