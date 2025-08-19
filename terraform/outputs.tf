# LoadBalancer outputs
output "loadbalancer_ip" {
  description = "LoadBalancer external IP"
  value       = var.enable_ingress ? module.nginx_ingress[0].loadbalancer_ip : null
}

# Application URLs
output "application_urls" {
  description = "Application URLs"
  value = {
    application = "https://${var.application_domain}"
    monitoring  = "https://${var.monitoring_domain}"
  }
}



# Storage classes
output "storage_classes" {
  description = "Available storage classes"
  value       = var.enable_storage ? module.longhorn[0].storage_classes : []
}

# Monitoring access
output "monitoring_info" {
  description = "Monitoring access information"
  value = var.enable_monitoring ? {
    grafana_url      = "https://${var.monitoring_domain}"
    grafana_username = "admin"
    prometheus_url   = "http://prometheus.monitoring.svc.cluster.local:9090"
  } : null
}
