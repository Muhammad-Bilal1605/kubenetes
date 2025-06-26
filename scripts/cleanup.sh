#!/bin/bash

# Fitness Tracker Kubernetes Cleanup Script
echo "🧹 Cleaning up Fitness Tracker Deployment from Kubernetes"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Set kubectl context to minikube
kubectl config use-context minikube

print_status "Deleting all resources in fitness-app namespace..."

# Delete HPA first
kubectl delete -f k8s/hpa.yaml --ignore-not-found=true

# Delete services
kubectl delete -f k8s/frontend-service.yaml --ignore-not-found=true
kubectl delete -f k8s/backend-service.yaml --ignore-not-found=true
kubectl delete -f k8s/mongodb-service.yaml --ignore-not-found=true

# Delete deployments
kubectl delete -f k8s/frontend-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/backend-deployment.yaml --ignore-not-found=true
kubectl delete -f k8s/mongodb-deployment.yaml --ignore-not-found=true

# Delete ConfigMap
kubectl delete -f k8s/configmap.yaml --ignore-not-found=true

# Delete PVC (this will also delete the PV and lose data)
print_warning "Deleting PVC will permanently delete MongoDB data!"
read -p "Are you sure you want to delete the MongoDB data? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    kubectl delete -f k8s/mongodb-pvc.yaml --ignore-not-found=true
    print_status "PVC deleted - MongoDB data has been permanently removed"
else
    print_status "PVC retained - MongoDB data is preserved"
fi

# Delete namespace (this will delete any remaining resources)
kubectl delete -f k8s/namespace.yaml --ignore-not-found=true

print_status "✅ Cleanup completed!"

# Show remaining resources (should be empty)
print_status "Checking for any remaining resources..."
kubectl get all -n fitness-app 2>/dev/null || print_status "Namespace fitness-app no longer exists" 