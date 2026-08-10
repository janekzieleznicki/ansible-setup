VENV        ?= .venv
PYTHON      := $(VENV)/bin/python
PIP         := $(VENV)/bin/pip
MOLECULE    := $(VENV)/bin/molecule
ANSIBLE_GALAXY := ansible-galaxy
PODMAN      := podman

.PHONY: deps test test-smoke test-full converge destroy

$(VENV):
	python3 -m venv --system-site-packages $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install "molecule==26.6.0" "molecule-plugins==26.7.15" ansible-lint
	$(ANSIBLE_GALAXY) collection install community.general containers.podman community.docker

test-smoke: $(VENV)
	$(MOLECULE) --debug test -s smoke

test-full: $(VENV)
	$(MOLECULE) --debug test -s full

test: test-smoke test-full

converge:
	$(MOLECULE) --debug converge -s full

destroy:
	$(MOLECULE) destroy -s full
	$(MOLECULE) destroy -s smoke

clean: destroy
	rm -rf $(VENV)