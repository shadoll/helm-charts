{{/* PVC name to mount: existing claim if set, otherwise the chart-created one */}}
{{- define "pocket-id.pvcName" -}}
{{- if .Values.persistence.existingClaim -}}
{{ .Values.persistence.existingClaim }}
{{- else -}}
{{ .Release.Name }}-data
{{- end -}}
{{- end -}}
