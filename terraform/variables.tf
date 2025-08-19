# Global variables
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config-camps"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "camps-shared-cluster"
}

# Domain variables for each service
variable "monitoring_domain" {
  description = "Domain for monitoring services (Grafana, Prometheus)"
  type        = string
  default     = "monitoring.camps.ch"
}

variable "application_domain" {
  description = "Domain for main application"
  type        = string
  default     = "camps.ch"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# Storage variables
variable "longhorn_replica_count" {
  description = "Number of replicas for Longhorn storage"
  type        = number
  default     = 1
}

# Ingress variables
variable "nginx_ingress_replicas" {
  description = "Number of Nginx Ingress replicas"
  type        = number
  default     = 1
}

variable "nginx_ingress_max_replicas" {
  description = "Maximum number of Nginx Ingress replicas for auto-scaling"
  type        = number
  default     = 5
}

variable "nginx_ingress_enable_autoscaling" {
  description = "Enable auto-scaling for Nginx Ingress"
  type        = bool
  default     = false
}

# Monitoring variables
variable "prometheus_replicas" {
  description = "Number of Prometheus replicas"
  type        = number
  default     = 1
}

variable "grafana_replicas" {
  description = "Number of Grafana replicas"
  type        = number
  default     = 1
}

variable "alertmanager_replicas" {
  description = "Number of AlertManager replicas"
  type        = number
  default     = 1
}

variable "cert_manager_replicas" {
  description = "Number of cert-manager replicas"
  type        = number
  default     = 1
}

# Resource customization
variable "enable_monitoring" {
  description = "Enable monitoring stack (Prometheus, Grafana, AlertManager)"
  type        = bool
  default     = true
}

variable "enable_ingress" {
  description = "Enable Nginx Ingress Controller"
  type        = bool
  default     = true
}

variable "enable_storage" {
  description = "Enable Longhorn storage"
  type        = bool
  default     = true
}

variable "enable_ssl" {
  description = "Enable cert-manager for SSL certificates"
  type        = bool
  default     = true
}

# Resource customization - CPU and Memory
variable "nginx_ingress_cpu_limit" {
  description = "Nginx Ingress CPU limit"
  type        = string
  default     = "500m"
}

variable "nginx_ingress_memory_limit" {
  description = "Nginx Ingress memory limit"
  type        = string
  default     = "512Mi"
}

variable "nginx_ingress_cpu_request" {
  description = "Nginx Ingress CPU request"
  type        = string
  default     = "100m"
}

variable "nginx_ingress_memory_request" {
  description = "Nginx Ingress memory request"
  type        = string
  default     = "128Mi"
}

variable "prometheus_cpu_limit" {
  description = "Prometheus CPU limit"
  type        = string
  default     = "500m"
}

variable "prometheus_memory_limit" {
  description = "Prometheus memory limit"
  type        = string
  default     = "1Gi"
}

variable "prometheus_cpu_request" {
  description = "Prometheus CPU request"
  type        = string
  default     = "250m"
}

variable "prometheus_memory_request" {
  description = "Prometheus memory request"
  type        = string
  default     = "512Mi"
}

variable "grafana_cpu_limit" {
  description = "Grafana CPU limit"
  type        = string
  default     = "500m"
}

variable "grafana_memory_limit" {
  description = "Grafana memory limit"
  type        = string
  default     = "512Mi"
}

variable "grafana_cpu_request" {
  description = "Grafana CPU request"
  type        = string
  default     = "100m"
}

variable "grafana_memory_request" {
  description = "Grafana memory request"
  type        = string
  default     = "128Mi"
}

variable "alertmanager_cpu_limit" {
  description = "AlertManager CPU limit"
  type        = string
  default     = "100m"
}

variable "alertmanager_memory_limit" {
  description = "AlertManager memory limit"
  type        = string
  default     = "128Mi"
}

variable "alertmanager_cpu_request" {
  description = "AlertManager CPU request"
  type        = string
  default     = "50m"
}

variable "alertmanager_memory_request" {
  description = "AlertManager memory request"
  type        = string
  default     = "64Mi"
}

# Monitoring variables
variable "prometheus_storage_size" {
  description = "Prometheus storage size"
  type        = string
  default     = "20Gi"
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

# SSL variables
variable "letsencrypt_email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
}

# Tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "camps-ch"
    ManagedBy   = "terraform"
    Environment = "production"
  }
}
