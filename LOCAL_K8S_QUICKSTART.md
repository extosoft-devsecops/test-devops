# 🧪 Local Kubernetes Testing - Quick Start

## ⚡ Quick Start (3 Steps)

### 1️⃣ Enable Kubernetes in Docker Desktop
```
Docker Desktop → Settings → Kubernetes → ✅ Enable Kubernetes → Apply & Restart
```

### 2️⃣ Switch Context
```bash
kubectl config use-context docker-desktop
kubectl get nodes  # ตรวจสอบว่าทำงาน
```

### 3️⃣ Deploy
```bash
cd helm/app
make local-start
```

## 🌐 Access Application
```
http://localhost:30080
```

## 📋 Commands

| Command | Description |
|---------|-------------|
| `make local-start` | Build + Deploy |
| `make local-status` | ดู status |
| `make local-logs` | ดู logs |
| `make local-test` | ทดสอบ app |
| `make local-stop` | หยุด |
| `make local-cleanup` | ลบทั้งหมด |

## 📚 Documentation

- **Setup Guide**: `helm/DOCKER_DESKTOP_K8S_SETUP.md`
- **Full Guide**: `helm/LOCAL_TESTING_GUIDE.md`
- **Helm README**: `helm/app/README.md`

---

**Ready to test! 🚀**

