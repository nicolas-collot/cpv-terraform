output "namespace" {
  description = "Longhorn namespace"
  value       = kubernetes_namespace.longhorn_system.metadata[0].name
}

output "default_storage_class" {
  description = "Default storage class name"
  value       = "longhorn"
}

output "storage_classes" {
  description = "Available storage classes"
  value = [
    "longhorn"
  ]
}

output "ui_service_name" {
  description = "Longhorn UI service name"
  value       = "${helm_release.longhorn.name}-frontend"
}
