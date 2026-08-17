{{- define "tfa.middlewareName" -}}
{{- if .Values.middleware.name -}}
{{ .Values.middleware.name }}
{{- else -}}
{{ .Release.Name }}-auth
{{- end -}}
{{- end -}}

{{- define "tfa.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end -}}

{{/*
  The portals, normalised to one shape.

  A portal is a set of identity providers with its own OAuth2 client, and the
  middleware address is what selects it — so two portals means two clients, and
  therefore two Pocket ID applications that can be granted to different people.

  `portals` is the general form. The older single-portal values (`portal.name`,
  `pocketID`, `existingSecret`, `middleware.name`) still work and are folded into
  the same shape here, so an existing release keeps rendering exactly as before.
*/}}
{{- define "tfa.portals" -}}
{{- if .Values.portals -}}
{{- range .Values.portals }}
- name: {{ .name | quote }}
  endpoint: {{ .pocketID.endpoint | quote }}
  clientID: {{ .pocketID.clientID | quote }}
  existingSecret: {{ required "each portal needs an existingSecret" .existingSecret | quote }}
  secretKey: {{ .secretKey | default "client-secret" | quote }}
  middlewareName: {{ .middlewareName | default (printf "%s-%s" $.Release.Name .name) | quote }}
{{- end }}
{{- else -}}
- name: {{ .Values.portal.name | quote }}
  endpoint: {{ .Values.pocketID.endpoint | quote }}
  clientID: {{ .Values.pocketID.clientID | quote }}
  existingSecret: {{ required "existingSecret is required" .Values.existingSecret | quote }}
  secretKey: "client-secret"
  middlewareName: {{ include "tfa.middlewareName" . | quote }}
{{- end -}}
{{- end -}}

{{/*
  The domains served, normalised.

  `domain` is the cookie's scope and `authHost` is where this service is reachable
  for it. A browser will not send a cookie scoped to one registrable domain to a
  host under another, so an app on a second domain needs its own entry here — not
  merely a second client.
*/}}
{{- define "tfa.domains" -}}
{{- if .Values.domains -}}
{{- range .Values.domains }}
- domain: {{ .domain | quote }}
  authHost: {{ .authHost | default .domain | quote }}
{{- end }}
{{- else -}}
- domain: {{ required "cookieDomain is required when `domains` is not set" .Values.cookieDomain | quote }}
  authHost: {{ required "hostname is required when `domains` is not set" .Values.hostname | quote }}
{{- end -}}
{{- end -}}

{{/* Where a portal's client secret is mounted. */}}
{{- define "tfa.secretDir" -}}
/var/run/secrets/traefik-forward-auth
{{- end -}}
