# Nginx Ingress Controller
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      name = "ingress-nginx"
    }
  }
}

resource "helm_release" "ingress_nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.7.1"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  
  timeout = 600
  
  values = [
    yamlencode({
      controller = {
        replicaCount = 1
        
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
        
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type" = "nlb"
          }
        }
        
        config = {
          "use-proxy-protocol" = "false"
          "proxy-real-ip-cidr" = "0.0.0.0/0"
          "use-forwarded-headers" = "true"
        }
      }
    })
  ]
  
  depends_on = [kubernetes_namespace.ingress_nginx]
}

# Wait for LoadBalancer to get external IP
resource "time_sleep" "wait_for_lb" {
  depends_on = [helm_release.ingress_nginx]
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
