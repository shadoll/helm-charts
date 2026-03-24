# Home Assistant Helm Chart — Issues & Improvements

## Defaults & Best Practices

- [ ] **`hostNetwork: true` should default to `false`**
  `hostNetwork` is only needed for HomeKit/mDNS discovery on the LAN. A clean install should not claim the host network by default. Users who need it can opt in via values.
  File: `values.yaml` line 12, `deployment.yaml` lines 24-27

- [ ] **HomeKit should default to disabled**
  HomeKit is a specific integration, not a core feature. Default `homekit.enabled: false` and let users enable it when needed. Currently exposes port 21063 on every install.
  File: `values.yaml` lines 16-18, `deployment.yaml` lines 105-109

- [ ] **Timezone should default to `UTC`**
  Currently hardcoded to `Europe/Kyiv`. Chart defaults should be locale-neutral. Users override via values for their deployment.
  File: `values.yaml` line 14

- [ ] **Resource limits too high for default**
  CPU limit of 8 cores is excessive for a default install. Consider `cpu: 2` / `memory: 2Gi` as default limits, with `cpu: 100m` / `memory: 256Mi` as requests. Production users can increase as needed.
  File: `values.yaml` lines 40-46

- [ ] **`imagePullPolicy: Always` should be `IfNotPresent`**
  For tagged images (not `latest`), `IfNotPresent` is the Kubernetes convention. `Always` causes unnecessary image pulls on every pod restart.
  File: `values.yaml` line 5, `deployment.yaml` line 93

## Security

- [ ] **No `securityContext` defined**
  The deployment has no pod or container security context. Should add at minimum:
  ```yaml
  securityContext:
    runAsNonRoot: false  # HA needs root for s6 init
    # But container-level:
    allowPrivilegeEscalation: false
    capabilities:
      drop: [ALL]
      add: [NET_BIND_SERVICE]  # if needed for homekit
  ```
  Note: Home Assistant uses s6-overlay which requires root. Full non-root may not be feasible, but `capabilities` should still be restricted.
  File: `deployment.yaml`

- [ ] **No `ServiceAccount` created**
  Chart should create a dedicated ServiceAccount with `automountServiceAccountToken: false` (HA doesn't need Kubernetes API access). This follows the principle of least privilege.
  Files: new `templates/serviceaccount.yaml`, `deployment.yaml`

## Reliability

- [ ] **No liveness/readiness probes**
  HA exposes HTTP on port 8123. The chart should define probes:
  ```yaml
  livenessProbe:
    httpGet:
      path: /
      port: 8123
    initialDelaySeconds: 60
    periodSeconds: 30
    failureThreshold: 5
  readinessProbe:
    httpGet:
      path: /
      port: 8123
    initialDelaySeconds: 30
    periodSeconds: 10
  ```
  `initialDelaySeconds` should be generous — HA can take 30-90s to start depending on integrations. Consider making these configurable via values.
  File: `deployment.yaml`

## Code Quality

- [ ] **`busybox:latest` in init containers**
  Init containers (`init-config`, `init-secrets`, `init-recorder`) use `busybox:latest` which is unpinned and not reproducible. Pin to a specific version, e.g. `busybox:1.37` and make it configurable via values.
  File: `deployment.yaml` lines 31, 43, 63

- [ ] **`version-source` annotation in deployment template**
  The `version-source: github-release:home-assistant/core` annotation is for the `just app` CLI tooling in the k3s repo, not a chart concern. Should be removed from the template and added via HelmRelease annotations or values.
  File: `deployment.yaml` lines 8-9

## Future Enhancements

- [ ] **Auto-generate `http.yaml` from chart values**
  Same pattern as the recorder init container — generate `/config/http.yaml` and add `http: !include http.yaml` to `configuration.yaml`. This simplifies initial setup since `trusted_proxies` is required for Traefik/ingress to work and the values can be derived from the Kubernetes environment.
  Generated file example:
  ```yaml
  server_port: 8123
  use_x_forwarded_for: true
  trusted_proxies:
    - 10.42.0.0/16   # k8s pod CIDR (Traefik)
    - 10.43.0.0/16   # k8s service CIDR
  ```
  Values structure:
  ```yaml
  http:
    enabled: false
    port: 8123
    useXForwardedFor: true
    trustedProxies: []
      # - 10.42.0.0/16
      # - 10.43.0.0/16
  ```
  File: `values.yaml`, `deployment.yaml` (new init container)

- [ ] **S3 backup support**
  Add optional S3 sync as a post-backup step in the CronJob. Write locally to PVC first (fast restore), then push to S3 for disaster recovery. Values structure:
  ```yaml
  backup:
    s3:
      enabled: false
      endpoint: ""
      bucket: ""
      existingSecret: ""
  ```

- [ ] **NOTES.txt for post-install instructions**
  Add `templates/NOTES.txt` to display useful info after install (URLs, first-time setup steps, how to access HA).

- [ ] **Support `topologySpreadConstraints`**
  For multi-node clusters, allow configuring topology spread via values (though HA is typically single-replica).
