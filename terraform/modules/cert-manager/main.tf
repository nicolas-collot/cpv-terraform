# cert-manager for SSL certificates
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      name = "cert-manager"
      "cert-manager.io/disable-validation" = "true"
    }
  }
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.13.2"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  
  timeout = 600
  
  set {
    name  = "installCRDs"
    value = "true"
  }
  
  values = [
    yamlencode({
      replicaCount = var.replica_count
      
      resources = {
        limits = {
          cpu = "100m"
          memory = "128Mi"
        }
        requests = {
          cpu = "100m"
          memory = "128Mi"
        }
      }
      
      webhook = {
        replicaCount = var.replica_count
        resources = {
          limits = {
            cpu = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu = "100m"
            memory = "128Mi"
          }
        }
      }
      
      cainjector = {
        replicaCount = var.replica_count
        resources = {
          limits = {
            cpu = "100m"
            memory = "128Mi"
          }
          requests = {
            cpu = "100m"
            memory = "128Mi"
          }
        }
      }
      
      prometheus = {
        enabled = true
        servicemonitor = {
          enabled = true
          prometheusInstance = "default"
          targetPort = 9402
          path = "/metrics"
          interval = "60s"
          scrapeTimeout = "30s"
          labels = {
            release = "prometheus"
          }
        }
      }
    })
  ]
  
  depends_on = [kubernetes_namespace.cert_manager]
}

# Wait for cert-manager to be ready
resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert_manager]
  create_duration = "120s"
}

# Let's Encrypt Cluster Issuer
resource "kubernetes_manifest" "letsencrypt_issuer" {
  depends_on = [time_sleep.wait_for_cert_manager]
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-prod"
    }
    spec = {
      acme = {
        server = "https://acme-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-prod"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
  
  timeouts {
    create = "5m"
  }
}

# Let's Encrypt Staging Issuer (for testing)
resource "kubernetes_manifest" "letsencrypt_staging_issuer" {
  depends_on = [time_sleep.wait_for_cert_manager]
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-staging"
    }
    spec = {
      acme = {
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        email  = var.letsencrypt_email
        privateKeySecretRef = {
          name = "letsencrypt-staging"
        }
        solvers = [
          {
            http01 = {
              ingress = {
                class = "nginx"
              }
            }
          }
        ]
      }
    }
  }
  
  timeouts {
    create = "5m"
  }
}
