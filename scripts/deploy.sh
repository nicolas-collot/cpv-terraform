#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Deploy infrastructure
deploy_infrastructure() {
    log_info "Deploying infrastructure..."
    
    cd terraform
    
    # Check if plan exists
    if [ ! -f "terraform.tfplan" ]; then
        log_warning "No terraform plan found. Creating new plan..."
        terraform plan -out=terraform.tfplan
    fi
    
    # Apply changes
    log_info "Applying Terraform changes..."
    terraform apply terraform.tfplan
    
    # Remove plan file after successful apply
    rm -f terraform.tfplan
    
    log_success "Infrastructure deployment complete"
    
    cd - > /dev/null
}

# Validate deployment
validate_deployment() {
    log_info "Validating deployment..."
    
    # Set KUBECONFIG
    export KUBECONFIG="$HOME/.kube/config-pergament"
    
    # Check if all pods are running
    local namespaces=("longhorn-system" "ingress-nginx" "cert-manager" "monitoring" "production")
    
    for namespace in "${namespaces[@]}"; do
        log_info "Checking pods in namespace: $namespace"
        
        if kubectl get namespace "$namespace" &> /dev/null; then
            local pending_pods
            pending_pods=$(kubectl get pods -n "$namespace" --field-selector=status.phase!=Running,status.phase!=Succeeded -o name 2>/dev/null | wc -l)
            
            if [ "$pending_pods" -gt 0 ]; then
                log_warning "$pending_pods pods not ready in namespace $namespace"
                kubectl get pods -n "$namespace"
            else
                log_success "All pods ready in namespace $namespace"
            fi
        else
            log_warning "Namespace $namespace not found"
        fi
    done
    
    # Check ingress
    log_info "Checking ingress status..."
    if kubectl get ingress -n "production" &> /dev/null; then
        kubectl get ingress -n "production"
    fi
    
    # Get LoadBalancer IP
    log_info "LoadBalancer IP:"
    kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
    echo ""
}

# Show application URLs
show_urls() {
    log_info "Application URLs:"
    echo "Application: [configured via application_domain variable]"
    echo "Monitoring: [configured via monitoring_domain variable]"
    
    log_info "Grafana credentials:"
    echo "Username: admin"
    echo "Password: [check terraform.tfvars]"
}

# Main function
main() {
    log_info "Starting deployment for camps.ch infrastructure"
    
    # Confirm deployment
    read -p "Are you sure you want to deploy? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Deployment cancelled"
        exit 0
    fi
    
    deploy_infrastructure
    
    log_info "Waiting for pods to be ready..."
    sleep 30
    
    validate_deployment
    show_urls
    
    log_success "Deployment complete!"
}

# Script usage
usage() {
    echo "Usage: $0"
    echo ""
    echo "This script deploys the camps.ch infrastructure."
}

# Check if help is requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

# Run main function
main
