# HashiCorp Vault OSS - Complete Installation Guide

## 📚 Table of Contents

### Part A: Deployment Options
1. [Overview](#overview)
2. [Architecture Comparison](#architecture-comparison)
3. [Prerequisites](#prerequisites)

### Part B: Docker Deployment (Standalone/Development)
4. [Docker Installation](#docker-installation)
5. [Docker Configuration](#docker-configuration)
6. [Docker SSL/TLS Setup](#docker-ssltls-setup)

### Part C: Kubernetes Deployment (Production/HA)
7. [Kubernetes Installation](#kubernetes-installation)
8. [Kubernetes Configuration](#kubernetes-configuration)
9. [Kubernetes SSL/TLS & Ingress](#kubernetes-ssltls--ingress)
10. [High Availability Setup](#high-availability-setup)

### Part D: Common Configuration
11. [Kubernetes Integration](#kubernetes-integration)
12. [CSI Driver Setup](#csi-driver-setup)
13. [Security & Best Practices](#security--best-practices)
14. [Monitoring & Backup](#monitoring--backup)
15. [Troubleshooting](#troubleshooting)

---

## Overview

This comprehensive guide covers **two deployment methods** for HashiCorp Vault OSS (Open Source Software):

### 🐳 Option 1: Docker Deployment
**Best for:**
- Development environments
- Testing and POC
- Single-server deployments
- Quick setup and prototyping

**Components:**
- Vault Server (Docker container)
- NGINX reverse proxy (SSL termination)
- File-based storage backend
- Single instance (non-HA)

### ☸️ Option 2: Kubernetes Deployment
**Best for:**
- Production environments
- High Availability requirements
- Cloud-native architecture
- Scalable infrastructure

**Components:**
- Vault StatefulSet (3+ replicas)
- Integrated Raft storage
- Kubernetes Ingress (NGINX)
- Auto-unseal capabilities
- Production-grade HA

---

## Architecture Comparison

### Docker Architecture
```
┌─────────────────────────────────────┐
│          Internet/Users             │
└──────────────┬──────────────────────┘
               │
        ┌──────▼───────┐
        │ NGINX (443)  │
        │ SSL Terminate│
        └──────┬───────┘
               │
        ┌──────▼───────┐
        │ Vault Server │
        │   (8200)     │
        └──────┬───────┘
               │
        ┌──────▼───────┐
        │ File Storage │
        │  (Volume)    │
        └──────────────┘
```

### Kubernetes Architecture
```
┌──────────────────────────────────────────────┐
│          Internet/External Traffic           │
└──────────────────┬───────────────────────────┘
                   │
            ┌──────▼────────┐
            │ Load Balancer │
            └──────┬────────┘
                   │
            ┌──────▼────────┐
            │ Ingress (TLS) │
            └──────┬────────┘
                   │
   ┌───────────────┼───────────────┐
   │               │               │
┌──▼───┐      ┌────▼───┐      ┌───▼──┐
│Vault │◄─────►Vault  │◄─────►│Vault │
│Pod-0 │      │Pod-1  │       │Pod-2 │
│Active│      │Standby│       │Standby│
└──┬───┘      └───┬───┘       └───┬──┘
   │              │               │
   └──────────────┼───────────────┘
                  │
          ┌───────▼────────┐
          │  Raft Storage  │
          │ (StatefulSet)  │
          └────────────────┘
```

---

## Prerequisites

### Common Requirements
- **Vault CLI**: HashiCorp Vault client
- **kubectl**: Kubernetes CLI (for both options)
- **Domain name**: For SSL certificate
- **SSL certificate**: Cloudflare Origin or Let's Encrypt

### Docker-Specific Requirements
- **Linux server**: Ubuntu 20.04+ / CentOS 8+ / RHEL 8+
- **Docker Engine**: 20.10+
- **Docker Compose**: 2.0+
- **Resources**:
    - CPU: 2 cores minimum
    - Memory: 4GB minimum
    - Storage: 20GB minimum

### Kubernetes-Specific Requirements
- **Kubernetes Cluster**: 1.24+
    - GKE, EKS, AKS, or on-premises
- **Helm**: 3.0+
- **Storage Class**: For PersistentVolumes
- **Ingress Controller**: NGINX Ingress
- **Resources**:
    - CPU: 3 cores minimum (1 core per pod)
    - Memory: 6GB minimum (2GB per pod)
    - Storage: 30GB minimum (10GB per pod)

### Install Prerequisites

```bash
# Install Vault CLI
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm (for Kubernetes deployment)
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verify installations
vault version
kubectl version --client
helm version
```

---

# Part B: Docker Deployment

## Docker Installation

### 1. Project Structure Setup

```bash
# Create directory structure
mkdir -p /opt/vault-nginx/{vault/{config,data,logs},nginx,certs}
cd /opt/vault-nginx

# Verify structure
tree -L 2 /opt/vault-nginx
```

### 2. Docker Compose Configuration

Create `docker-compose.yml`:

### 2. Docker Compose Configuration

Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  vault:
    image: hashicorp/vault:1.18.0
    container_name: vault
    restart: unless-stopped
    cap_add:
      - IPC_LOCK
    environment:
      VAULT_ADDR: http://0.0.0.0:8200
      VAULT_LOG_LEVEL: info
    volumes:
      - ./vault/config:/vault/config:ro
      - ./vault/data:/vault/data
      - ./vault/logs:/vault/logs
    ports:
      - "8200:8200"
    command: "vault server -config=/vault/config/config.hcl"
    networks:
      - vault-network
    healthcheck:
      test: ["CMD", "vault", "status"]
      interval: 10s
      timeout: 5s
      retries: 3

  nginx:
    image: nginx:stable-alpine
    container_name: vault-nginx
    restart: unless-stopped
    depends_on:
      vault:
        condition: service_healthy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx/nginx.conf:/etc/nginx/conf.d/default.conf:ro
      - ./certs:/etc/nginx/ssl:ro
    networks:
      - vault-network
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/health"]
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  vault-network:
    driver: bridge
```

### 3. Start Docker Services

```bash
# Start services
docker-compose up -d

# Check services status
docker-compose ps

# View logs
docker-compose logs -f vault
docker-compose logs -f nginx
```

## Docker Configuration

### 1. Vault Configuration File

Create `vault/config/config.hcl`:

```hcl
ui = true
disable_mlock = true

storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = "true"  # TLS terminated at NGINX
}

api_addr = "http://0.0.0.0:8200"
cluster_addr = "http://0.0.0.0:8201"

# Telemetry for monitoring
telemetry {
  disable_hostname = false
  prometheus_retention_time = "24h"
}
```

### 2. Initialize Vault (First Time Only)

```bash
# Set Vault address
export VAULT_ADDR="https://vault-devops.extosoft.app"
export VAULT_SKIP_VERIFY=true  # Only if using self-signed cert

# Initialize Vault
vault operator init \
  -key-shares=5 \
  -key-threshold=3 \
  -format=json > vault-init-keys.json

# ⚠️ CRITICAL: Backup vault-init-keys.json securely!

# Extract keys
cat vault-init-keys.json | jq -r '.unseal_keys_b64[]' > unseal-keys.txt
cat vault-init-keys.json | jq -r '.root_token' > root-token.txt

# Unseal Vault
vault operator unseal $(sed -n '1p' unseal-keys.txt)
vault operator unseal $(sed -n '2p' unseal-keys.txt)
vault operator unseal $(sed -n '3p' unseal-keys.txt)

# Check status
vault status

# Login
vault login $(cat root-token.txt)
```

### 3. Enable Required Engines

```bash
# Enable KV secrets engine v2
vault secrets enable -path=secret kv-v2

# Enable Kubernetes authentication
vault auth enable kubernetes

# List enabled secrets engines
vault secrets list

# List enabled auth methods
vault auth list
```

## Docker SSL/TLS Setup

### 1. NGINX Configuration

Create `nginx/nginx.conf`:

```nginx
upstream vault {
    server vault:8200;
}

server {
    listen 80;
    server_name vault-devops.extosoft.app;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name vault-devops.extosoft.app;

    # SSL Configuration
    ssl_certificate /etc/nginx/ssl/vault-devops.extosoft.app.pem;
    ssl_certificate_key /etc/nginx/ssl/vault-devops.extosoft.app.key;
    
    # SSL Security
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_prefer_server_ciphers off;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    
    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;

    location / {
        proxy_pass http://vault;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 90;
        proxy_redirect http://vault https://vault-devops.extosoft.app;
    }
}
```

### 2. SSL Certificate Setup

#### Using Cloudflare Origin Certificates:

1. Generate certificate in Cloudflare dashboard
2. Save certificate as `certs/vault-devops.extosoft.app.pem`
3. Save private key as `certs/vault-devops.extosoft.app.key`

```bash
# Set appropriate permissions
chmod 600 certs/vault-devops.extosoft.app.key
chmod 644 certs/vault-devops.extosoft.app.pem
```

## Kubernetes Integration

### 1. Configure Kubernetes Authentication

Create GKE-specific auth configuration script:

```bash
#!/bin/bash
export VAULT_ADDR="https://vault-devops.extosoft.app"
export VAULT_TOKEN="your-vault-token"

# Get GKE cluster information
PROJECT_ID="$(gcloud config get-value project)"
ZONE="$(gcloud config get-value compute/zone)"
CLUSTER_NAME="$(kubectl config current-context | cut -d_ -f3)"
KUBERNETES_NAME="$(kubectl config current-context)"
KUBERNETES_HOST="$(kubectl cluster-info | grep "Kubernetes control plane" | awk '{print $7}')"
KUBERNETES_CA_CERT=$(kubectl config view --raw -o json | \
    jq -r '.clusters[] | select(.name=="'"$KUBERNETES_NAME"'") | .cluster."certificate-authority-data"' | \
    base64 -d)

echo "Project ID: $PROJECT_ID"
echo "Zone: $ZONE"
echo "Cluster Name: $CLUSTER_NAME"
echo "Using Kubernetes context: $KUBERNETES_NAME"
echo "KUBERNETES_HOST: $KUBERNETES_HOST"
echo "KUBERNETES_CA_CERT: $KUBERNETES_CA_CERT"

# Create long-lived service account token for token reviewer
TOKEN_REVIEWER_JWT=$(kubectl create token vault-auth -n vault --duration=87600h)

# Configure Vault Kubernetes auth
vault write auth/kubernetes/config \
    kubernetes_host="$KUBERNETES_HOST" \
    kubernetes_ca_cert="$KUBERNETES_CA_CERT" \
    issuer="https://container.googleapis.com/v1/projects/YOUR_PROJECT/locations/YOUR_ZONE/clusters/YOUR_CLUSTER" \
    token_reviewer_jwt="$TOKEN_REVIEWER_JWT" \
    disable_iss_validation=false
```

### 2. Create Kubernetes Role and Policy

```bash
# Create policy for Kubernetes access
vault policy write k8s-policy - <<EOF
path "secret/data/datadog/*" {
  capabilities = ["read"]
}
path "secret/data/app/*" {
  capabilities = ["read"]
}
EOF

# Create Kubernetes role
vault write auth/kubernetes/role/k8s-app \
    bound_service_account_names=vault-csi-sa \
    bound_service_account_namespaces=your-namespace \
    policies=k8s-policy \
    ttl=24h
```

### 3. Create Service Account and RBAC

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: vault-auth
  namespace: vault
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: vault-csi-role
rules:
- apiGroups: [""]
  resources: ["serviceaccounts/token"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vault-csi-binding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: vault-csi-role
subjects:
- kind: ServiceAccount
  name: vault-csi-sa
  namespace: your-namespace
```

## CSI Driver Setup

### 1. Install Secrets Store CSI Driver

```bash
# Add Helm repository
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo update

# Install CSI Driver
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
    --namespace kube-system \
    --set syncSecret.enabled=true \
    --set enableSecretRotation=true
```

### 2. Install Vault CSI Provider

```bash
# Install Vault CSI Provider
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm install vault-csi-provider hashicorp/vault-csi-provider \
    --namespace csi \
    --create-namespace
```

### 3. Create SecretProviderClass

```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: vault-secrets
  namespace: your-namespace
spec:
  provider: vault
  parameters:
    vaultAddress: "https://vault-devops.extosoft.app"
    roleName: "k8s-app"
    objects: |
      - objectName: "datadog-api-key"
        secretPath: "secret/data/datadog/api"
        secretKey: "api_key"
      - objectName: "datadog-app-key"
        secretPath: "secret/data/datadog/api"
        secretKey: "app_key"
  secretObjects:
  - secretName: datadog-secret
    type: Opaque
    data:
    - objectName: datadog-api-key
      key: api-key
    - objectName: datadog-app-key
      key: app-key
```

### 4. Use in Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: your-app
spec:
  template:
    spec:
      serviceAccountName: vault-csi-sa
      containers:
      - name: app
        image: your-app:latest
        volumeMounts:
        - name: vault-secrets
          mountPath: "/mnt/secrets"
          readOnly: true
      volumes:
      - name: vault-secrets
        csi:
          driver: secrets-store.csi.k8s.io
          readOnly: true
          volumeAttributes:
            secretProviderClass: "vault-secrets"
```

## Sample Secret Management

### 1. Store Secrets in Vault

```bash
# Store Datadog API credentials
vault kv put secret/datadog/api \
    api_key="your-datadog-api-key" \
    app_key="your-datadog-app-key"

# Store database credentials
vault kv put secret/app/database \
    username="dbuser" \
    password="supersecret123"

# Store application configuration
vault kv put secret/app/config \
    environment="production" \
    debug="false" \
    max_connections="100"
```

### 2. Read Secrets (Testing)

```bash
# Read secrets
vault kv get secret/datadog/api
vault kv get secret/app/database
vault kv get secret/app/config

# Get specific field
vault kv get -field=api_key secret/datadog/api
```

## Security Best Practices

### 1. Vault Security
- Use strong unsealing keys and store them securely
- Rotate root token regularly
- Implement least-privilege access policies
- Enable audit logging
- Regular backups of Vault data

### 2. Network Security
- Use TLS everywhere (Vault to NGINX, NGINX to clients)
- Implement firewall rules
- Use private networks for backend communication
- Regular SSL certificate rotation

### 3. Kubernetes Security
- Use dedicated service accounts for each application
- Implement RBAC properly
- Rotate service account tokens
- Monitor and audit access

## Monitoring and Maintenance

### 1. Health Checks

```bash
# Check Vault status
vault status

# Check seal status
vault operator key-status

# Check authentication methods
vault auth list

# Check secrets engines
vault secrets list
```

### 2. Backup Procedures

```bash
# Backup Vault data
docker exec vault-container tar czf /tmp/vault-backup.tar.gz /vault/data

# Copy backup from container
docker cp vault-container:/tmp/vault-backup.tar.gz ./vault-backup-$(date +%Y%m%d).tar.gz
```

### 3. Log Management

```bash
# Check Vault logs
docker logs vault

# Check NGINX logs
docker logs vault-nginx

# Monitor CSI driver logs
kubectl logs -n kube-system daemonset/secrets-store-csi-driver
kubectl logs -n csi deployment/vault-csi-provider
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Vault Initialization Issues
```bash
# Check if Vault is sealed
vault status

# Unseal if needed
vault operator unseal
```

#### 2. SSL Certificate Problems
```bash
# Test SSL configuration
openssl s_client -connect vault-devops.extosoft.app:443

# Check certificate validity
openssl x509 -in certs/vault-devops.extosoft.app.pem -text -noout
```

#### 3. Kubernetes Authentication Failures
```bash
# Check service account token
kubectl create token vault-csi-sa -n your-namespace

# Test Vault authentication manually
vault write auth/kubernetes/login role=k8s-app jwt="$(kubectl create token vault-csi-sa -n your-namespace)"
```

#### 4. CSI Mount Issues
```bash
# Check CSI driver status
kubectl get pods -n kube-system | grep secrets-store
kubectl get pods -n csi | grep vault-csi

# Check SecretProviderClass
kubectl get secretproviderclass -n your-namespace

# Check pod events
kubectl describe pod your-pod-name
```

### Useful Commands

```bash
# Restart Vault services
docker-compose restart

# View all containers
docker-compose ps

# Follow logs
docker-compose logs -f vault
docker-compose logs -f nginx

# Kubernetes debugging
kubectl get events --sort-by=.metadata.creationTimestamp
kubectl logs deployment/your-app
```

## Conclusion

This guide provides a complete setup for HashiCorp Vault OSS with Kubernetes integration. Follow the security best practices and monitoring procedures to maintain a secure and reliable secret management system.

For additional information, refer to:
- [HashiCorp Vault Documentation](https://www.vaultproject.io/docs)
- [Kubernetes Secrets Store CSI Driver](https://secrets-store-csi-driver.sigs.k8s.io/)
- [Vault CSI Provider](https://github.com/hashicorp/vault-csi-provider)