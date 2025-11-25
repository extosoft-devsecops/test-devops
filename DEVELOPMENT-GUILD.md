# Development Guild

This document outlines the development practices and guidelines for the Test DevOps application. It covers environment
setup, deployment strategies, and testing procedures to ensure a smooth development workflow.

## Development Environment Setup

- **Docker**: Ensure Docker is installed and running.
- **Kubernetes**: Set up a local Kubernetes cluster using Minikube or Kind.
- **Helm**: Install Helm for managing Kubernetes applications.
- **Kubectl**: Configure kubectl to interact with your Kubernetes cluster.
- **Datadog Agent**: Set up Datadog Agent for monitoring application metrics and logs.

# Build image

```bash
  make build
```

# Run compose localhost

Prerequisites

- *.env* file with the following variables set
  DD_API_KEY=your_datadog_api_key

start the application with datadog agent in docker compose

```bash
make run-compose-localhost
```

stop the application with datadog agent in docker compose

```bash
make stop-compose-localhost
```

# Development and Testing

## Run Unit Tests

ติดตั้ง dependencies ก่อน:

```bash
npm install
```

รัน unit test:

```bash
npx jest
```

หรือ

```bash
npm test
```

## Manual API Testing

- รันแอปพลิเคชัน:
  ```bash
  npm start
  # หรือ
  node index.js
  ```
- ตรวจสอบ endpoint หลัก:
  - เปิดเบราว์เซอร์หรือใช้ curl ไปที่ `http://localhost:3000/`
  - ตรวจสอบ health check:
    ```bash
    curl http://localhost:3000/healthz
    ```

## ทดสอบบน Kubernetes (Docker Desktop)

1. ติดตั้ง dependencies และ build image ตามขั้นตอนด้านบน
2. ติดตั้ง Helm chart (ตัวอย่าง):
   ```bash
   helm install test-devops ./helm/test-devops -f ./helm/test-devops/values.yaml
   ```
3. ตรวจสอบ service และ pod:
   ```bash
   kubectl get pods
   kubectl get svc
   ```
4. ทดสอบ endpoint ผ่าน port-forward:
   ```bash
   kubectl port-forward svc/test-devops 3000:3000
   curl http://localhost:3000/
   ```

## หมายเหตุ
- หากต้องการทดสอบ Datadog Agent ให้ตั้งค่า `DD_API_KEY` ในไฟล์ `.env` หรือผ่าน environment variable
- สามารถดู log และผลลัพธ์การทดสอบได้จาก output ของคำสั่งข้างต้น
