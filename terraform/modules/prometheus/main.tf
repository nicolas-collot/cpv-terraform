# Prometheus monitoring stack
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "55.5.0"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
  timeout = 600
  
  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "7d"
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "longhorn"
                resources = {
                  requests = {
                    storage = "20Gi"
                  }
                }
              }
            }
          }
          resources = {
            limits = {
              cpu = "500m"
              memory = "1Gi"
            }
            requests = {
              cpu = "250m"
              memory = "512Mi"
            }
          }
        }
      }
      
      grafana = {
        adminPassword = var.grafana_admin_password
        
        persistence = {
          enabled = true
          storageClassName = "longhorn"
          size = "5Gi"
        }
        
        resources = {
          limits = {
            cpu = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu = "100m"
            memory = "128Mi"
          }
        }
        
        ingress = {
          enabled = true
          ingressClassName = "nginx"
          hosts = [var.monitoring_domain]
          tls = [{
            secretName = "grafana-tls"
            hosts = [var.monitoring_domain]
          }]
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
          }
        }
      }
      
      alertmanager = {
        alertmanagerSpec = {
          retention = "24h"
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "longhorn"
                resources = {
                  requests = {
                    storage = "5Gi"
                  }
                }
              }
            }
          }
          resources = {
            limits = {
              cpu = "100m"
              memory = "128Mi"
            }
            requests = {
              cpu = "50m"
              memory = "64Mi"
            }
          }
        }
      }
    })
  ]
  
  depends_on = [kubernetes_namespace.monitoring]
}

