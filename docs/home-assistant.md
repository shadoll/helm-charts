# Home Assistant Helm Chart

A Helm chart for Home Assistant with PostgreSQL recorder support, managed secrets, and Kubernetes-native logging.

## Features
- **PostgreSQL Recorder**: Optional PostgreSQL backend for HA recorder with automated database and user creation via `db-init` job.
- **Managed Secrets**: HA `secrets.yaml` generated from Kubernetes Secrets (works with sealed-secrets).
- **Kubernetes-native Logging**: Log file disabled, all logs go to stdout (`kubectl logs`).
- **Backups**: Integrated CronJob for automated PostgreSQL backups with configurable retention and node pinning.
- **Ingress**: Dictionary-based multi-ingress support (e.g. external HTTPS + internal LAN).
- **Host Network**: Enabled by default for mDNS/HomeKit discovery.
- **Persistence**: Config and media volumes with hostPath or PVC support.

## Installation

### 1. Create Secrets

**PostgreSQL secret** (if using postgres recorder):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ha-secret
stringData:
  HA_POSTGRESQL_PASSWORD: "<password>"
  POSTGRES_ADMIN_PASSWORD: "<admin-password>"
```

**HA secrets** (optional, for managing HA `secrets.yaml`):
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ha-ha-secrets
stringData:
  api_key: "some-api-key"
  webhook_token: "some-token"
```

### 2. Configure Values
Review the [values.yaml](https://github.com/shadoll/helm-charts/blob/main/home-assistant/values.yaml) and create your override file.

### 3. Install
```bash
helm install my-ha ./home-assistant -f my-values.yaml
```

## Configuration Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | HA image repository | `ghcr.io/home-assistant/home-assistant` |
| `image.tag` | HA image tag | (Chart appVersion) |
| `hostNetwork` | Enable host networking | `true` |
| `timezone` | Container timezone | `Europe/Kyiv` |
| `homekit.enabled` | Expose HomeKit port (21063) | `true` |
| `persistence.config.type` | Config volume type (`hostPath` or `pvc`) | `hostPath` |
| `persistence.media.enabled` | Enable media volume | `true` |
| `haSecrets.enabled` | Manage HA secrets.yaml from K8s Secret | `false` |
| `haSecrets.existingSecret` | K8s Secret name for HA secrets | `""` |
| `postgres.enabled` | Enable PostgreSQL recorder | `false` |
| `postgres.host` | PostgreSQL host | `postgres-tcp.postgres.svc.cluster.local` |
| `postgres.db` | Database name | `homeassistant` |
| `postgres.user` | Database user | `ha` |
| `postgres.existingSecret` | K8s Secret with DB credentials | `""` |
| `dbInit.enabled` | Enable database initialization job | `false` |
| `backup.enabled` | Enable automated PostgreSQL backups | `false` |
| `backup.node` | Pin backup CronJob to specific node | `""` |
| `http.enabled` | **Deprecated, see below.** Generate `http.yaml` and include it from `configuration.yaml` | `false` |

For detailed configuration, see the [values.yaml](https://github.com/shadoll/helm-charts/blob/main/home-assistant/values.yaml).

## Deprecations

### `http:` config section (removal planned for appVersion 2027.7)
HA core has migrated the entire `http:` config section — `server_port`, `ip_ban_enabled`,
`login_attempts_threshold`, `use_x_forwarded_for`, and `trusted_proxies` — out of
`configuration.yaml`. Setting `http.enabled: true` makes HA log:

> The HTTP configuration in configuration.yaml has already been migrated and is now being
> ignored. Please remove the http: block from your configuration.yaml.

Leave `http.enabled: false` (the default). The `init-http` init container, the `http:` values
block, and this section will be removed from the chart once `appVersion` reaches 2027.7.

## Architecture

### Init Containers
1. **init-config** (always): Cleans up old log files from PVC.
2. **init-secrets** (when `haSecrets.enabled`): Generates `/config/secrets.yaml` from K8s Secret key-value pairs.
3. **init-recorder** (when `postgres.enabled`): Generates `/config/recorder.yaml` with PostgreSQL connection string and appends `recorder: !include recorder.yaml` to `configuration.yaml`.
4. **init-http** (when `http.enabled`, **deprecated**, see [Deprecations](#deprecations)): Generates `/config/http.yaml` and appends `http: !include http.yaml` to `configuration.yaml`.

### Logging
The container patches the HA s6-overlay run script to pass `--log-file /dev/null`, disabling file-based logging. All logs go to stdout and are accessible via `kubectl logs`.
