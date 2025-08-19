output "namespace" {
  description = "Nginx Ingress namespace"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

output "loadbalancer_ip" {
  description = "LoadBalancer external IP"
  value       = length(data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress) > 0 ? data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].ip : null
}

output "service_name" {
  description = "Nginx Ingress controller service name"
  value       = data.kubernetes_service.nginx_ingress.metadata[0].name
}
