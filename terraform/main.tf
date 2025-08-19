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
  
  depends_on = var.enable_storage ? [module.longhorn[0]] : []
  
  tags = var.common_tags
}

# SSL Certificate Management
module "cert_manager" {
  count  = var.enable_ssl ? 1 : 0
  source = "./modules/cert-manager"
  
  replica_count = var.cert_manager_replicas
  letsencrypt_email = var.letsencrypt_email
  
  depends_on = var.enable_ingress ? [module.nginx_ingress[0]] : []
  
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
  
  depends_on = concat(
    var.enable_storage ? [module.longhorn[0]] : [],
    var.enable_ssl ? [module.cert_manager[0]] : []
  )
  
  tags = var.common_tags
}




