#!/bin/bash

# Fitness Tracker Kubernetes Deployment Script
echo "🚀 Starting Fitness Tracker Deployment to Kubernetes"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if minikube is running
if ! minikube status &> /dev/null; then
    print_error "Minikube is not running. Please start minikube first."
    exit 1
fi

# Set kubectl context to minikube
kubectl config use-context minikube

# Point Docker daemon to minikube
print_status "Configuring Docker to use minikube's Docker daemon..."
eval $(minikube docker-env)

# Build Docker images
print_status "Building Docker images..."
docker build -f Dockerfile.backend -t fitness-backend:latest .
docker build -f Dockerfile.frontend -t fitness-frontend:latest .

print_status "Docker images built successfully!"

# Apply Kubernetes manifests
print_status "Applying Kubernetes manifests..."

# Create namespace first
kubectl apply -f k8s/namespace.yaml

# Apply PVC (must be created before deployment)
kubectl apply -f k8s/mongodb-pvc.yaml

# Apply ConfigMap
kubectl apply -f k8s/configmap.yaml

# Apply all deployments and services
kubectl apply -f k8s/mongodb-deployment.yaml
kubectl apply -f k8s/mongodb-service.yaml
kubectl apply -f k8s/backend-deployment.yaml
kubectl apply -f k8s/backend-service.yaml
kubectl apply -f k8s/frontend-deployment.yaml
kubectl apply -f k8s/frontend-service.yaml

# Wait for deployments to be ready
print_status "Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/mongodb-deployment -n fitness-app
kubectl wait --for=condition=available --timeout=300s deployment/backend-deployment -n fitness-app
kubectl wait --for=condition=available --timeout=300s deployment/frontend-deployment -n fitness-app

# Apply HPA (after deployments are ready)
kubectl apply -f k8s/hpa.yaml

print_status "✅ All deployments are ready!"

# Get service URLs
print_status "Getting service URLs..."
minikube service frontend-service -n fitness-app --url
minikube service backend-service -n fitness-app --url

print_status "🎉 Deployment completed successfully!"
print_status "You can now access your application using the URLs above."

# Show pod status
print_status "Current pod status:"
kubectl get pods -n fitness-app -o wide 