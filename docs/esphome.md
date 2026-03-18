# ESPHome Helm Chart

A Helm chart for ESPHome dashboard with host network support for device discovery.

## Features
- **Host Network**: Enabled by default for mDNS device discovery.
- **Ingress**: Dictionary-based multi-ingress support (e.g. external HTTPS + internal LAN).
- **Persistence**: Config volume via hostPath.

## Installation

### 1. Configure Values
Review the [values.yaml](https://github.com/shadoll/helm-charts/blob/main/esphome/values.yaml) and create your override file.

### 2. Install
```bash
helm install my-esphome ./esphome -f my-values.yaml
```

## Configuration Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | ESPHome image repository | `ghcr.io/esphome/esphome` |
| `image.pullPolicy` | Image pull policy | `Always` |
| `timezone` | Container timezone | `Europe/Kyiv` |
| `usePing` | Use ping for device status | `true` |
| `hostNetwork` | Enable host networking | `true` |
| `volume.hostPath` | Host path for config persistence | `""` |
| `ingresses` | Dictionary of ingress definitions | `{}` |

For detailed configuration, see the [values.yaml](https://github.com/shadoll/helm-charts/blob/main/esphome/values.yaml).
