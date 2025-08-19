variable "environment" {
  description = "Environment name"
  type        = string
}

variable "monitoring_domain" {
  description = "Domain name for monitoring services"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
}

variable "prometheus_storage_size" {
  description = "Prometheus storage size"
  type        = string
  default     = "20Gi"
}

variable "grafana_storage_size" {
  description = "Grafana storage size"
  type        = string
  default     = "5Gi"
}

variable "alertmanager_storage_size" {
  description = "AlertManager storage size"
  type        = string
  default     = "5Gi"
}

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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
