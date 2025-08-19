output "namespace" {
  description = "cert-manager namespace"
  value       = kubernetes_namespace.cert_manager.metadata[0].name
}

output "cluster_issuer_prod" {
  description = "Production ClusterIssuer name"
  value       = "letsencrypt-prod"
}

output "cluster_issuer_staging" {
  description = "Staging ClusterIssuer name"
  value       = "letsencrypt-staging"
}

output "cert_manager_version" {
  description = "Installed cert-manager version"
  value       = var.cert_manager_version
}
