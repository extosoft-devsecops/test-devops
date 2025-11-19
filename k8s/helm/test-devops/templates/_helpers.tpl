{{- define "fullname" -}}
{{ .Chart.Name }}-{{ .Values.app.name }}
{{- end }}