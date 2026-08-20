VENV        ?= .venv
PYTHON      := $(VENV)/bin/python
PIP         := $(VENV)/bin/pip
MOLECULE    := $(VENV)/bin/molecule
ANSIBLE_GALAXY := ansible-galaxy
PODMAN      := podman

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
	$(info DEBUG: $@ = $@, MAKECMDGOALS = $(MAKECMDGOALS), LIMIT_ARGS = $(LIMIT_ARGS))
	$(MOLECULE) --debug test -s smoke $(if $(LIMIT_ARGS),-- --limit $(LIMIT_ARGS))

test-full: $(VENV)
	$(info DEBUG: $@ = $@, MAKECMDGOALS = $(MAKECMDGOALS), LIMIT_ARGS = $(LIMIT_ARGS))
	$(MOLECULE) --debug test -s full $(if $(LIMIT_ARGS),-- --limit $(LIMIT_ARGS))

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
	$(MOLECULE) verify -s smoke $(if $(LIMIT_ARGS),-- --limit $(LIMIT_ARGS))

dependency-full: $(VENV)
	$(MOLECULE) dependency -s full

destroy-full: $(VENV)
	$(MOLECULE) destroy -s full

create-full: $(VENV)
	$(MOLECULE) create -s full

converge-full: $(VENV)
	$(MOLECULE) converge -s full $(if $(LIMIT_ARGS),-- --limit $(LIMIT_ARGS))

verify-full: $(VENV)
	$(MOLECULE) verify -s full $(if $(LIMIT_ARGS),-- --limit $(LIMIT_ARGS))

cleanup-full: $(VENV)
	$(MOLECULE) cleanup -s full
clean: destroy
	rm -rf $(VENV)