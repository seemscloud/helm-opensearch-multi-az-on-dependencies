{{- define "observability-opensearch.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "observability-opensearch.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "observability-opensearch.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "observability-opensearch.labels" -}}
helm.sh/chart: {{ include "observability-opensearch.chart" . }}
{{ include "observability-opensearch.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "observability-opensearch.selectorLabels" -}}
app.kubernetes.io/name: {{ include "observability-opensearch.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{- define "observability-opensearch.dockerRegistry" -}}
{{- if eq .Values.global.dockerRegistry "" -}}
  {{- .Values.global.dockerRegistry -}}
{{- else -}}
  {{- .Values.global.dockerRegistry | trimSuffix "/" | printf "%s/" -}}
{{- end -}}
{{- end -}}