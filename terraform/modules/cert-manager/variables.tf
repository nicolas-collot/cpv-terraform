variable "cert_manager_version" {
  description = "Cert-manager Helm chart version"
  type        = string
  default     = "1.13.2"
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt"
  type        = string
}

variable "cert_issuer_staging" {
  description = "Name for Let's Encrypt staging ClusterIssuer"
  type        = string
  default     = "letsencrypt-staging"
}

variable "cert_issuer_prod" {
  description = "Name for Let's Encrypt production ClusterIssuer"
  type        = string
  default     = "letsencrypt-prod"
}

variable "ingress_class" {
  description = "Ingress class for cert-manager HTTP01 challenges"
  type        = string
  default     = "nginx"
}

variable "enable_monitoring" {
  description = "Enable monitoring for cert-manager"
  type        = bool
  default     = true
}

variable "node_selector" {
  description = "Node selector for cert-manager pods"
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
