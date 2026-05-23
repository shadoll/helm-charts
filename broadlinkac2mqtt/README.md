# Broadlink AC2MQTT Helm Chart

Bridge between Broadlink-based air conditioners and MQTT. Enables control of Broadlink AC units through MQTT, with Home Assistant auto-discovery support.

## Overview

- **Application**: [ArtemVladimirov/broadlinkac2mqtt](https://github.com/ArtemVladimirov/broadlinkac2mqtt)
- **Type**: MQTT bridge (no HTTP server)
- **Platform Support**: Multi-arch (amd64, arm64)
- **Image**: `ghcr.io/artemvladimirov/broadlinkac2mqtt`

## Features

- Control Broadlink AC units via MQTT
- Home Assistant MQTT Discovery support
- Multi-device support
- Configurable update intervals
- Automatic reconnection handling
- Health checks for container reliability

## Prerequisites

- Kubernetes cluster
- MQTT broker (e.g., Mosquitto)
- Broadlink AC units on your network
- Device IP addresses and MAC addresses

## Installation

### Basic Installation

```bash
helm install broadlinkac2mqtt ./broadlinkac2mqtt \
  --set config.mqtt.server="tcp://mqtt-broker:1883" \
  --set config.mqtt.user="myuser" \
  --set config.mqtt.password="mypassword"
```

### With Device Configuration

Create a `values-custom.yaml` file:

```yaml
config:
  mqtt:
    server: "tcp://mqtt.home.lan:1883"
    user: "broadlink"
    password: "secret"
    discovery: true
    discovery_prefix: "homeassistant"
  
  devices:
    - ip: "192.168.1.100"
      mac: "AA:BB:CC:DD:EE:FF"
      name: "Living Room AC"
      port: 80
      temp_unit: "C"
    
    - ip: "192.168.1.101"
      mac: "11:22:33:44:55:66"
      name: "Bedroom AC"
      port: 80
      temp_unit: "F"
```

Install with custom values:

```bash
helm install broadlinkac2mqtt ./broadlinkac2mqtt -f values-custom.yaml
```

### Using Existing Secret for MQTT Credentials

Create a secret:

```bash
kubectl create secret generic broadlink-mqtt-creds \
  --from-literal=MQTT_USER=myuser \
  --from-literal=MQTT_PASSWORD=mypassword
```

Install referencing the secret:

```yaml
existingSecret: "broadlink-mqtt-creds"
secretKeys:
  mqttUser: "MQTT_USER"
  mqttPassword: "MQTT_PASSWORD"

config:
  mqtt:
    server: "tcp://mqtt.home.lan:1883"
    # user and password will be read from secret
  devices:
    - ip: "192.168.1.100"
      mac: "AA:BB:CC:DD:EE:FF"
      name: "Living Room AC"
```

## Configuration

### Service Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.service.update_interval` | Seconds between device polls | `10` |
| `config.service.log_level` | Log level (debug/info/error/disabled) | `info` |

### MQTT Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `config.mqtt.server` | MQTT broker URL | `tcp://mqtt-broker:1883` |
| `config.mqtt.user` | MQTT username | `""` |
| `config.mqtt.password` | MQTT password | `""` |
| `config.mqtt.client_id` | MQTT client ID | `broadlinkac2mqtt` |
| `config.mqtt.discovery` | Enable Home Assistant discovery | `true` |
| `config.mqtt.discovery_prefix` | HA discovery prefix | `homeassistant` |
| `config.mqtt.topic_prefix` | Base topic prefix | `broadlinkac2mqtt` |

### Device Configuration

Each device requires:

- `ip`: Device IP address (required)
- `mac`: Device MAC address in format AA:BB:CC:DD:EE:FF (required)
- `name`: Friendly name for the device (required)
- `port`: Device port (optional, default: 80)
- `temp_unit`: Temperature unit "C" or "F" (optional, default: C)

### Resource Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `resources.requests.cpu` | CPU request | `50m` |
| `resources.requests.memory` | Memory request | `64Mi` |
| `resources.limits.cpu` | CPU limit | `200m` |
| `resources.limits.memory` | Memory limit | `256Mi` |

## Health Checks

The chart includes comprehensive health checks:

- **Startup Probe**: Allows 60 seconds for MQTT connection and device authentication
- **Liveness Probe**: Verifies the main process is running every 30 seconds
- **Readiness Probe**: Checks config file presence and process health every 15 seconds

All probes use process-based checks since the application doesn't expose HTTP endpoints.

## Home Assistant Integration

When `config.mqtt.discovery` is enabled, devices automatically appear in Home Assistant as climate entities. The integration supports:

- Power on/off
- Mode selection (cool, heat, auto, fan, dry)
- Temperature setpoint
- Fan speed control
- Swing mode control

## Troubleshooting

### Check pod status

```bash
kubectl get pods -l app=broadlinkac2mqtt
kubectl logs -l app=broadlinkac2mqtt
```

### Verify configuration

```bash
kubectl get configmap broadlinkac2mqtt-config -o yaml
```

### Common Issues

1. **Pod won't start**: Check MQTT broker connectivity
2. **Devices not discovered**: Verify IP addresses and MAC addresses are correct
3. **Connection timeouts**: Ensure devices are on the same network segment
4. **MQTT authentication failed**: Verify credentials in secret or config

## Version Management

The chart includes version tracking annotations compatible with automated version checking tools:

```yaml
annotations:
  version-source: github-release:ArtemVladimirov/broadlinkac2mqtt
  version-pattern: "s|^v||"
```

Check for updates:
```bash
# Using just (if in k3s repo)
just app check broadlinkac2mqtt

# Or manually check releases
curl -s https://api.github.com/repos/ArtemVladimirov/broadlinkac2mqtt/releases/latest | jq -r .tag_name
```

## Upgrading

Update the chart version:

```bash
helm upgrade broadlinkac2mqtt ./broadlinkac2mqtt -f values-custom.yaml
```

## Uninstalling

```bash
helm uninstall broadlinkac2mqtt
```

## Notes

- This is an MQTT-only application with no HTTP interface
- Only one replica should run to avoid conflicting device commands
- The application uses environment variable substitution for secrets in config.yml
- Config changes require pod restart to take effect
