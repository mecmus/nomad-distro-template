{{/*
Expand the name of the chart.
*/}}
{{- define "nomad-oasis.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "nomad-oasis.fullname" -}}
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

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "nomad-oasis.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "nomad-oasis.labels" -}}
helm.sh/chart: {{ include "nomad-oasis.chart" . }}
{{ include "nomad-oasis.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "nomad-oasis.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nomad-oasis.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "nomad-oasis.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nomad-oasis.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Generate API secret
*/}}
{{- define "nomad-oasis.apiSecret" -}}
{{- if .Values.nomad.apiSecret }}
{{- .Values.nomad.apiSecret }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

{{/*
Generate JupyterHub crypt key
*/}}
{{- define "nomad-oasis.jupyterhubCryptKey" -}}
{{- if .Values.north.jupyterhubCryptKey }}
{{- .Values.north.jupyterhubCryptKey }}
{{- else }}
{{- randAlphaNum 64 }}
{{- end }}
{{- end }}

{{/*
Generate RabbitMQ password
*/}}
{{- define "nomad-oasis.rabbitmqPassword" -}}
{{- if .Values.rabbitmq.auth.password }}
{{- .Values.rabbitmq.auth.password }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

{{/*
Get the image registry
*/}}
{{- define "nomad-oasis.imageRegistry" -}}
{{- if .Values.global.imageRegistry }}
{{- .Values.global.imageRegistry }}
{{- else }}
{{- "ghcr.io" }}
{{- end }}
{{- end }}
