VENV        ?= .venv
PYTHON      := $(VENV)/bin/python
PIP         := $(VENV)/bin/pip
MOLECULE    := $(VENV)/bin/molecule
ANSIBLE_GALAXY := ansible-galaxy
PODMAN      := podman

# Capture extra goals (platform names) after the main target
LIMIT_ARGS = $(filter-out $@,$(MAKECMDGOALS))
# Prevent make from trying to build those as targets
$(eval $(LIMIT_ARGS):;@:)

.PHONY: deps test test-smoke test-full converge destroy

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

clean: destroy
	rm -rf $(VENV)