# Monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name = "monitoring"
    }
  }
}

# Prometheus Stack using kube-prometheus-stack
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "54.2.2"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  
  timeout = 600
  
  values = [
    yamlencode({
      fullnameOverride = "prometheus"
      
      alertmanager = {
        enabled = true
        
        alertmanagerSpec = {
          replicas = var.alertmanager_replicas
          storage = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "longhorn"
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.alertmanager_storage_size
                  }
                }
              }
            }
          }
          
          resources = {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
        
        config = {
          global = {
            smtp_smarthost = "localhost:587"
            smtp_from = "alertmanager@${var.monitoring_domain}"
          }
          
          route = {
            group_by = ["alertname"]
            group_wait = "10s"
            group_interval = "10s"
            repeat_interval = "1h"
            receiver = "web.hook"
          }
          
          receivers = [
            {
              name = "web.hook"
              webhook_configs = [
                {
                  url = "http://127.0.0.1:5001/"
                }
              ]
            }
          ]
        }
      }
      
      grafana = {
        enabled = true
        
        replicas = var.grafana_replicas
        adminPassword = var.grafana_admin_password
        
        ingress = {
          enabled = true
          ingressClassName = "nginx"
          hosts = ["${var.monitoring_domain}"]
          annotations = {
            "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
            "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
          }
          tls = [
            {
              secretName = "monitoring-tls"
              hosts = ["${var.monitoring_domain}"]
            }
          ]
        }
        
        persistence = {
          enabled = true
          storageClassName = "longhorn"
          size = var.grafana_storage_size
        }
        
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
        
        dashboardProviders = {
          "dashboardproviders.yaml" = {
            apiVersion = 1
            providers = [
              {
                name = "default"
                orgId = 1
                folder = ""
                type = "file"
                disableDeletion = false
                editable = true
                options = {
                  path = "/var/lib/grafana/dashboards/default"
                }
              }
            ]
          }
        }
        
        dashboards = {
          default = {
            "kubernetes-cluster-monitoring" = {
              gnetId = 7249
              revision = 1
              datasource = "Prometheus"
            }
            "kubernetes-pod-monitoring" = {
              gnetId = 6417
              revision = 1
              datasource = "Prometheus"
            }
            "node-exporter-full" = {
              gnetId = 1860
              revision = 27
              datasource = "Prometheus"
            }
            "nginx-ingress-controller" = {
              gnetId = 9614
              revision = 1
              datasource = "Prometheus"
            }
          }
        }
      }
      
      prometheus = {
        enabled = true
        
        prometheusSpec = {
          replicas = var.prometheus_replicas
          retention = "30d"
          retentionSize = "15GB"
          
          storageSpec = {
            volumeClaimTemplate = {
              spec = {
                storageClassName = "longhorn"
                accessModes = ["ReadWriteOnce"]
                resources = {
                  requests = {
                    storage = var.prometheus_storage_size
                  }
                }
              }
            }
          }
          
          resources = {
            limits = {
              cpu    = "2000m"
              memory = "4Gi"
            }
            requests = {
              cpu    = "1000m"
              memory = "2Gi"
            }
          }
          
          serviceMonitorSelectorNilUsesHelmValues = false
          podMonitorSelectorNilUsesHelmValues = false
          ruleSelectorNilUsesHelmValues = false
          
          additionalScrapeConfigs = []
        }
        
        ingress = {
          enabled = false  # Access via Grafana or port-forward
        }
      }
      
      prometheusOperator = {
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "250m"
            memory = "256Mi"
          }
        }
      }
      
      kubeStateMetrics = {
        enabled = true
      }
      
      nodeExporter = {
        enabled = true
      }
      
      kubeApiServer = {
        enabled = true
      }
      
      kubelet = {
        enabled = true
        serviceMonitor = {
          cAdvisorMetricRelabelings = [
            {
              sourceLabels = ["__name__"]
              regex = "(container_cpu_usage_seconds_total|container_memory_working_set_bytes|container_fs_usage_bytes|container_fs_limit_bytes)"
              action = "keep"
            }
          ]
        }
      }
      
      kubeControllerManager = {
        enabled = false  # Not accessible in managed clusters
      }
      
      kubeEtcd = {
        enabled = false  # Not accessible in managed clusters
      }
      
      kubeScheduler = {
        enabled = false  # Not accessible in managed clusters
      }
      
      kubeProxy = {
        enabled = false  # Not accessible in managed clusters
      }
      
      coreDns = {
        enabled = true
      }
      
      kubeDns = {
        enabled = false
      }
    })
  ]
  
  depends_on = [kubernetes_namespace.monitoring]
}
