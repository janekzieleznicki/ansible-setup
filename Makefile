VENV        := .venv
PYTHON      := $(VENV)/bin/python
PIP         := $(VENV)/bin/pip
MOLECULE    := $(VENV)/bin/molecule
ANSIBLE_GALAXY := ansible-galaxy
PODMAN      := podman

DOCKERFILES := dockerfiles

FEDORA_PLATFORMS := fedora:41 fedora:40
EL_PLATFORMS     := rockylinux:8 quay.io/centos/centos:stream9 \
                    rockylinux:9 almalinux:9 oraclelinux:9
SUSE_PLATFORMS   := registry.opensuse.org/opensuse/tumbleweed:latest \
                    registry.opensuse.org/opensuse/leap:15.6

MOLECULE_IMAGE  := localhost/molecule

.PHONY: deps images test test-smoke test-full converge clean destroy

deps:
	python3 -m venv --system-site-packages $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install "molecule==26.6.0" "molecule-plugins==26.7.15" ansible-lint
	$(ANSIBLE_GALAXY) collection install community.general containers.podman community.docker

# Build the container images used by both scenarios.
images:
	$(PODMAN) build --build-arg BASE_IMAGE=fedora:41 -t $(MOLECULE_IMAGE)-fedora:41 -f $(DOCKERFILES)/Containerfile.fedora .
	$(PODMAN) build --build-arg BASE_IMAGE=fedora:40 -t $(MOLECULE_IMAGE)-fedora:40 -f $(DOCKERFILES)/Containerfile.fedora .
	$(PODMAN) build -t $(MOLECULE_IMAGE)-el:8 -f $(DOCKERFILES)/Containerfile.rhel8 .
	$(PODMAN) build --build-arg BASE_IMAGE=quay.io/centos/centos:stream9 -t $(MOLECULE_IMAGE)-el:stream9 -f $(DOCKERFILES)/Containerfile.el .
	$(PODMAN) build --build-arg BASE_IMAGE=rockylinux:9 -t $(MOLECULE_IMAGE)-el:rocky-9 -f $(DOCKERFILES)/Containerfile.el .
	$(PODMAN) build --build-arg BASE_IMAGE=almalinux:9 -t $(MOLECULE_IMAGE)-el:alma-9 -f $(DOCKERFILES)/Containerfile.el .
	$(PODMAN) build --build-arg BASE_IMAGE=oraclelinux:9 -t $(MOLECULE_IMAGE)-el:oracle-9 -f $(DOCKERFILES)/Containerfile.el .
	$(PODMAN) build --build-arg BASE_IMAGE=registry.opensuse.org/opensuse/tumbleweed:latest -t $(MOLECULE_IMAGE)-suse:tumbleweed -f $(DOCKERFILES)/Containerfile.suse .
	$(PODMAN) build --build-arg BASE_IMAGE=registry.opensuse.org/opensuse/leap:15.6 -t $(MOLECULE_IMAGE)-suse:leap-15.6 -f $(DOCKERFILES)/Containerfile.leap .

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

clean: destroy
	$(PODMAN) rmi -f $(MOLECULE_IMAGE)-fedora:41 $(MOLECULE_IMAGE)-fedora:40 \
		$(MOLECULE_IMAGE)-el:8 $(MOLECULE_IMAGE)-el:stream9 $(MOLECULE_IMAGE)-el:rocky-9 \
		$(MOLECULE_IMAGE)-el:alma-9 $(MOLECULE_IMAGE)-el:oracle-9 \
		$(MOLECULE_IMAGE)-suse:tumbleweed $(MOLECULE_IMAGE)-suse:leap-15.6 2>/dev/null || true
