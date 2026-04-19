{{- define "ntfy.configMapName" -}}
{{- if .Values.existingConfigMap -}}
{{ .Values.existingConfigMap }}
{{- else -}}
{{ .Release.Name }}-config
{{- end -}}
{{- end -}}
