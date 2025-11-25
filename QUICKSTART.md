# 🚀 Quick Start Guide

เลือกวิธี deploy ที่เหมาะกับคุณ:

| วิธีการ | เหมาะสำหรับ | ความซับซ้อน |
|---------|------------|-----------|
| 🐳 [Docker Compose](#1-docker-compose) | Local development ง่ายที่สุด | ⭐ |
| ☸️ [Kubernetes + Helm](#2-kubernetes--helm) | Kubernetes native, Production-ready | ⭐⭐ |
| 🏗️ [Terraform](#3-terraform-infrastructure-as-code) | Infrastructure as Code, Multi-environment | ⭐⭐⭐ |

---

## 1. Docker Compose

**เหมาะสำหรับ:** Local development, ทดสอบ features

### 📦 Requirements

- Docker Desktop
- Docker Compose

### 🚀 Deploy

**Step 1: เตรียม Environment Variables**

สร้างไฟล์ `.env`:

```bash
DD_API_KEY=<YOUR_DATADOG_API_KEY>
```

**Step 2: Run Application**

```bash
docker compose -f docker-compose-localhost.yaml --env-file .env up --build
```

**Step 3: Access Application**

```bash
open http://localhost:3000
# หรือ
curl http://localhost:3000/
```

### 📋 Management Commands

```bash
# ดู status
docker-compose -f docker-compose-localhost.yaml ps

# ดู logs
docker-compose -f docker-compose-localhost.yaml logs -f

# Restart
docker-compose -f docker-compose-localhost.yaml restart

# Stop
docker-compose -f docker-compose-localhost.yaml down
```

### ✅ Features

- ✅ Simple one-command deployment
- ✅ Hot reload support
- ✅ Easy debugging
- ✅ Quick iteration

---

## 2. Kubernetes + Helm

**เหมาะสำหรับ:** Production deployment, Advanced features

### 📦 Requirements

- Docker Desktop with Kubernetes enabled
- kubectl
- Helm 3.x
- Docker image built

### 🚀 Deploy

**Step 1: Enable Kubernetes**

```text
Docker Desktop → Settings → Kubernetes → ✅ Enable Kubernetes → Apply
```

**Step 2: Build Docker Image**

```bash
docker build -t test-devops:latest .
```

**Step 3: Deploy with Helm**

**Option A: Without Monitoring (Quick Start)**

```bash
helm install test-devops ./helm/test-devops \
  --namespace test-devops \
  --create-namespace \
  --wait
```

**Option B: With Datadog Monitoring**

```bash
helm install test-devops ./helm/test-devops \
  --namespace test-devops \
  --create-namespace \
  --set datadog.enabled=true \
  --set datadog.apiKey=<YOUR_DATADOG_API_KEY> \
  --wait
```

> 💡 **Get Datadog API Key:** [https://app.datadoghq.com/organization-settings/api-keys](https://app.datadoghq.com/organization-settings/api-keys)

**Step 4: Access Application**

```bash
open http://localhost:30080
# หรือ
curl http://localhost:30080/
```

### 📋 Management Commands

```bash
# ดู resources
kubectl get all -n test-devops

# ดู pods
kubectl get pods -n test-devops

# ดู logs
kubectl logs -n test-devops -l app.kubernetes.io/name=test-devops -f

# Update configuration
helm upgrade test-devops ./helm/test-devops -n test-devops

# Rollback
helm rollback test-devops -n test-devops

# Uninstall
helm uninstall test-devops -n test-devops
```

### 🔄 Update Workflow

```bash
# 1. แก้ไขโค้ด
vim index.js

# 2. Build image ใหม่
docker build -t test-devops:latest .

# 3. Restart pods
kubectl rollout restart deployment/test-devops-test-devops -n test-devops

# หรือ upgrade helm
helm upgrade test-devops ./helm/test-devops -n test-devops --wait
```

### ✅ Features

- ✅ Health checks (liveness & readiness)
- ✅ Resource limits & requests
- ✅ Auto-restart on failure
- ✅ Service discovery
- ✅ ConfigMap & Secrets support
- ✅ Optional: Datadog monitoring
- ✅ Optional: Prometheus metrics
- ✅ Optional: Horizontal Pod Autoscaler

---

## 3. Terraform (Infrastructure as Code)

**เหมาะสำหรับ:** Production, Multi-environment, GitOps

### 📦 Requirements

- Terraform >= 1.0
- Docker Desktop with Kubernetes enabled
- kubectl
- Docker image built

### 🚀 Deploy

**Step 1: Install Terraform**

```bash
# macOS
brew install terraform

# Verify
terraform version
```

**Step 2: Configure**

```bash
cd terraform

# สร้าง configuration file
cp terraform.tfvars.example terraform.tfvars

# แก้ไข values
vim terraform.tfvars
```

**Example `terraform.tfvars`:**

```hcl
# Kubernetes
kubeconfig_path = "~/.kube/config"
kube_context    = "docker-desktop"
namespace       = "test-devops-tf"
environment     = "local"

# Application
image_repository = "test-devops"
image_tag        = "latest"
replica_count    = 1

# Service
service_type      = "NodePort"
service_node_port = 30080

# Monitoring
datadog_enabled = true
datadog_api_key = "<YOUR_DATADOG_API_KEY>"
```

**Step 3: Build Image**

```bash
cd ..
docker build -t test-devops:latest .
cd terraform
```

**Step 4: Deploy**

```bash
# Initialize (first time only)
terraform init

# Preview changes
terraform plan

# Deploy
terraform apply

# หรือ auto-approve
terraform apply -auto-approve
```

**Step 5: Verify**

```bash
# ดู outputs
terraform output

# Access application
open http://localhost:30080
```

### 📋 Management Commands

**View State:**

```bash
# Current state
terraform show

# Outputs
terraform output
terraform output deployment_info

# Resource list
terraform state list

# Refresh state
terraform refresh
```

**Update Resources:**

```bash
# Scale replicas
terraform apply -var="replica_count=3"

# Update image
terraform apply -var="image_tag=v2.0.0"

# Enable autoscaling
terraform apply -var="autoscaling_enabled=true"

# Change service type
terraform apply -var="service_type=LoadBalancer"
```

**Manage Environment:**

```bash
# Local
terraform apply \
  -var="environment=local" \
  -var="kube_context=docker-desktop"

# Development (GKE)
terraform apply \
  -var="environment=develop" \
  -var="kube_context=gke_project_region_cluster" \
  -var="image_repository=gcr.io/project/image"

# UAT/Production
terraform apply \
  -var="environment=uat" \
  -var="replica_count=2" \
  -var="autoscaling_enabled=true"
```

**Destroy:**

```bash
terraform destroy
# หรือ
terraform destroy -auto-approve
```

### 🔒 Security Best Practices

**Use Environment Variables for Secrets:**

```bash
export TF_VAR_datadog_api_key="your-api-key"
terraform apply
```

**Or use separate secrets file:**

```bash
# สร้าง secrets.tfvars (เพิ่มใน .gitignore)
echo 'datadog_api_key = "your-key"' > secrets.tfvars

# Apply with secrets
terraform apply -var-file="secrets.tfvars"
```

### 🛠️ Development Workflow

```bash
# 1. แก้ไขโค้ด
vim ../index.js

# 2. Build image
docker build -t test-devops:latest ..

# 3. Update infrastructure
terraform apply -var="image_tag=latest"

# 4. Verify
kubectl get pods -n test-devops-tf
curl http://localhost:30080
```

### ✅ Features

- ✅ Infrastructure as Code (version controlled)
- ✅ Automated namespace & secrets creation
- ✅ Idempotent deployments
- ✅ State management
- ✅ Multi-environment support
- ✅ Dependency management
- ✅ Plan before apply
- ✅ Easy rollback
- ✅ Integration with CI/CD

---

## 📊 Comparison

| Feature | Docker Compose | Kubernetes + Helm | Terraform |
|---------|---------------|-------------------|-----------|
| Setup Time | ⚡ 1 min | ⚡⚡ 5 min | ⚡⚡⚡ 10 min |
| Learning Curve | ⭐ Easy | ⭐⭐ Medium | ⭐⭐⭐ Advanced |
| Production Ready | ❌ No | ✅ Yes | ✅ Yes |
| Scalability | ❌ Limited | ✅ Excellent | ✅ Excellent |
| Multi-Environment | ❌ No | ⚠️ Manual | ✅ Yes |
| Infrastructure as Code | ❌ No | ⚠️ Partial | ✅ Yes |
| Auto-scaling | ❌ No | ✅ Yes | ✅ Yes |
| Health Checks | ❌ Basic | ✅ Advanced | ✅ Advanced |
| Rollback | ⚠️ Manual | ✅ Easy | ✅ Easy |
| State Management | ❌ No | ⚠️ Helm | ✅ Terraform |

---

## 📚 Additional Resources

- **Helm Chart Documentation**: [`helm/test-devops/README.md`](helm/test-devops/README.md)
- **Helm Values Reference**: [`helm/test-devops/values.yaml`](helm/test-devops/values.yaml)
- **Terraform Guide**: [`terraform/README.md`](terraform/README.md)
- **Datadog Setup**: [`helm/test-devops/DATADOG.md`](helm/test-devops/DATADOG.md)

---

## 🆘 Troubleshooting

### Docker Compose

```bash
# Port already in use
docker-compose -f docker-compose-localhost.yaml down
lsof -ti:3000 | xargs kill -9

# Rebuild from scratch
docker-compose -f docker-compose-localhost.yaml down -v
docker-compose -f docker-compose-localhost.yaml up --build
```

### Kubernetes + Helm

```bash
# Helm install failed
helm uninstall test-devops -n test-devops
kubectl delete namespace test-devops
helm install test-devops ./helm/test-devops --namespace test-devops --create-namespace

# Pods not starting
kubectl describe pod <pod-name> -n test-devops
kubectl logs <pod-name> -n test-devops

# Port already in use
kubectl get svc -A | grep 30080
kubectl delete svc <service-name> -n <namespace>
```

### Terraform

```bash
# State locked
terraform force-unlock <lock-id>

# State out of sync
terraform refresh

# Start fresh
terraform destroy -auto-approve
rm -rf .terraform terraform.tfstate*
terraform init
terraform apply

# Validation errors
terraform fmt
terraform validate
```

---

## 🎉 Happy Testing

