#!/bin/bash

# Fitness Tracker Kubernetes Monitoring Script
echo "📊 Monitoring Fitness Tracker Kubernetes Deployment"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

# Set kubectl context to minikube
kubectl config use-context minikube

print_header "NAMESPACE STATUS"
kubectl get namespace fitness-app

print_header "PODS STATUS"
kubectl get pods -n fitness-app -o wide

print_header "DEPLOYMENTS STATUS"
kubectl get deployments -n fitness-app

print_header "SERVICES STATUS"
kubectl get services -n fitness-app

print_header "PVC STATUS"
kubectl get pvc -n fitness-app

print_header "HPA STATUS"
kubectl get hpa -n fitness-app

print_header "CONFIGMAP STATUS"
kubectl get configmap -n fitness-app

print_header "RESOURCE USAGE"
kubectl top pods -n fitness-app 2>/dev/null || echo "Metrics server not available"

print_header "SERVICE ENDPOINTS"
print_status "Frontend URL:"
minikube service frontend-service -n fitness-app --url 2>/dev/null || echo "Service not ready"

print_status "Backend URL:"
minikube service backend-service -n fitness-app --url 2>/dev/null || echo "Service not ready"

print_header "RECENT EVENTS"
kubectl get events -n fitness-app --sort-by='.metadata.creationTimestamp' | tail -10

print_status "Monitoring completed!"
print_status "Run 'kubectl logs -f deployment/backend-deployment -n fitness-app' to view backend logs"
print_status "Run 'kubectl logs -f deployment/frontend-deployment -n fitness-app' to view frontend logs" 