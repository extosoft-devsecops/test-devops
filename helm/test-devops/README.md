# Test DevOps Helm Chart

Helm chart สำหรับทดสอบ Node.js application บน Docker Desktop Kubernetes

## Prerequisites

- Docker Desktop with Kubernetes enabled
- kubectl configured
- helm 3.x installed

## Quick Start

### 1. Build & Deploy

**Without Datadog (Local Testing):**

```bash
# จาก root ของ project
./helm/test-devops/deploy.sh
```

**With Datadog:**

```bash
# Build Docker image
docker build -t test-devops:latest .

# Deploy with Helm + Datadog
helm upgrade --install test-devops ./helm/test-devops \
  --namespace test-devops \
  --create-namespace \
  --set datadog.apiKey=<YOUR_DATADOG_API_KEY> \
  --wait
```

หรือ

```bash
# Build Docker image
docker build -t test-devops:latest .

# Deploy with Helm
helm upgrade --install test-devops ./helm/test-devops \
  --namespace test-devops \
  --create-namespace \
  --wait
```

### 2. Access Application

```bash
# เปิดบราวเซอร์
open http://localhost:30080

# หรือใช้ curl
curl http://localhost:30080/

# Health check
curl http://localhost:30080/healthz
```

## Configuration

### values.yaml

```yaml
replicaCount: 1              # จำนวน pods

image:
  repository: test-devops    # Docker image name
  tag: latest                # Image tag
  pullPolicy: IfNotPresent   # Pull policy

service:
  type: NodePort             # Service type
  port: 3000                 # Service port
  nodePort: 30080           # NodePort (localhost:30080)

env:
  serviceName: test-devops   # Service name
  nodeEnv: local             # Environment
  enableMetrics: "true"      # Enable metrics logging

datadog:
  enabled: true              # Enable/disable Datadog Agent
  apiKey: ""                # Set via --set or leave empty for local testing
```

**📊 Datadog Agent:**

See [DATADOG.md](DATADOG.md) for complete Datadog configuration guide.

Quick examples:
```bash
# Deploy with Datadog
helm install test-devops ./helm/test-devops \
  --set datadog.apiKey=<YOUR_KEY> \
  -n test-devops

# Deploy without Datadog (local testing)
helm install test-devops ./helm/test-devops \
  --set datadog.enabled=false \
  -n test-devops

# Enable APM
helm install test-devops ./helm/test-devops \
  --set datadog.apiKey=<YOUR_KEY> \
  --set datadog.agent.apm.enabled=true \
  -n test-devops
```

## Commands

### View Resources

```bash
# Get pods
kubectl get pods -n test-devops

# Get services
kubectl get svc -n test-devops

# Get all
kubectl get all -n test-devops
```

### View Logs

```bash
# Follow logs
kubectl logs -n test-devops -l app.kubernetes.io/name=test-devops -f

# Last 50 lines
kubectl logs -n test-devops -l app.kubernetes.io/name=test-devops --tail=50
```

### Update Deployment

```bash
# After code changes
docker build -t test-devops:latest .

# Restart pods to use new image
kubectl rollout restart deployment -n test-devops

# Or redeploy with Helm
helm upgrade test-devops ./helm/test-devops -n test-devops
```

### Uninstall

```bash
# Remove Helm release
helm uninstall test-devops -n test-devops

# Delete namespace
kubectl delete namespace test-devops
```

## Testing

### Test Endpoints

```bash
# Home page
curl http://localhost:30080/

# Health check
curl http://localhost:30080/healthz
```

### Expected Output

**Home page:**
```html
<h1>Test DevOps App</h1>
<p>Sending metrics via Datadog DogStatsD</p>
<p>Environment: <strong>local</strong></p>
```

**Health check:**
```json
{"status":"ok","uptime":123.456}
```

**Logs (metrics):**
```
📊 core.random_delay = 123ms
📊 core.random_delay = 456ms
📊 core.random_delay = 789ms
```

## Troubleshooting

### Pod not starting

```bash
# Describe pod
kubectl describe pod -n test-devops <pod-name>

# Check events
kubectl get events -n test-devops --sort-by='.lastTimestamp'
```

### Image not found

```bash
# Rebuild image
docker build -t test-devops:latest .

# Check images
docker images | grep test-devops
```

### Cannot access localhost:30080

```bash
# Check service
kubectl get svc -n test-devops

# Use port-forward instead
kubectl port-forward -n test-devops svc/test-devops-test-devops 3000:3000
```

## Files Structure

```
helm/test-devops/
├── Chart.yaml              # Chart metadata
├── values.yaml             # Default values
├── deploy.sh              # Deploy script
├── README.md              # This file
└── templates/
    ├── _helpers.tpl       # Template helpers
    ├── deployment.yaml    # Deployment manifest
    ├── service.yaml       # Service manifest
    └── NOTES.txt         # Post-install notes
```

## Features

✅ NodePort service (port 30080)  
✅ Health checks (liveness & readiness)  
✅ Resource limits  
✅ Metrics logging  
✅ Easy deployment script  
✅ Docker Desktop optimized  

## Next Steps

1. แก้โค้ดใน `index.js`
2. Build image ใหม่: `docker build -t test-devops:latest .`
3. Restart deployment: `kubectl rollout restart deployment -n test-devops`
4. ทดสอบ: `curl http://localhost:30080/`

---

**Happy Testing! 🚀**

