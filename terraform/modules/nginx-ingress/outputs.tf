output "namespace" {
  description = "Nginx Ingress namespace"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "loadbalancer_ip" {
  description = "LoadBalancer external IP"
  value       = helm_release.ingress_nginx.name
}

output "service_name" {
  description = "Nginx Ingress controller service name"
  value       = data.kubernetes_service.nginx_ingress.metadata[0].name
}
