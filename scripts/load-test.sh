#!/bin/bash

# Load Testing Script for Fitness Tracker HPA Demonstration
echo "🚀 Starting Load Test to Demonstrate HPA Auto-scaling"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Check if deployment is ready
kubectl get deployment backend-deployment -n fitness-app > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${RED}[ERROR]${NC} Backend deployment not found. Please deploy the application first."
    exit 1
fi

print_header "INITIAL STATE"
print_status "Current pod count:"
kubectl get pods -l app=backend -n fitness-app

print_status "Current HPA status:"
kubectl get hpa backend-hpa -n fitness-app

print_header "STARTING LOAD TEST"
print_warning "This will create sustained load on the backend service to trigger auto-scaling"
print_status "Starting 5 concurrent load generators..."

# Create multiple load generators
for i in {1..5}; do
    kubectl run load-generator-$i \
        --image=busybox \
        --restart=Never \
        --rm -i --tty -- /bin/sh -c "
        echo 'Load generator $i started';
        while true; do 
            wget -q --timeout=1 -O- http://backend-service.fitness-app.svc.cluster.local:4000/ || true; 
            sleep 0.1; 
        done" &
    echo "Started load generator $i (PID: $!)"
done

print_status "Load generators started! Monitoring auto-scaling..."
print_status "Press Ctrl+C to stop the load test"

# Monitor scaling
trap 'echo -e "\n${YELLOW}Stopping load test...${NC}"; kubectl delete pod -l run=load-generator --ignore-not-found=true -n default; exit 0' INT

# Monitor for 10 minutes or until interrupted
for i in {1..120}; do
    clear
    print_header "LOAD TEST MONITORING (${i}/120 - $(date))"
    
    echo -e "${BLUE}Pod Count:${NC}"
    kubectl get pods -l app=backend -n fitness-app --no-headers | wc -l
    
    echo -e "\n${BLUE}Pod Status:${NC}"
    kubectl get pods -l app=backend -n fitness-app
    
    echo -e "\n${BLUE}HPA Status:${NC}"
    kubectl get hpa backend-hpa -n fitness-app
    
    echo -e "\n${BLUE}CPU/Memory Usage:${NC}"
    kubectl top pods -l app=backend -n fitness-app 2>/dev/null || echo "Metrics not available yet"
    
    echo -e "\n${BLUE}Recent Events:${NC}"
    kubectl get events -n fitness-app --field-selector reason=SuccessfulRescale --sort-by='.metadata.creationTimestamp' | tail -3
    
    echo -e "\n${YELLOW}Load generators running... Press Ctrl+C to stop${NC}"
    
    sleep 5
done

print_status "Load test completed after 10 minutes"
kubectl delete pod -l run=load-generator --ignore-not-found=true -n default

print_header "FINAL STATE"
kubectl get pods -l app=backend -n fitness-app
kubectl get hpa backend-hpa -n fitness-app 