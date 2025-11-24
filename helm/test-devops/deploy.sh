#!/bin/bash

# Deploy script for Docker Desktop Kubernetes
set -e

NAMESPACE="test-devops"
RELEASE_NAME="test-devops"
CHART_PATH="./helm/test-devops"

echo "🚀 Deploying Test DevOps to Docker Desktop Kubernetes"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl."
    exit 1
fi

# Check if helm is available
if ! command -v helm &> /dev/null; then
    echo "❌ helm not found. Please install helm."
    exit 1
fi

# Check Kubernetes connection
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster"
    echo "Please ensure Kubernetes is running in Docker Desktop"
    exit 1
fi

echo "✅ Prerequisites checked"
echo ""

# Build Docker image
echo "🔨 Building Docker image..."
docker build -t test-devops:latest .

if [ $? -ne 0 ]; then
    echo "❌ Docker build failed"
    exit 1
fi

echo "✅ Docker image built successfully"
echo ""

# Create namespace if not exists
echo "📦 Creating namespace: $NAMESPACE"
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Deploy with Helm
echo "🚢 Deploying with Helm..."
helm upgrade --install $RELEASE_NAME $CHART_PATH \
    --namespace $NAMESPACE \
    --wait \
    --timeout 2m

echo ""
echo "✅ Deployment completed!"
echo ""

# Show status
echo "📊 Deployment Status:"
kubectl get pods -n $NAMESPACE
echo ""
kubectl get svc -n $NAMESPACE

echo ""
echo "🌐 Access your application at: http://localhost:30080"
echo ""
echo "📋 View logs with:"
echo "   kubectl logs -n $NAMESPACE -l app.kubernetes.io/name=test-devops -f"
echo ""

