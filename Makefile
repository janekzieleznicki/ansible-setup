VENV        ?= .venv
PYTHON      := $(VENV)/bin/python
PIP         := $(VENV)/bin/pip
MOLECULE    := $(VENV)/bin/molecule
ANSIBLE_GALAXY := ansible-galaxy
PODMAN      := podman
# Molecule ephemeral dir token: first 4 chars of urlsafe-b64(sha256(project dir name))
MOLECULE_TOKEN := $(shell printf '%s' "$(notdir $(CURDIR))" | sha256sum | cut -c1-6 | xxd -r -p | base64 | tr '+/' '-_')
MOLECULE_EPHEMERAL_BASE := $(HOME)/.ansible/tmp
ANSIBLE_PLAYBOOK := ansible-playbook

# Standard goals that must not be treated as platform limit arguments
STANDARD_TARGETS = test-smoke test-full converge destroy dependency-smoke destroy-smoke create-smoke prepare-smoke verify-smoke dependency-full destroy-full create-full converge-full verify-full cleanup-full
# Capture extra goals (platform names) after the main target
LIMIT_ARGS := $(filter-out $(STANDARD_TARGETS),$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS)))
# Prevent make from trying to build platform names as targets
ifneq ($(LIMIT_ARGS),)
  $(eval $(LIMIT_ARGS):;@:)
endif
.PHONY: deps test test-smoke test-full converge destroy dependency-smoke destroy-smoke create-smoke prepare-smoke verify-smoke dependency-full destroy-full create-full converge-full verify-full cleanup-full

$(VENV):
	python3 -m venv --system-site-packages $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install "molecule==26.6.0" "molecule-plugins==26.7.15" ansible-lint
deps:
	$(ANSIBLE_GALAXY) collection install community.general containers.podman community.docker

test-smoke: $(VENV)
	$(MAKE) dependency-smoke destroy-smoke create-smoke prepare-smoke verify-smoke $(LIMIT_ARGS)

test-full: $(VENV)
	$(MAKE) dependency-full destroy-full create-full converge-full verify-full $(LIMIT_ARGS)
	$(MOLECULE) destroy -s full

test: test-smoke test-full

converge:
	$(info DEBUG: $@ = $@, MAKECMDGOALS = $(MAKECMDGOALS), LIMIT_ARGS = $(LIMIT_ARGS))
	$(MOLECULE) --debug converge -s full $(if $(LIMIT_ARGS),-- --limit $(LIMIT_ARGS))

destroy:
	$(MOLECULE) destroy -s full
	$(MOLECULE) destroy -s smoke
dependency-smoke: $(VENV)
	$(MOLECULE) dependency -s smoke

destroy-smoke: $(VENV)
	$(MOLECULE) destroy -s smoke

create-smoke: $(VENV)
	$(MOLECULE) create -s smoke

prepare-smoke: $(VENV)
	$(MOLECULE) prepare -s smoke $(if $(LIMIT_ARGS),-- --limit $(LIMIT_ARGS))

verify-smoke: $(VENV)
ifneq ($(LIMIT_ARGS),)
	ANSIBLE_CONFIG=$(MOLECULE_EPHEMERAL_BASE)/molecule.$(MOLECULE_TOKEN).smoke/ansible.cfg \
	$(ANSIBLE_PLAYBOOK) --diff \
		--inventory $(MOLECULE_EPHEMERAL_BASE)/molecule.$(MOLECULE_TOKEN).smoke/inventory \
		--skip-tags molecule-notest,notest \
		--limit $(LIMIT_ARGS) \
		molecule/smoke/verify.yml
else
	$(MOLECULE) verify -s smoke
endif

dependency-full: $(VENV)
	$(MOLECULE) dependency -s full

destroy-full: $(VENV)
	$(MOLECULE) destroy -s full

create-full: $(VENV)
	$(MOLECULE) create -s full

converge-full: $(VENV)
	$(MOLECULE) converge -s full $(if $(LIMIT_ARGS),-- --limit $(LIMIT_ARGS))

verify-full: $(VENV)
ifneq ($(LIMIT_ARGS),)
	ANSIBLE_CONFIG=$(MOLECULE_EPHEMERAL_BASE)/molecule.$(MOLECULE_TOKEN).full/ansible.cfg \
	$(ANSIBLE_PLAYBOOK) --diff \
		--inventory $(MOLECULE_EPHEMERAL_BASE)/molecule.$(MOLECULE_TOKEN).full/inventory \
		--skip-tags molecule-notest,notest \
		--limit $(LIMIT_ARGS) \
		molecule/full/verify.yml
else
	$(MOLECULE) verify -s full
endif

cleanup-full: $(VENV)
	$(MOLECULE) cleanup -s full
clean: destroy
	rm -rf $(VENV)