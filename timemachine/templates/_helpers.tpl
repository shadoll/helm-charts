{{/*
Expand the name of the chart.
*/}}
{{- define "timemachine.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "timemachine.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "timemachine.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "timemachine.labels" -}}
helm.sh/chart: {{ include "timemachine.chart" . }}
{{ include "timemachine.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "timemachine.selectorLabels" -}}
app.kubernetes.io/name: {{ include "timemachine.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Render extraShares as the comma-separated EXTRA_SHARES env value
(format expected by the image: "name1:/path1,name2:/path2").
*/}}
{{- define "timemachine.extraShares" -}}
{{- $parts := list -}}
{{- range .Values.extraShares -}}
{{- $parts = append $parts (printf "%s:%s" .name .mountPath) -}}
{{- end -}}
{{- join "," $parts -}}
{{- end -}}
