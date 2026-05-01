{{- define "serviceAccountName" -}}
{{- if .Values.serviceAccount.name }}
{{- .Values.serviceAccount.name }}
{{- else }}
{{- .Values.app.name }}-sa
{{- end }}
{{- end }}
