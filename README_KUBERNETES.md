# Fitness Tracker - Kubernetes Deployment

This project deploys a full-stack fitness tracking application on Kubernetes using minikube.

## 🏗️ Architecture

- **Frontend**: React.js with Nginx (2 replicas, LoadBalancer service)
- **Backend**: Node.js/Express API (3 replicas, LoadBalancer service, HPA enabled)
- **Database**: MongoDB (1 replica, NodePort service, Persistent storage)
- **Auto-scaling**: HorizontalPodAutoscaler for backend (2-10 replicas)

## 📋 Requirements

All requirements are met as specified:
- ✅ Web server deployment with multiple replicas and LoadBalancer service
- ✅ Database deployment with single replica and NodePort service
- ✅ Persistent Volume Claim for database persistence
- ✅ HorizontalPodAutoscaler for auto-scaling based on traffic

## 🚀 Quick Start

### 1. Prerequisites
```bash
# Ensure you have Ubuntu VM with minikube, kubectl, and Docker installed
# Follow the complete setup guide in KUBERNETES_DEPLOYMENT.md
```

### 2. Deploy Application
```bash
# Clone the repository
git clone <your-repo-url>
cd fitness-tracker

# Start minikube
minikube start --memory=4096 --cpus=2 --driver=docker
minikube addons enable metrics-server

# Deploy the application
chmod +x scripts/*.sh
./scripts/deploy.sh
```

### 3. Access Application
```bash
# Get URLs
minikube service frontend-service -n fitness-app --url
minikube service backend-service -n fitness-app --url

# Open in browser
minikube service frontend-service -n fitness-app
```

### 4. Monitor & Test
```bash
# Check deployment status
./scripts/monitor.sh

# Test endpoints
./scripts/test-endpoints.sh

# Test auto-scaling
./scripts/load-test.sh
```

## 📁 Project Structure

```
fitness-tracker/
├── k8s/                          # Kubernetes manifests
│   ├── namespace.yaml            # Application namespace
│   ├── mongodb-pvc.yaml          # Persistent volume claim
│   ├── mongodb-deployment.yaml   # MongoDB deployment (1 replica)
│   ├── mongodb-service.yaml      # MongoDB NodePort service
│   ├── configmap.yaml           # Application configuration
│   ├── backend-deployment.yaml   # Backend deployment (3 replicas)
│   ├── backend-service.yaml      # Backend LoadBalancer service
│   ├── frontend-deployment.yaml  # Frontend deployment (2 replicas)
│   ├── frontend-service.yaml     # Frontend LoadBalancer service
│   └── hpa.yaml                 # HorizontalPodAutoscaler
├── scripts/                      # Automation scripts
│   ├── deploy.sh                # Main deployment script
│   ├── cleanup.sh               # Cleanup script
│   ├── monitor.sh               # Monitoring script
│   ├── load-test.sh             # Load testing for HPA
│   └── test-endpoints.sh        # Endpoint testing
├── client/                       # React frontend
├── server/                       # Node.js backend
├── Dockerfile.frontend           # Frontend container
├── Dockerfile.backend            # Backend container
└── docker-compose.yml           # Original Docker Compose (reference)
```

## 🔧 Kubernetes Resources

| Resource | Type | Replicas | Service Type | Purpose |
|----------|------|----------|--------------|---------|
| MongoDB | Deployment | 1 | NodePort | Database with persistent storage |
| Backend | Deployment | 3 | LoadBalancer | API server with auto-scaling |
| Frontend | Deployment | 2 | LoadBalancer | Web interface |

## 📊 Auto-scaling Configuration

The HorizontalPodAutoscaler monitors:
- **CPU Usage**: Scales when average exceeds 70%
- **Memory Usage**: Scales when average exceeds 80%
- **Min Replicas**: 2
- **Max Replicas**: 10

## 🛠️ Useful Commands

```bash
# View all resources
kubectl get all -n fitness-app

# Scale manually
kubectl scale deployment backend-deployment --replicas=5 -n fitness-app

# View logs
kubectl logs -f deployment/backend-deployment -n fitness-app

# Delete everything
./scripts/cleanup.sh
```

## 🔍 Troubleshooting

1. **Pods not starting**: Check `kubectl describe pod <pod-name> -n fitness-app`
2. **Services not accessible**: Verify with `minikube service list`
3. **Images not found**: Ensure Docker daemon is pointed to minikube: `eval $(minikube docker-env)`

## 📝 Assignment Requirements Fulfilled

✅ **Kubernetes deployment using minikube**
✅ **Well-indented YAML files for all resources**
✅ **Web server deployment with multiple replicas and LoadBalancer service**
✅ **Database deployment with single replica and NodePort service**
✅ **Persistent Volume Claim for database persistence**
✅ **HorizontalPodAutoscaler for auto-scaling**
✅ **Docker images bundled with application code**

For detailed instructions, see [KUBERNETES_DEPLOYMENT.md](KUBERNETES_DEPLOYMENT.md) 