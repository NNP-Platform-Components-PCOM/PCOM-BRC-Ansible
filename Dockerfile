# syntax=docker/dockerfile:1.7
#
# PCOM - BRC - Ansible
# --------------------
# Ansible build/automation image on the PCOM Ubuntu base. Ships Python 3,
# Ansible, Kubernetes tooling (kubectl, helm, python-kubernetes), the NiFi
# toolkit CLI, database clients, and OpenTelemetry SDKs. Part of the Nubo
# Native Platform (NNP) build images.
#
# Build:
#   docker build -t pcom-brc-ansible:6.7.0-v1 .

# Base image: the PCOM Ubuntu runtime base. Overridable at build time.
ARG base_image=ghcr.io/nnp-platform-components-pcom/pcom-brc-ubuntu
ARG base_version=22.04-v1

FROM ${base_image}:${base_version}

# --- OCI image metadata (populated by CI, overridable at build time) ---------
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION="6.7.0-v1"
ARG nifi_toolkit_version=2.0.0

LABEL org.opencontainers.image.title="pcom-brc-ansible" \
      org.opencontainers.image.description="Ansible build image on the PCOM Ubuntu base (Python 3, kubectl, helm, NiFi toolkit)." \
      org.opencontainers.image.vendor="Nubo Native Platform" \
      org.opencontainers.image.source="https://github.com/NNP-Platform-Components-PCOM/PCOM-BRC-Ansible" \
      org.opencontainers.image.url="https://github.com/NNP-Platform-Components-PCOM/PCOM-BRC-Ansible" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}"

ENV TZ=Europe/Minsk \
    DEBIAN_FRONTEND=noninteractive \
    ANSIBLE_HOST_KEY_CHECKING=False

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# System packages.
RUN apt-get update && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        curl \
        ca-certificates \
        gnupg \
        lsb-release \
        software-properties-common \
        openssh-client \
        postgresql-client \
        default-mysql-client \
        unzip \
    && rm -rf /var/lib/apt/lists/*

# NiFi toolkit CLI.
RUN curl -fsSL "https://archive.apache.org/dist/nifi/${nifi_toolkit_version}/nifi-toolkit-${nifi_toolkit_version}-bin.zip" -o /tmp/nifi-toolkit.zip \
    && unzip /tmp/nifi-toolkit.zip -d /opt \
    && ln -s "/opt/nifi-toolkit-${nifi_toolkit_version}/bin/cli.sh" /usr/local/bin/nifi-cli \
    && rm -f /tmp/nifi-toolkit.zip

# Make python3 the default `python`.
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Python tooling: Ansible, Kubernetes and OpenTelemetry libraries.
RUN python3 -m pip install --upgrade pip \
    && pip install \
        ansible \
        kubernetes \
        pyyaml \
        docker \
        httpie \
        opentelemetry-sdk \
        opentelemetry-exporter-otlp \
        opentelemetry-api

# kubectl (matches the amd64 image architecture).
RUN curl -fsSLO "https://storage.googleapis.com/kubernetes-release/release/$(curl -fsSL https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# helm.
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
