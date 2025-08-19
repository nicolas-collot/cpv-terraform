# Essential configuration
variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config-pergament"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
  default     = "camps-shared-cluster"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

# Domain configuration
variable "application_domain" {
  description = "Application domain"
  type        = string
  default     = "camps.ch"
}

variable "monitoring_domain" {
  description = "Monitoring domain"
  type        = string
  default     = "monitoring.camps.ch"
}

# SSL configuration
variable "letsencrypt_email" {
  description = "Email for Let's Encrypt certificates"
  type        = string
  default     = "admin@camps.ch"
}

# Monitoring configuration
variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin123"
}

# Common tags
variable "common_tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default = {
    Project     = "camps-ch"
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
