{{- define "common.tplvalues.render" -}}
{{- if .scope }}
  {{- if typeIs "string" .value }}
    {{- tpl (cat "{{- with $.RelativeScope -}}" .value  "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- else }}
    {{- tpl (cat "{{- with $.RelativeScope -}}" (.value | toYaml)  "{{- end }}") (merge (dict "RelativeScope" .scope) .context) }}
  {{- end }}
{{- else }}
  {{- if typeIs "string" .value }}
    {{- tpl .value .context }}
  {{- else }}
    {{- tpl (.value | toYaml) .context }}
  {{- end }}
{{- end -}}
{{- end -}}


{{/* 获取 Horizontal Pod Autoscaler apiVersion版本 */}}

{{- define "common.capabilities.hpa.apiVersion" -}}
{{- if semverCompare "<1.23-0" (include "common.capabilities.kubeVersion" .context) -}}
{{- if .beta2 -}}
{{- print "autoscaling/v2beta2" -}}
{{- else -}}
{{- print "autoscaling/v2beta1" -}}
{{- end -}}
{{- else -}}
{{- print "autoscaling/v2" -}}
{{- end -}}
{{- end -}}

{{/* 获取 Kubernetes 版本 */}}
{{- define "common.capabilities.kubeVersion" -}}
{{- default .Capabilities.KubeVersion.Version .Values.kubeVersion -}}
{{- end -}}