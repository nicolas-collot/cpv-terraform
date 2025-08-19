variable "environment" {
  description = "Environment name"
  type        = string
}

variable "monitoring_domain" {
  description = "Domain for monitoring services"
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
