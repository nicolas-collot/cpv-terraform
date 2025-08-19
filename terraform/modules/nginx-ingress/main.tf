# Nginx Ingress Controller
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      name = "ingress-nginx"
    }
  }
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  
  timeout = 600
  
  values = [
    yamlencode({
      controller = {
        replicaCount = var.replica_count
        
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/infomaniak-load-balancer-proxy-protocol" = "true"
          }
          externalTrafficPolicy = "Local"
        }
        
        config = {
          "use-proxy-protocol" = "true"
          "real-ip-header" = "proxy_protocol"
          "set-real-ip-from" = "0.0.0.0/0"
          "proxy-body-size" = "100m"
          "proxy-connect-timeout" = "15"
          "proxy-send-timeout" = "600"
          "proxy-read-timeout" = "600"
          "proxy-buffers-number" = "4"
          "proxy-buffer-size" = "32k"
          "ssl-protocols" = "TLSv1.2 TLSv1.3"
          "ssl-ciphers" = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384"
          "ssl-prefer-server-ciphers" = "true"
          "enable-brotli" = "true"
        }
        
        metrics = {
          enabled = true
          serviceMonitor = {
            enabled = true
            additionalLabels = {
              release = "prometheus"
            }
          }
        }
        
        resources = {
          limits = {
            cpu = "2000m"
            memory = "2Gi"
          }
          requests = {
            cpu = "500m"
            memory = "512Mi"
          }
        }
        
        autoscaling = {
          enabled = var.enable_autoscaling
          minReplicas = var.replica_count
          maxReplicas = var.max_replicas
          targetCPUUtilizationPercentage = 70
          targetMemoryUtilizationPercentage = 70
        }
        
        nodeSelector = {}
        tolerations = []
        affinity = {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [
              {
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [
                      {
                        key = "app.kubernetes.io/name"
                        operator = "In"
                        values = ["ingress-nginx"]
                      }
                    ]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }
            ]
          }
        }
      }
      
      defaultBackend = {
        enabled = true
        replicaCount = 1
        
        resources = {
          limits = {
            cpu = "10m"
            memory = "20Mi"
          }
          requests = {
            cpu = "10m"
            memory = "20Mi"
          }
        }
      }
    })
  ]
  
  depends_on = [kubernetes_namespace.ingress_nginx]
}

# Wait for LoadBalancer to get external IP
resource "time_sleep" "wait_for_lb" {
  depends_on = [helm_release.nginx_ingress]
  create_duration = "60s"
}

# Get LoadBalancer IP
data "kubernetes_service" "nginx_ingress" {
  depends_on = [time_sleep.wait_for_lb]
  
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace.ingress_nginx.metadata[0].name
  }
}
