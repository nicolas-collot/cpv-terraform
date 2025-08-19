# 🏕️ camps.ch Infrastructure

Production-ready Kubernetes infrastructure for camps.ch using Terraform and Helm.

## 🚀 Quick Start

```bash
# 1. Set kubeconfig
export KUBECONFIG=~/.kube/config-pergament

# 2. Copy and edit configuration
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edit terraform/terraform.tfvars with your values

# 3. Deploy infrastructure
./scripts/setup.sh
./scripts/deploy.sh
```

## 📋 What's Deployed

### Core Infrastructure
- **Longhorn Storage** - Distributed block storage
- **Nginx Ingress** - Load balancer and routing
- **Cert-Manager** - SSL certificate management
- **Prometheus Stack** - Monitoring and alerting

### URLs
- **Monitoring Dashboard**: https://monitoring.camps.ch
- **Grafana**: https://monitoring.camps.ch (admin/admin123)

## 📁 Repository Structure

```
├── terraform/                 # Terraform configurations
│   ├── modules/              # Reusable modules
│   │   ├── longhorn/         # Storage system
│   │   ├── nginx-ingress/    # Load balancer
│   │   ├── cert-manager/     # SSL certificates
│   │   └── prometheus/       # Monitoring stack
│   ├── main.tf              # Main configuration
│   ├── variables.tf         # Variable definitions
│   ├── outputs.tf           # Output values
│   └── terraform.tfvars.example # Configuration template
├── scripts/                  # Deployment scripts
│   ├── setup.sh             # Initial setup
│   └── deploy.sh            # Deployment
└── docs/                     # Documentation
    ├── architecture.md      # Architecture overview
    └── deployment.md        # Deployment guide
```

## 🔧 Configuration

### Essential Variables
- `kubeconfig_path` - Path to your kubeconfig file
- `application_domain` - Main application domain
- `monitoring_domain` - Monitoring dashboard domain
- `letsencrypt_email` - Email for SSL certificates
- `grafana_admin_password` - Grafana admin password

### Default Resources
- **All replicas**: 1 (minimal resource usage)
- **Storage**: 20GB Prometheus, 5GB Grafana/AlertManager
- **CPU/Memory**: Optimized for minimal usage

## 📚 Documentation

- [Architecture Documentation](docs/architecture.md)
- [Deployment Guide](docs/deployment.md) - **Complete step-by-step deployment instructions**

## 🛠️ Scripts

- `scripts/setup.sh` - Initial setup and validation
- `scripts/deploy.sh` - Deploy infrastructure and verify

## 🔒 Security

- SSL certificates via Let's Encrypt
- Secure Grafana admin password
- Minimal resource allocation
- Production-ready defaults

## 📞 Support

For issues and questions, check the [deployment guide](docs/deployment.md) or review the architecture documentation.
