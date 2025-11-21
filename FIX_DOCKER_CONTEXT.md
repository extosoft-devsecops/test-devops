# ⚠️ แก้ไข: no context exists with the name: "docker-desktop"

## สาเหตุ
Kubernetes ยังไม่ได้เปิดใช้งานใน Docker Desktop

---

## ⚡ วิธีแก้ไข (เลือก 1 วิธี)

### 🎯 วิธีที่ 1: ใช้ Setup Script (ง่ายที่สุด)

```bash
cd helm/app
make local-setup
```

Script จะแนะนำทีละขั้นตอน

---

### 🐳 วิธีที่ 2: เปิด Kubernetes ใน Docker Desktop

#### macOS:
1. เปิด Docker Desktop
2. คลิก **Preferences** (หรือกด `⌘ + ,`)
3. ไปที่แท็บ **Kubernetes**
4. ✅ เลือก **Enable Kubernetes**
5. คลิก **Apply & Restart**
6. รอ 2-5 นาที

#### Windows:
1. เปิด Docker Desktop
2. คลิก Settings icon (⚙️)
3. ไปที่ **Kubernetes**
4. ✅ เลือก **Enable Kubernetes**
5. คลิก **Apply & Restart**
6. รอ 2-5 นาที

#### ตรวจสอบว่าพร้อม:
```bash
kubectl config get-contexts
kubectl get nodes
```

ควรเห็น:
```
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   1m    v1.28.x
```

---

### 🚀 วิธีที่ 3: ใช้ Minikube (ทางเลือก)

```bash
# Install
brew install minikube

# Start
minikube start --driver=docker --cpus=4 --memory=4096

# ตรวจสอบ
kubectl get nodes
```

---

### 🎪 วิธีที่ 4: ใช้ Kind

```bash
# Install
brew install kind

# Create cluster
kind create cluster --name test-devops

# ตรวจสอบ
kubectl get nodes
```

---

### 📦 วิธีที่ 5: ใช้ Docker Compose แทน (ไม่ต้องใช้ K8s)

```bash
# จาก root ของ project
cd ../..
make run-localhost

# เข้าถึง
open http://localhost:3000
```

---

## ✅ หลังแก้แล้ว

```bash
cd helm/app
make local-start
```

---

## 📚 อ่านเพิ่มเติม

- **คำแนะนำละเอียด**: `helm/FIX_NO_DOCKER_DESKTOP_CONTEXT.md`
- **Setup guide**: `helm/DOCKER_DESKTOP_K8S_SETUP.md`
- **Full guide**: `helm/LOCAL_TESTING_GUIDE.md`

---

## 🆘 ยังมีปัญหา?

ดูที่: `helm/FIX_NO_DOCKER_DESKTOP_CONTEXT.md`

