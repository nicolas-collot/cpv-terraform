# 🚀 Deployment Guide

## Prerequisites

### Required Tools
```bash
# Install Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# Install kubectl (required for kubectl provider)
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update && sudo apt-get install helm
```

### Cluster Access
1. **Download kubeconfig** from Infomaniak:
   - Go to manager.infomaniak.com
   - Cloud → Kubernetes → camps-shared-cluster
   - "Accès" → "Télécharger kubeconfig"
   - Save as `~/.kube/config-pergament`

2. **Test connectivity**:
   ```bash
   export KUBECONFIG=~/.kube/config-pergament
   kubectl cluster-info
   ```

## Configuration

### 1. Clone Repository
```bash
git clone [YOUR_REPOSITORY_URL]
cd camps-ch-infrastructure
```

### 2. Configure Variables
```bash
# Copy example configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Edit configuration
nano terraform/terraform.tfvars
```

### 3. Required Configuration
Update these values in `terraform.tfvars`:

```hcl
# Domain configuration
application_domain = "your-domain.com"
monitoring_domain = "monitoring.your-domain.com"

# SSL certificates
letsencrypt_email = "admin@your-domain.com"

# Security
grafana_admin_password = "YOUR_STRONG_PASSWORD"

# Environment
environment = "production"  # or "uat"
```

### 4. Optional Configuration
Adjust based on your needs:

```hcl
# For production environments
longhorn_replica_count = 2
nginx_ingress_replicas = 2
prometheus_replicas = 2
grafana_replicas = 2

# Enable auto-scaling
nginx_ingress_enable_autoscaling = true
nginx_ingress_max_replicas = 10

# Increase storage for production
prometheus_storage_size = "100Gi"
grafana_storage_size = "20Gi"
alertmanager_storage_size = "10Gi"

# Increase resource limits for production
prometheus_cpu_limit = "2000m"
prometheus_memory_limit = "4Gi"
grafana_cpu_limit = "1000m"
grafana_memory_limit = "1Gi"
```

## Deployment

### Automated Deployment (Recommended)
```bash
# Setup and plan
./scripts/setup.sh

# Deploy infrastructure
./scripts/deploy.sh
```

### Manual Deployment
```bash
# Initialize Terraform
cd terraform
terraform init

# Plan deployment
terraform plan -out=terraform.tfplan

# Apply changes
terraform apply terraform.tfplan
```

## Post-Deployment

### 1. Verify Deployment
```bash
# Check all namespaces
kubectl get namespaces

# Check pods in each namespace
kubectl get pods -n longhorn-system
kubectl get pods -n ingress-nginx
kubectl get pods -n cert-manager
kubectl get pods -n monitoring
kubectl get pods -n production
```

### 2. Get LoadBalancer IP
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

### 3. Configure DNS
Point your domains to the LoadBalancer IP:
- `your-domain.com` → LoadBalancer IP
- `monitoring.your-domain.com` → LoadBalancer IP

### 4. Access Services
- **Grafana**: https://monitoring.your-domain.com
  - Username: `admin`
  - Password: [from terraform.tfvars]

### 5. Verify SSL Certificates
```bash
# Check certificate status
kubectl get certificates -A

# Test SSL
echo | openssl s_client -connect monitoring.your-domain.com:443 -servername monitoring.your-domain.com
```

## Monitoring Setup

### 1. Grafana Dashboards
Pre-configured dashboards are automatically installed:
- Kubernetes Cluster Overview
- Node Exporter Full
- Nginx Ingress Controller
- Pod Monitoring

### 2. Alerting
AlertManager is configured with basic alerts:
- Pod crashloop/restart
- High CPU/Memory usage
- SSL certificate expiration

### 3. Metrics
Prometheus collects metrics from:
- Kubernetes cluster
- Nginx Ingress
- Node Exporter
- Custom applications

## Troubleshooting

### Common Issues

#### 0. Cert-Manager CRD Issues
If you encounter errors like "No matches for kind 'ClusterIssuer' in 'certmanager.io'":
1. **Wait for cert-manager to fully initialize** (can take 2-3 minutes)
2. **Check cert-manager pods are running**:
   ```bash
   kubectl get pods -n cert-manager
   ```
3. **Verify CRDs are installed**:
   ```bash
   kubectl get crd | grep cert-manager
   ```
4. **Check cert-manager version compatibility** (using v1.13.2):
   ```bash
   kubectl get deployment cert-manager -n cert-manager -o jsonpath='{.spec.template.spec.containers[0].image}'
   ```
5. **Verify kubectl provider is working**:
   ```bash
   kubectl get clusterissuers
   ```
6. **If issues persist, re-run terraform apply** after a few minutes

#### 1. Pods Not Starting
```bash
# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check logs
kubectl logs <pod-name> -n <namespace>

# Check resource usage
kubectl top pods -n <namespace>
```

#### 2. SSL Certificate Issues
```bash
# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager

# Check certificate status
kubectl get certificates -A
kubectl describe certificate <cert-name> -n <namespace>
```

#### 3. Storage Issues
```bash
# Check Longhorn status
kubectl get volumes -A
kubectl get volumesnapshots -A

# Check PVC status
kubectl get pvc -A
```

#### 4. Ingress Issues
```bash
# Check ingress status
kubectl get ingress -A

# Check nginx logs
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
```

### Resource Scaling

#### Scale Up for Production
```hcl
# Increase replicas
longhorn_replica_count = 3
nginx_ingress_replicas = 3
prometheus_replicas = 3
grafana_replicas = 2

# Enable auto-scaling
nginx_ingress_enable_autoscaling = true
nginx_ingress_max_replicas = 15

# Increase resource limits
prometheus_cpu_limit = "4000m"
prometheus_memory_limit = "8Gi"
grafana_cpu_limit = "2000m"
grafana_memory_limit = "2Gi"

# Increase storage
prometheus_storage_size = "200Gi"
grafana_storage_size = "50Gi"
alertmanager_storage_size = "20Gi"
```

#### Scale Down for Development
```hcl
# Minimal configuration
longhorn_replica_count = 1
nginx_ingress_replicas = 1
prometheus_replicas = 1
grafana_replicas = 1

# Disable auto-scaling
nginx_ingress_enable_autoscaling = false

# Minimal resources
prometheus_cpu_limit = "250m"
prometheus_memory_limit = "512Mi"
grafana_cpu_limit = "250m"
grafana_memory_limit = "256Mi"

# Minimal storage
prometheus_storage_size = "10Gi"
grafana_storage_size = "2Gi"
alertmanager_storage_size = "2Gi"
```

## Maintenance

### Updates
```bash
# Update Helm repositories
helm repo update

# Check for chart updates
helm list -A

# Update via Terraform
cd terraform
terraform plan
terraform apply
```

### Backups
```bash
# Longhorn snapshots
kubectl get volumesnapshots -A

# Export Terraform state
terraform state pull > terraform-state-backup.json
```

### Monitoring
- **Grafana**: https://monitoring.your-domain.com
- **Prometheus**: Port-forward to access directly
- **AlertManager**: Configure webhook receivers for notifications

## Security Considerations

### 1. Passwords
- Change `grafana_admin_password` to a strong password
- Use secrets management for production

### 2. Network Security
- Configure network policies
- Use RBAC for access control
- Enable audit logging

### 3. SSL/TLS
- Certificates are automatically managed by cert-manager
- Monitor certificate expiration
- Configure proper TLS versions

### 4. Monitoring Security
- Secure Grafana access
- Configure authentication providers
- Set up proper alerting channels
