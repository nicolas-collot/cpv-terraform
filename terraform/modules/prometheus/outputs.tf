output "namespace" {
  description = "Monitoring namespace"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "grafana_url" {
  description = "Grafana URL"
  value       = "https://${var.monitoring_domain}"
}

output "grafana_admin_username" {
  description = "Grafana admin username"
  value       = "admin"
}

output "prometheus_url" {
  description = "Prometheus internal URL"
  value       = "http://prometheus-prometheus:9090"
}

output "alertmanager_url" {
  description = "AlertManager internal URL"
  value       = "http://prometheus-alertmanager:9093"
}
