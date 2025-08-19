# 🏗️ camps.ch Infrastructure

Infrastructure Kubernetes as Code pour la plateforme camps.ch - **Production Ready**

## 🎯 Architecture

- **Provider**: Infomaniak Managed Kubernetes
- **IaC**: Terraform + Helm
- **Monitoring**: Prometheus + Grafana + AlertManager
- **Storage**: Longhorn distributed storage (2 replicas)
- **Load Balancer**: Nginx Ingress Controller (3 replicas, auto-scaling)
- **SSL**: cert-manager + Let's Encrypt

## 🚀 Quick Start

### Prerequisites
```bash
# Install required tools
brew install terraform kubectl helm

# Or on Ubuntu/Debian
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform kubectl helm
```

### Configuration
```bash
# 1. Set kubeconfig
export KUBECONFIG=~/.kube/config-camps

# 2. Copy and edit configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
nano terraform/terraform.tfvars

# 3. Run setup
./scripts/setup.sh
```

### Deployment
```bash
# Deploy infrastructure
./scripts/deploy.sh
```

## 📋 Infrastructure Components

### Core Infrastructure
- **Longhorn Storage**: Distributed storage with configurable replicas
- **Nginx Ingress**: Load balancer with configurable auto-scaling
- **cert-manager**: Automatic SSL certificate management
- **Prometheus Stack**: Complete monitoring solution

### Monitoring Stack
- **Prometheus**: Metrics collection and storage (100GB)
- **Grafana**: Dashboards and visualization
- **AlertManager**: Alert routing and notification
- **Node Exporter**: System metrics
- **Kube State Metrics**: Kubernetes metrics

### URLs
- **Monitoring Dashboard**: Configurable via `monitoring_domain` variable
- **Grafana**: Configurable via `monitoring_domain` variable (admin/admin)

## 🔧 Resource Allocation & Customization

### Default Configuration (UAT Ready - Minimal Resources)
- **All replicas**: 1 by default (minimal resource usage)
- **Auto-scaling**: Disabled by default
- **Storage**: 20GB Prometheus, 5GB Grafana/AlertManager
- **CPU/Memory**: Minimal limits optimized for UAT environments

### Resource Limits (Default - UAT)
- **Nginx Ingress**: 500m CPU / 512MB RAM limits, 100m CPU / 128MB RAM requests
- **Prometheus**: 500m CPU / 1GB RAM limits, 250m CPU / 512MB RAM requests  
- **Grafana**: 500m CPU / 512MB RAM limits, 100m CPU / 128MB RAM requests
- **AlertManager**: 100m CPU / 128MB RAM limits, 50m CPU / 64MB RAM requests

### Production Scaling
For production environments, increase:
- **Replica counts**: 2-3 replicas per component
- **Resource limits**: 2-4x current values
- **Storage sizes**: 50-200GB based on retention needs
- **Auto-scaling**: Enable with appropriate thresholds

### Customization Options
- **Replica counts**: Configurable for all components
- **Resource limits**: CPU and memory limits/requests per component
- **Auto-scaling**: Enable/disable per component
- **Component enablement**: Enable/disable entire modules
- **Storage sizes**: Configurable per component

## 📊 Monitoring Features

### Pre-configured Dashboards
- Kubernetes Cluster Overview
- Node Exporter Full
- Nginx Ingress Controller
- Pod Monitoring

### Alerting Rules
- Pod crashloop/restart
- High CPU/Memory usage
- SSL certificate expiration
- Storage issues

## 🔗 Documentation

- [Architecture Documentation](docs/architecture.md)
- [Deployment Guide](docs/deployment.md) - **Complete step-by-step deployment instructions**

## 🛠️ Scripts

- `scripts/setup.sh`: Initialize and plan Terraform
- `scripts/deploy.sh`: Deploy infrastructure and validate

## 📞 Support

- **Repository**: [Your GitLab Repository URL]
- **Issues**: GitLab Issues
- **Documentation**: Wiki GitLab
