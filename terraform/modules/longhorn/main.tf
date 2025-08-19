# Longhorn Storage System
resource "kubernetes_namespace" "longhorn_system" {
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
  version    = "1.5.3"
  namespace  = kubernetes_namespace.longhorn_system.metadata[0].name
  
  timeout = 600
  
  values = [
    yamlencode({
      defaultSettings = {
        defaultReplicaCount = var.replica_count
        storageMinimalAvailablePercentage = 10
        backupTarget = ""
        backupTargetCredentialSecret = ""
        allowRecurringJobWhileVolumeDetached = true
        createDefaultDiskLabeledNodes = true
        defaultDataPath = "/var/lib/longhorn/"
        replicaSoftAntiAffinity = false
        storageOverProvisioningPercentage = 100
        storageMinimalAvailablePercentage = 25
        upgradeChecker = true
        defaultReplicaCount = var.replica_count
        guaranteedEngineManagerCPU = 12
        guaranteedReplicaManagerCPU = 12
        kubernetesClusterAutoscalerEnabled = false
        orphanAutoDeletion = true
        storageNetwork = ""
      }
      
      persistence = {
        defaultClass = true
        defaultFsType = "ext4"
        defaultClassReplicaCount = var.replica_count
        defaultDataLocality = "disabled"
        reclaimPolicy = "Delete"
        migratable = false
        recurringJobSelector = {
          enable = false
          jobList = []
        }
        backingImage = {
          enable = false
          name = ""
          dataSourceType = ""
          dataSourceParameters = ""
          expectedChecksum = ""
        }
        defaultNodeSelector = {
          enable = false
          selector = ""
        }
      }
      
      csi = {
        kubeletRootDir = "~"
        attacherReplicaCount = var.replica_count
        provisionerReplicaCount = var.replica_count
        resizerReplicaCount = var.replica_count
        snapshotterReplicaCount = var.replica_count
      }
      
      longhornManager = {
        priorityClass = ""
        tolerations = []
        nodeSelector = {}
        serviceAnnotations = {}
      }
      
      longhornDriver = {
        priorityClass = ""
        tolerations = []
        nodeSelector = {}
      }
      
      longhornUI = {
        replicas = 1
        priorityClass = ""
        tolerations = []
        nodeSelector = {}
      }
      
      ingress = {
        enabled = false
      }
      
      service = {
        ui = {
          type = "ClusterIP"
          nodePort = ""
        }
        manager = {
          type = "ClusterIP"
          nodePort = ""
        }
      }
    })
  ]
  
  depends_on = [kubernetes_namespace.longhorn_system]
}

# Wait for Longhorn to be ready
resource "time_sleep" "wait_for_longhorn" {
  depends_on = [helm_release.longhorn]
  create_duration = "60s"
}
