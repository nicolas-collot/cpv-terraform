# =============================================================================
# CERT-MANAGER TERRAFORM CONFIGURATION
# Complete setup with pathType fix for nginx ingress compatibility
# =============================================================================

# Create cert-manager namespace
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "cert-manager.io/disable-validation" = "true"
    }
  }
}

# Add Jetstack Helm repository
resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = kubernetes_namespace.cert_manager.metadata[0].name
  version    = var.cert_manager_version

  values = [
    yamlencode({
      # Essential configuration for cert-manager
      installCRDs = true

      global = {
        leaderElection = {
          namespace = kubernetes_namespace.cert_manager.metadata[0].name
        }
      }

      # Enable prometheus metrics
      prometheus = {
        enabled = true
      }

      # Configure resource requests/limits
      resources = {
        requests = {
          cpu    = "10m"
          memory = "32Mi"
        }
      }

      webhook = {
        resources = {
          requests = {
            cpu    = "10m"
            memory = "32Mi"
          }
        }
      }

      cainjector = {
        resources = {
          requests = {
            cpu    = "10m"
            memory = "32Mi"
          }
        }
      }

      # Configure node selector if needed
      nodeSelector = var.node_selector != null ? var.node_selector : {}
    })
  ]

  # Wait for deployment to be ready
  wait          = true
  wait_for_jobs = true
  timeout       = 300

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

# Wait for cert-manager to be ready before creating issuers
resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert_manager]
  create_duration = "30s"
}

# =============================================================================
# CLUSTER ISSUERS WITH PATHTYPE FIX
# =============================================================================

# Create ClusterIssuer for Let's Encrypt staging
resource "kubectl_manifest" "cluster_issuer_staging" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${var.cert_issuer_staging}
  labels:
    app.kubernetes.io/name: cert-manager
    app.kubernetes.io/component: cluster-issuer
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: ${var.cert_issuer_staging}
    solvers:
    - http01:
        ingress:
          ingressClassName: ${var.ingress_class}
          ingressTemplate:
            metadata:
              annotations:
                nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
                nginx.ingress.kubernetes.io/ssl-redirect: "false"
            spec:
              # CRITICAL FIX: Configure pathType in ingressTemplate
              rules:
              - http:
                  paths:
                  - pathType: Prefix  # Use Prefix instead of Exact
                    path: /.well-known/acme-challenge
                    backend:
                      service:
                        name: ""  # Will be filled by cert-manager
                        port:
                          number: 8089
YAML

  depends_on = [
    time_sleep.wait_for_cert_manager
  ]
}

# Create ClusterIssuer for Let's Encrypt production
resource "kubectl_manifest" "cluster_issuer_prod" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${var.cert_issuer_prod}
  labels:
    app.kubernetes.io/name: cert-manager
    app.kubernetes.io/component: cluster-issuer
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: ${var.cert_issuer_prod}
    solvers:
    - http01:
        ingress:
          ingressClassName: ${var.ingress_class}
          ingressTemplate:
            metadata:
              annotations:
                nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
                nginx.ingress.kubernetes.io/ssl-redirect: "false"
            spec:
              # CRITICAL FIX: Configure pathType in ingressTemplate
              rules:
              - http:
                  paths:
                  - pathType: Prefix  # Use Prefix instead of Exact
                    path: /.well-known/acme-challenge
                    backend:
                      service:
                        name: ""  # Will be filled by cert-manager
                        port:
                          number: 8089
YAML

  depends_on = [
    time_sleep.wait_for_cert_manager
  ]
}

# =============================================================================
# HTTP01 SOLVER ONLY - NO DNS01/CLOUDFLARE NEEDED
# Using nginx ingress for ACME HTTP01 challenges
# =============================================================================

# =============================================================================
# VALIDATION AND MONITORING
# =============================================================================

# ServiceMonitor for cert-manager metrics (if Prometheus is available)
resource "kubectl_manifest" "cert_manager_service_monitor" {
  count = var.enable_monitoring ? 1 : 0

  yaml_body = <<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: cert-manager
  namespace: ${kubernetes_namespace.cert_manager.metadata[0].name}
  labels:
    app.kubernetes.io/name: cert-manager
    app.kubernetes.io/component: monitoring
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: cert-manager
      app.kubernetes.io/component: controller
  endpoints:
  - port: tcp-prometheus-servicemonitor
    interval: 60s
    path: /metrics
YAML

  depends_on = [
    helm_release.cert_manager
  ]
}

# =============================================================================
# OUTPUTS
# =============================================================================

# Validate that ClusterIssuers are ready
data "kubectl_path_documents" "check_staging_issuer" {
  pattern = "/dev/null"
  depends_on = [
    kubectl_manifest.cluster_issuer_staging
  ]
}

data "kubectl_path_documents" "check_prod_issuer" {
  pattern = "/dev/null"
  depends_on = [
    kubectl_manifest.cluster_issuer_prod
  ]
}
