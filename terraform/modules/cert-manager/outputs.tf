output "namespace" {
  description = "cert-manager namespace"
  value       = kubernetes_namespace.cert_manager.metadata[0].name
}

output "cluster_issuer_prod" {
  description = "Production ClusterIssuer name"
  value       = kubernetes_manifest.letsencrypt_issuer.manifest.metadata.name
}

output "cluster_issuer_staging" {
  description = "Staging ClusterIssuer name"
  value       = kubernetes_manifest.letsencrypt_staging_issuer.manifest.metadata.name
}
