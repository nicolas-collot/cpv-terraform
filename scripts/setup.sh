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

# Check if required tools are installed
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    local tools=("terraform" "kubectl" "helm")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Please install missing tools and run again"
        exit 1
    fi
    
    log_success "All prerequisites are installed"
}

# Setup environment
setup_environment() {
    log_info "Setting up environment..."
    
    # Check if kubeconfig exists
    if [ ! -f "$HOME/.kube/config-camps" ]; then
        log_error "Kubeconfig not found at $HOME/.kube/config-camps"
        log_info "Please download kubeconfig from Infomaniak and place it at $HOME/.kube/config-camps"
        exit 1
    fi
    
    # Set KUBECONFIG
    export KUBECONFIG="$HOME/.kube/config-camps"
    
    # Test kubectl connectivity
    if ! kubectl cluster-info &> /dev/null; then
        log_error "Cannot connect to Kubernetes cluster"
        log_info "Please check your kubeconfig and cluster status"
        exit 1
    fi
    
    log_success "Connected to Kubernetes cluster"
    
    # Check if terraform.tfvars exists
    local tfvars_file="terraform/terraform.tfvars"
    if [ ! -f "$tfvars_file" ]; then
        log_warning "terraform.tfvars not found at $tfvars_file"
        log_info "Copying terraform.tfvars.example to terraform.tfvars"
        cp "terraform/terraform.tfvars.example" "$tfvars_file"
        log_warning "Please edit $tfvars_file with your actual values before continuing"
        exit 1
    fi
    
    log_success "Environment setup complete"
}

# Initialize Terraform
init_terraform() {
    log_info "Initializing Terraform..."
    
    cd terraform
    
    # Initialize Terraform
    terraform init
    
    # Validate configuration
    terraform validate
    
    log_success "Terraform initialized successfully"
    
    cd - > /dev/null
}

# Plan Terraform
plan_terraform() {
    log_info "Planning Terraform..."
    
    cd terraform
    
    # Plan changes
    terraform plan -out=terraform.tfplan
    
    log_success "Terraform plan complete. Review the plan above."
    log_info "Run './scripts/deploy.sh' to apply changes"
    
    cd - > /dev/null
}

# Main function
main() {
    log_info "Starting setup for camps.ch infrastructure"
    
    check_prerequisites
    setup_environment
    init_terraform
    plan_terraform
    
    log_success "Setup complete!"
    log_info "Next steps:"
    log_info "1. Review the Terraform plan"
    log_info "2. Run './scripts/deploy.sh' to deploy"
}

# Script usage
usage() {
    echo "Usage: $0"
    echo ""
    echo "This script sets up the camps.ch infrastructure for deployment."
}

# Check if help is requested
if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
fi

# Run main function
main
