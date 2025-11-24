# 🚀 Quick Start

## 1. Quick Start - Docker Desktop Compose

### ขั้นตอนง่ายๆ 2 ขั้น

#### 1️⃣ Build & Run Application

.env ตัวอย่าง
```bash
DD_API_KEY=<YOUR_DATADOG_API_KEY>
```

```bash
# รัน Docker Compose
docker compose -f docker-compose-localhost.yaml --env-file .env up --build
```

#### 2️⃣ เข้าถึง Application

```bash
# เปิดบราวเซอร์
open http://localhost:3000

# หรือทดสอบด้วย curl
curl http://localhost:3000/
```

---

### ✅ สิ่งที่ได้

- ✅ Application running on Docker
- ✅ Port mapping (3000)
- ✅ Easy local development

---

### 📋 Commands

```bash
# ดู containers
docker-compose -f docker-compose-localhost.yaml ps

# ดู logs
docker-compose -f docker-compose-localhost.yaml logs -f

# หยุด containers
docker-compose -f docker-compose-localhost.yaml down
```

---

### 🔧 แก้โค้ดและ Deploy ใหม่

```bash
# 1. แก้โค้ดใน index.js
vim index.js

# 2. Restart containers
docker-compose -f docker-compose-localhost.yaml restart
```

---

## 2. Quick Start - Docker Desktop Kubernetes

### ขั้นตอนง่ายๆ 3 ขั้น

#### 1️⃣ เปิด Kubernetes ใน Docker Desktop

```
Docker Desktop → Settings → Kubernetes → ✅ Enable Kubernetes → Apply
```

#### 2️⃣ Build & Deploy Application

```bash
# 1. สร้าง Docker image
docker build -t test-devops:latest .

# 2. Deploy ด้วย Helm (เลือก 1 จาก 2 วิธี)

# วิธีที่ 1: Deploy without Datadog (เหมาะสำหรับการทดสอบ)
helm install test-devops ./helm/test-devops \
  --namespace test-devops \
  --create-namespace \
  --wait

# วิธีที่ 2: Deploy with Datadog (สำหรับ monitoring แบบเต็มรูปแบบ)
# ต้องมี Datadog API Key จาก https://app.datadoghq.com/organization-settings/api-keys
helm install test-devops ./helm/test-devops \
  --namespace test-devops \
  --create-namespace \
  --set datadog.apiKey=<YOUR_DATADOG_API_KEY> \
  --set datadog.enabled=true \
  --wait
```

> **💡 วิธีหา Datadog API Key:**
> 1. ไปที่ [Datadog API Keys](https://app.datadoghq.com/organization-settings/api-keys)
> 2. คลิก "New Key" หรือคัดลอก key ที่มีอยู่
> 3. นำ API Key มาใส่แทน `<YOUR_DATADOG_API_KEY>`
> 4. หรือเก็บไว้ในไฟล์ `.env` และใช้คำสั่ง: `--set datadog.apiKey=$DD_API_KEY`


#### 3️⃣ เข้าถึง Application

```bash
# เปิดบราวเซอร์
open http://localhost:30080

# หรือทดสอบด้วย curl
curl http://localhost:30080/
```

---

### ✅ สิ่งที่ได้

- ✅ Deployment บน Kubernetes
- ✅ Service (NodePort 30080)
- ✅ Health checks (liveness & readiness)
- ✅ Resource limits
- ✅ Metrics logging

---

### 📋 Commands

```bash
# ดู pods
kubectl get pods -n test-devops

# ดู logs
kubectl logs -n test-devops -l app.kubernetes.io/name=test-devops -f

# ดู service
kubectl get svc -n test-devops

# ลบ deployment
helm uninstall test-devops -n test-devops
```

---

### 🔧 แก้โค้ดและ Deploy ใหม่

```bash
# 1. แก้โค้ดใน index.js
vim index.js

# 2. Build image ใหม่
docker build -t test-devops:latest .

# 3. Restart pods
kubectl rollout restart deployment -n test-devops
```

---

## 📚 เอกสารเพิ่มเติม

- **Full README**: `helm/test-devops/README.md`
- **Helm values**: `helm/test-devops/values.yaml`

---

**Happy Testing! 🎉**

