# probara

Copy of the upstream Helm chart `helm/monitoring-platform` from
[yassinebenameur/probara](https://github.com/yassinebenameur/probara) at `v1.0.0`
(AGPL-3.0, see `LICENSE`), kept here so `scripts/update-charts.sh` can track new
releases.

Changes against upstream:

- `Chart.yaml`: `version-source` / `version-pattern` annotations for the update script.
- Image tags default to `Chart.AppVersion` (`image.tag` and `frontend.image.tag` are empty by default,
  upstream defaults to `latest`).

To take an upstream chart change, copy `helm/monitoring-platform/templates` and `values.yaml` again
and re-apply the two changes above.

For a worker-only install in another cluster, use the `probara-worker` chart.
