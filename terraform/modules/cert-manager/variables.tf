variable "replica_count" {
  description = "Number of cert-manager replicas"
  type        = number
  default     = 1
}

variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
