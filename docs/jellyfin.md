# Jellyfin Helm Chart

A modern, parameterized Helm chart for Jellyfin media server with PostgreSQL support and integrated backup capabilities.

## Features
- **PostgreSQL Support**: Uses the Jellyfin PostgreSQL adapter for robust database storage.
- **Database Initialization**: Automated schema and database creation via `db-init` job.
- **Backups**: Integrated CronJob for automated database backups with configurable retention.
- **Ingress**: Dual-ingress pattern support (Internal HTTP and External HTTPS via Traefik).
- **Security**: Designed for use with `existingSecret` for credentials management.

## Installation

### 1. Create a Secret
Create a secret named `jellyfin-secret` containing:
- `JELLYFIN_POSTGRESQL_PASSWORD`: The password for the jellyfin user.
- `POSTGRES_ADMIN_PASSWORD`: The superuser password for database initialization.

### 2. Configure Values
Review the [values.yaml](https://github.com/shadoll/helm-charts/blob/main/jellyfin/values.yaml) and create your override file.

### 3. Install
```bash
helm install my-jellyfin ./jellyfin -f my-values.yaml
```

## Configuration Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | Jellyfin image repository | `ghcr.io/rogly-net/jellyfin-postgresql` |
| `image.tag` | Jellyfin image tag | (Chart appVersion) |
| `postgres.host` | PostgreSQL host address | `postgres-tcp.postgres.svc.cluster.local` |
| `persistence.config.enabled` | Enable config persistence | `true` |
| `backup.enabled` | Enable automated backups | `true` |

For detailed configuration, see the [values.yaml](https://github.com/shadoll/helm-charts/blob/main/jellyfin/values.yaml).
