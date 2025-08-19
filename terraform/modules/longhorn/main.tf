# Longhorn storage system
resource "kubernetes_namespace" "longhorn" {
  metadata {
    name = "longhorn-system"
    labels = {
      name = "longhorn-system"
    }
  }
}

resource "helm_release" "longhorn" {
  name       = "longhorn"
  repository = "https://charts.longhorn.io"
  chart      = "longhorn"
  version    = "1.6.0"
  namespace  = kubernetes_namespace.longhorn.metadata[0].name
  
  timeout = 600
  
  values = [
    yamlencode({
      defaultSettings = {
        defaultReplicaCount = 1
      }
      
      persistence = {
        defaultClass = true
        defaultClassReplicaCount = 1
      }
      
      csi = {
        kubeletRootDir = "/var/lib/kubelet"
        attacherReplicaCount = 1
        provisionerReplicaCount = 1
        resizerReplicaCount = 1
        snapshotterReplicaCount = 1
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
    })
  ]
  
  depends_on = [kubernetes_namespace.longhorn]
}
