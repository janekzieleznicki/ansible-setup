ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN dnf -y --allowerasing install \
        python3 \
        python3-dnf \
        sudo \
        curl \
        tar \
    && dnf clean all
