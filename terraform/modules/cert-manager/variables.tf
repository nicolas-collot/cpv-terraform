variable "letsencrypt_email" {
  description = "Email address for Let's Encrypt"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
