{{/*
Common labels
*/}}
{{- define "frigate.labels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/component: nvr
app.kubernetes.io/part-of: home-automation
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "frigate.selectorLabels" -}}
app: {{ .Release.Name }}
{{- end -}}
