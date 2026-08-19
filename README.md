# PCOM - BRC - Ansible

**Build component: Ansible** — an Ansible automation image built on the PCOM
Ubuntu base for the Nubo Native Platform (NNP). Ships Python 3, Ansible,
Kubernetes tooling, the NiFi toolkit CLI, database clients, and OpenTelemetry
SDKs.

## Image

Published to Docker Hub on every push to `main`:

```
docker.io/nubonativesolution/pcom-brc-ansible:6.7.0-v1
docker.io/nubonativesolution/pcom-brc-ansible:latest
```

Architecture: `linux/amd64`.

## Included tooling

- **Python 3** + pip (`python` maps to `python3`)
- **Ansible** (+ `pyyaml`, `docker`, `httpie`)
- **Kubernetes**: `kubectl`, `helm`, python `kubernetes`
- **OpenTelemetry**: `opentelemetry-sdk`, `opentelemetry-api`, `opentelemetry-exporter-otlp`
- **NiFi toolkit** CLI as `nifi-cli`
- Clients: `openssh-client`, `postgresql-client`, `default-mysql-client`
- `ANSIBLE_HOST_KEY_CHECKING=False`

## Build locally

```bash
docker build -t pcom-brc-ansible:6.7.0-v1 .
```

## CI/CD

`.github/workflows/build.yml` is a thin caller for the shared
[`PCOM-CICD`](https://github.com/NNP-Platform-Components-PCOM/PCOM-CICD)
reusable pipeline: build with Buildx, publish to **GHCR** with SBOM +
provenance, sign with **cosign keyless** (OIDC), and scan with Trivy and Grype
(results in the **Security** tab). Pull requests build and scan without
publishing.
