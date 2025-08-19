# Storage - Longhorn
module "longhorn" {
  source = "./modules/longhorn"
  tags   = var.common_tags
}

# Ingress Controller
module "nginx_ingress" {
  source = "./modules/nginx-ingress"
  tags   = var.common_tags
}

# SSL Certificate Management
module "cert_manager" {
  source = "./modules/cert-manager"
  
  letsencrypt_email = var.letsencrypt_email
  tags              = var.common_tags
}

# Monitoring Stack
module "prometheus" {
  source = "./modules/prometheus"
  
  environment            = var.environment
  monitoring_domain      = var.monitoring_domain
  grafana_admin_password = var.grafana_admin_password
  tags                   = var.common_tags
}




