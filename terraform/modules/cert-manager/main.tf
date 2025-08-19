# =============================================================================
# CERT-MANAGER TERRAFORM CONFIGURATION
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
  version    = "1.13.2"

  values = [
    yamlencode({
      installCRDs = true
      
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
    })
  ]

  wait          = true
  wait_for_jobs = true
  timeout       = 300

  depends_on = [
    kubernetes_namespace.cert_manager
  ]
}

# Wait for cert-manager to be ready
resource "time_sleep" "wait_for_cert_manager" {
  depends_on = [helm_release.cert_manager]
  create_duration = "30s"
}

# Create ClusterIssuer for Let's Encrypt staging
resource "kubectl_manifest" "cluster_issuer_staging" {
  yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-staging
spec:
  acme:
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: letsencrypt-staging
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
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
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.letsencrypt_email}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          ingressClassName: nginx
YAML

  depends_on = [
    time_sleep.wait_for_cert_manager
  ]
}
