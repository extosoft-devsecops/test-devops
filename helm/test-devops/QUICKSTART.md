# 🚀 Quick Start - Docker Desktop Kubernetes

## ขั้นตอนง่ายๆ 3 ขั้น

### 1️⃣ เปิด Kubernetes ใน Docker Desktop

```
Docker Desktop → Settings → Kubernetes → ✅ Enable Kubernetes → Apply
```

รอ 2-5 นาที จนเห็น "Kubernetes is running" สีเขียว

### 2️⃣ Deploy Application

```bash
# จาก root ของ project
cd /Users/kongnb2k/workspaces/extosoft/dev-opts/test-devops

# รัน deploy script
./helm/test-devops/deploy.sh
```

### 3️⃣ เข้าถึง Application

```bash
# เปิดบราวเซอร์
open http://localhost:30080

# หรือทดสอบด้วย curl
curl http://localhost:30080/
```

---

## ✅ สิ่งที่ได้

- ✅ Deployment บน Kubernetes
- ✅ Service (NodePort 30080)
- ✅ Health checks (liveness & readiness)
- ✅ Resource limits
- ✅ Metrics logging

---

## 📋 Commands

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

## 🔧 แก้โค้ดและ Deploy ใหม่

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

