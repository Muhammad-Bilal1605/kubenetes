# Fitness Tracker Kubernetes Deployment Guide

This guide will walk you through deploying the Fitness Tracker application to Kubernetes using minikube on Ubuntu.

## Prerequisites

### 1. Ubuntu Virtual Machine Setup
Make sure you have an Ubuntu VM with at least:
- 4GB RAM
- 2 CPU cores
- 20GB disk space
- Internet connection

### 2. Required Software Installation

```bash
# Update package list
sudo apt update && sudo apt upgrade -y

# Install Docker
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
newgrp docker

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install Git (if not already installed)
sudo apt install -y git
```

## Step-by-Step Deployment Process

### Step 1: Push Code to GitHub

```bash
# Initialize git repository (if not already done)
cd /path/to/your/fitness-tracker
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial commit: Fitness Tracker with Kubernetes deployment"

# Create a new repository on GitHub and add remote
git remote add origin https://github.com/YOUR_USERNAME/fitness-tracker.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### Step 2: Clone Repository on Ubuntu VM

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/fitness-tracker.git
cd fitness-tracker
```

### Step 3: Start Minikube

```bash
# Start minikube with adequate resources
minikube start --memory=4096 --cpus=2 --driver=docker

# Enable metrics server for HPA
minikube addons enable metrics-server

# Verify minikube is running
minikube status
```

### Step 4: Deploy the Application

```bash
# Make deployment script executable
chmod +x scripts/deploy.sh

# Run the deployment script
./scripts/deploy.sh
```

This script will:
1. Configure Docker to use minikube's Docker daemon
2. Build both frontend and backend Docker images
3. Create the namespace
4. Deploy MongoDB with persistent storage
5. Deploy the backend with multiple replicas
6. Deploy the frontend with load balancing
7. Set up HorizontalPodAutoscaler for auto-scaling
8. Provide you with access URLs

### Step 5: Verify Deployment

```bash
# Check all resources
./scripts/monitor.sh

# Or manually check:
kubectl get all -n fitness-app
kubectl get pvc -n fitness-app
kubectl get hpa -n fitness-app
```

### Step 6: Access Your Application

```bash
# Get the frontend URL
minikube service frontend-service -n fitness-app --url

# Get the backend API URL
minikube service backend-service -n fitness-app --url

# Open in browser
minikube service frontend-service -n fitness-app
```

## Architecture Overview

### Components Deployed:

1. **MongoDB Database**
   - Single replica (as required)
   - NodePort service (as required)
   - Persistent Volume Claim for data persistence
   - 5GB storage allocated

2. **Backend (Node.js/Express)**
   - 3 replicas for load distribution
   - LoadBalancer service (as required)
   - Auto-scaling with HPA (2-10 replicas)
   - Resource limits and health checks

3. **Frontend (React/Nginx)**
   - 2 replicas for high availability
   - LoadBalancer service for external access
   - Optimized Nginx configuration

4. **HorizontalPodAutoscaler**
   - Monitors CPU and memory usage
   - Scales backend pods between 2-10 replicas
   - Triggers scaling at 70% CPU or 80% memory

### Services Configuration:

- **MongoDB Service**: NodePort (accessible on port 30001)
- **Backend Service**: LoadBalancer (auto-assigned external IP)
- **Frontend Service**: LoadBalancer (auto-assigned external IP)

## Useful Commands

### Monitoring and Debugging

```bash
# View all resources
kubectl get all -n fitness-app

# Check pod logs
kubectl logs -f deployment/backend-deployment -n fitness-app
kubectl logs -f deployment/frontend-deployment -n fitness-app
kubectl logs -f deployment/mongodb-deployment -n fitness-app

# Check HPA status
kubectl get hpa -n fitness-app
kubectl describe hpa backend-hpa -n fitness-app

# Check PVC status
kubectl get pvc -n fitness-app
kubectl describe pvc mongodb-pvc -n fitness-app

# View events
kubectl get events -n fitness-app --sort-by='.metadata.creationTimestamp'
```

### Scaling Operations

```bash
# Manually scale deployments
kubectl scale deployment backend-deployment --replicas=5 -n fitness-app
kubectl scale deployment frontend-deployment --replicas=3 -n fitness-app

# Test auto-scaling by generating load
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh
# Inside the pod, run:
while true; do wget -q -O- http://backend-service:4000/; done
```

### Updates and Rollbacks

```bash
# Update application (rebuild and redeploy)
./scripts/deploy.sh

# Rollback deployment
kubectl rollout undo deployment/backend-deployment -n fitness-app
kubectl rollout undo deployment/frontend-deployment -n fitness-app

# Check rollout status
kubectl rollout status deployment/backend-deployment -n fitness-app
```

## Cleanup

To remove all resources and clean up:

```bash
# Run cleanup script
chmod +x scripts/cleanup.sh
./scripts/cleanup.sh

# Stop minikube
minikube stop

# Delete minikube cluster (optional)
minikube delete
```

## Troubleshooting

### Common Issues:

1. **Pods stuck in Pending state**
   ```bash
   kubectl describe pod <pod-name> -n fitness-app
   ```
   Usually caused by insufficient resources or storage issues.

2. **Service not accessible**
   ```bash
   minikube service list
   kubectl get endpoints -n fitness-app
   ```

3. **Images not found**
   Make sure you're using minikube's Docker daemon:
   ```bash
   eval $(minikube docker-env)
   docker images | grep fitness
   ```

4. **MongoDB connection issues**
   Check if MongoDB service is running and accessible:
   ```bash
   kubectl exec -it deployment/backend-deployment -n fitness-app -- curl mongodb-service:27017
   ```

### Performance Monitoring:

```bash
# Monitor resource usage
kubectl top pods -n fitness-app
kubectl top nodes

# Check HPA metrics
kubectl get hpa -n fitness-app -w
```

## Security Considerations

1. **Database Credentials**: In production, use Kubernetes secrets instead of plain text
2. **Network Policies**: Implement network policies to restrict pod-to-pod communication
3. **RBAC**: Set up proper Role-Based Access Control
4. **Image Security**: Scan Docker images for vulnerabilities
5. **Resource Limits**: Always set resource limits to prevent resource exhaustion

## Production Readiness Checklist

- [ ] Replace hard-coded credentials with Kubernetes secrets
- [ ] Implement network policies
- [ ] Set up monitoring and logging (Prometheus, Grafana, ELK stack)
- [ ] Configure backup strategy for MongoDB
- [ ] Implement CI/CD pipeline
- [ ] Set up ingress controller for production traffic
- [ ] Configure SSL/TLS certificates
- [ ] Implement pod security policies
- [ ] Set up cluster autoscaling
- [ ] Configure disaster recovery procedures

This deployment setup provides a solid foundation for running your fitness tracker application on Kubernetes with high availability, auto-scaling, and persistent data storage. 