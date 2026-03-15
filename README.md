# Shadoll Helm Charts

A collection of custom and optimized Helm charts for self-hosted applications on Kubernetes.

## Repository Structure

- `/charts`: Individual application charts (e.g. `jellyfin`).
- `/docs`: Detailed application documentation and guides.

## Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/shadoll/helm-charts.git
cd helm-charts
```

### 2. Available Charts

| Chart | Description | Status |
|-------|-------------|--------|
| [Jellyfin](docs/jellyfin.md) | Media server with PostgreSQL support | Ready |

### 3. Usage with FluxCD

To use these charts in a FluxCD environment, add the repository as a Source:

```yaml
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: shadoll-charts
  namespace: flux-system
spec:
  interval: 1h
  url: https://github.com/shadoll/helm-charts
  ref:
    branch: main
```

Then reference the chart in your `HelmRelease`:

```yaml
spec:
  chart:
    spec:
      chart: ./jellyfin
      sourceRef:
        kind: GitRepository
        name: shadoll-charts
```

## Maintenance

This repository follows automated version tracking where possible. For manual updates, modify the `appVersion` and increment the `version` in the respective `Chart.yaml`.

---
© 2026 Shadoll. Managed with ❤️ for the Home Lab.
