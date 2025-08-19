# Storage - Longhorn
module "longhorn" {
  count  = var.enable_storage ? 1 : 0
  source = "./modules/longhorn"
  
  replica_count = var.longhorn_replica_count
  
  tags = var.common_tags
}

# Ingress Controller
module "nginx_ingress" {
  count  = var.enable_ingress ? 1 : 0
  source = "./modules/nginx-ingress"
  
  replica_count = var.nginx_ingress_replicas
  max_replicas  = var.nginx_ingress_max_replicas
  enable_autoscaling = var.nginx_ingress_enable_autoscaling
  
  depends_on = [module.longhorn]
  
  tags = var.common_tags
}

# SSL Certificate Management
module "cert_manager" {
  count  = var.enable_ssl ? 1 : 0
  source = "./modules/cert-manager"
  
  cert_manager_version = var.cert_manager_version
  letsencrypt_email = var.letsencrypt_email
  cert_issuer_staging = var.cert_issuer_staging
  cert_issuer_prod = var.cert_issuer_prod
  ingress_class = var.ingress_class
  enable_monitoring = var.enable_monitoring
  node_selector = var.node_selector
  
  depends_on = [module.nginx_ingress]
  
  tags = var.common_tags
}

# Monitoring Stack
module "prometheus" {
  count  = var.enable_monitoring ? 1 : 0
  source = "./modules/prometheus"
  
  environment            = var.environment
  monitoring_domain      = var.monitoring_domain
  grafana_admin_password = var.grafana_admin_password
  prometheus_storage_size = var.prometheus_storage_size
  prometheus_replicas    = var.prometheus_replicas
  grafana_replicas       = var.grafana_replicas
  alertmanager_replicas  = var.alertmanager_replicas
  
  depends_on = [
    module.longhorn,
    module.cert_manager
  ]
  
  tags = var.common_tags
}




