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
