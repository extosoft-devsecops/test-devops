# Terraform Configuration for Test DevOps

Terraform configuration สำหรับ deploy Helm chart ไปยัง Kubernetes cluster

## 📁 โครงสร้าง

```
terraform/
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Variable definitions
├── outputs.tf                   # Output definitions
├── terraform.tfvars.example     # Example variables file
├── values/                      # Helm values per environment
│   ├── local.yaml
│   ├── develop.yaml
│   ├── uat.yaml
│   └── production.yaml
└── README.md
```

## 🚀 Quick Start

### 1. ติดตั้ง Prerequisites

```bash
# Install Terraform
brew install terraform

# Verify installation
terraform version
```

### 2. เตรียม Configuration

```bash
cd terraform

# Copy example variables file
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values
vim terraform.tfvars
```

### 3. Deploy

```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply changes
terraform apply

# Or apply with auto-approve
terraform apply -auto-approve
```

## 📋 Configuration Examples

### Local Development (Docker Desktop)

```hcl
# terraform.tfvars
kubeconfig_path = "~/.kube/config"
kube_context    = "docker-desktop"
namespace       = "test-devops"
environment     = "local"

image_repository = "test-devops"
image_tag        = "latest"
replica_count    = 1

service_type      = "NodePort"
service_node_port = 30080

datadog_enabled = false
```

### Development Environment (GKE)

```hcl
# terraform.tfvars
kube_context     = "gke_test-devops-478606_asia-southeast1_gke-nonprod"
environment      = "develop"

image_repository = "asia-southeast1-docker.pkg.dev/test-devops-478606/test-devops-images/test-devops"
image_tag        = "develop-abc1234"
replica_count    = 1

service_type = "LoadBalancer"

datadog_enabled = true
datadog_api_key = "your-datadog-api-key"
```

### UAT Environment

```hcl
# terraform.tfvars
kube_context = "gke_test-devops-478606_asia-southeast1_gke-nonprod"
environment  = "uat"

image_repository = "asia-southeast1-docker.pkg.dev/test-devops-478606/test-devops-images/test-devops"
image_tag        = "main-def5678"
replica_count    = 2

service_type = "LoadBalancer"

autoscaling_enabled      = true
autoscaling_min_replicas = 2
autoscaling_max_replicas = 10

datadog_enabled    = true
datadog_api_key    = "your-datadog-api-key"
prometheus_enabled = true
```

## 🔧 Common Commands

### Deploy

```bash
# Deploy to local
terraform apply -var="environment=local"

# Deploy to develop
terraform apply -var="environment=develop" -var="image_tag=develop-abc1234"

# Deploy to UAT
terraform apply -var="environment=uat" -var="image_tag=main-def5678"

# Deploy with specific Datadog key
terraform apply -var="datadog_enabled=true" -var="datadog_api_key=YOUR_KEY"
```

### Manage

```bash
# Show current state
terraform show

# List resources
terraform state list

# Get outputs
terraform output

# Show deployment info
terraform output deployment_info

# Refresh state
terraform refresh
```

### Update

```bash
# Update image tag
terraform apply -var="image_tag=new-version"

# Scale replicas
terraform apply -var="replica_count=3"

# Enable autoscaling
terraform apply -var="autoscaling_enabled=true"
```

### Destroy

```bash
# Destroy all resources
terraform destroy

# Destroy with auto-approve
terraform destroy -auto-approve

# Destroy specific resource
terraform destroy -target=helm_release.test_devops
```

## 📊 Outputs

หลังจาก apply สำเร็จ จะได้ outputs:

```bash
namespace          = "test-devops"
release_name       = "test-devops"
release_status     = "deployed"
release_version    = "1"
app_version        = "1.0.0"
chart_version      = "1.0.0"
service_endpoint   = "http://localhost:30080"

deployment_info = {
  namespace          = "test-devops"
  release_name       = "test-devops"
  image              = "test-devops:latest"
  replicas           = 1
  autoscaling        = false
  datadog_enabled    = true
  prometheus_enabled = false
  environment        = "local"
}
```

## 🔐 Sensitive Variables

สำหรับ sensitive data เช่น Datadog API key:

### วิธีที่ 1: ใช้ Environment Variables

```bash
export TF_VAR_datadog_api_key="your-api-key"
terraform apply
```

### วิธีที่ 2: ใช้ .tfvars file (ห้ามเก็บใน Git)

```bash
# Create secrets.tfvars (add to .gitignore)
echo 'datadog_api_key = "your-api-key"' > secrets.tfvars

# Apply with secrets file
terraform apply -var-file="secrets.tfvars"
```

### วิธีที่ 3: Interactive Input

```bash
# Terraform will prompt for sensitive variables
terraform apply
```

## 🎯 Use Cases

### Deploy บน Docker Desktop

```bash
terraform apply \
  -var="kube_context=docker-desktop" \
  -var="environment=local" \
  -var="image_repository=test-devops" \
  -var="image_tag=latest"
```

### Deploy บน GKE with Datadog

```bash
terraform apply \
  -var="kube_context=gke_project_region_cluster" \
  -var="environment=develop" \
  -var="image_repository=asia-southeast1-docker.pkg.dev/project/repo/image" \
  -var="image_tag=develop-abc1234" \
  -var="datadog_enabled=true" \
  -var="datadog_api_key=$DATADOG_API_KEY"
```

### Enable Autoscaling

```bash
terraform apply \
  -var="autoscaling_enabled=true" \
  -var="autoscaling_min_replicas=2" \
  -var="autoscaling_max_replicas=10"
```

## 🔍 Troubleshooting

### ตรวจสอบ Kubernetes resources

```bash
kubectl get all -n test-devops
kubectl get pods -n test-devops
kubectl logs -n test-devops -l app.kubernetes.io/name=test-devops
```

### Debug Terraform

```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply

# Validate configuration
terraform validate

# Format code
terraform fmt
```

## 📚 Additional Resources

- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [Helm Chart Documentation](../helm/test-devops/README.md)

## ⚠️ Important Notes

1. **State Management**: ใช้ remote backend (GCS, S3) สำหรับ production
2. **Secrets**: ห้ามเก็บ API keys ใน Git
3. **Workspace**: ใช้ Terraform workspaces สำหรับ multi-environment
4. **Backup**: Backup Terraform state file เสมอ
5. **Review**: Review `terraform plan` ก่อน apply ทุกครั้ง

Happy Deploying! 🎉
