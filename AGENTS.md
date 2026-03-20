# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a collection of Helm charts for self-hosted applications on Kubernetes, designed for use with FluxCD GitOps. Charts: **jellyfin** (media server + PostgreSQL), **home-assistant** (home automation + PostgreSQL), **esphome** (IoT device dashboard).

## Common Commands

```bash
# Lint a chart
helm lint ./jellyfin

# Template a chart (render without installing)
helm template my-release ./jellyfin -f my-values.yaml

# Install/upgrade a chart
helm install <release> ./<chart> -f my-values.yaml
helm upgrade <release> ./<chart> -f my-values.yaml

# Run the automated version update script (checks upstream for new image tags)
./scripts/update-charts.sh
```

## Architecture

Each chart follows the same structure: `Chart.yaml`, `values.yaml`, and `templates/` (deployment, service, ingress, plus chart-specific resources like PVCs or init jobs).

### Automated Version Updates

Charts use custom `Chart.yaml` annotations to enable automated upstream version tracking:
- `version-source`: specifies where to check (e.g., `github-release:jellyfin/jellyfin` or `dockerhub-tags:...`)
- `version-pattern`: sed pattern to clean the fetched tag (e.g., strip `v` prefix)

`scripts/update-charts.sh` iterates all charts, fetches the latest upstream version, and bumps `appVersion` and `version` (patch increment) in `Chart.yaml` when an update is found. This runs daily via GitHub Actions (`.github/workflows/update-charts.yml`) and optionally sends Signal notifications on updates.

### Chart Conventions

- Image tags default to `Chart.AppVersion` (set via `image.tag | default .Chart.AppVersion`)
- Secrets are referenced via `existingSecret` — charts never create secrets directly
- Persistence supports both `hostPath` and PVC modes
- Jellyfin chart includes a `db-init-job` for PostgreSQL schema initialization
- ESPHome uses `hostNetwork: true` for mDNS device discovery
