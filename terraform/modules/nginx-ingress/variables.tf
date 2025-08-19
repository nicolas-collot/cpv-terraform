variable "replica_count" {
  description = "Number of Nginx Ingress replicas"
  type        = number
  default     = 1
}

variable "max_replicas" {
  description = "Maximum number of replicas for auto-scaling"
  type        = number
  default     = 5
}

variable "enable_autoscaling" {
  description = "Enable auto-scaling for Nginx Ingress"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
