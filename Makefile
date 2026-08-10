VENV        := .venv
PYTHON      := $(VENV)/bin/python
PIP         := $(VENV)/bin/pip
MOLECULE    := $(VENV)/bin/molecule
ANSIBLE_GALAXY := ansible-galaxy
PODMAN      := podman

.PHONY: deps test test-smoke test-full converge destroy

deps:
	python3 -m venv --system-site-packages $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install "molecule==26.6.0" "molecule-plugins==26.7.15" ansible-lint
	$(ANSIBLE_GALAXY) collection install community.general containers.podman community.docker

test-smoke:
	$(MOLECULE) test -s smoke

test-full:
	$(MOLECULE) test -s full

test: test-smoke test-full

converge:
	$(MOLECULE) converge -s full

destroy:
	$(MOLECULE) destroy -s full
	$(MOLECULE) destroy -s smoke
