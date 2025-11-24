# Datadog Agent Configuration

## Overview

Helm chart นี้รวม Datadog Agent DaemonSet เพื่อ monitor application และ collect metrics

## Features

✅ **DogStatsD** - รับ metrics จาก application  
✅ **Log Collection** - collect logs จาก containers  
✅ **Process Monitoring** - monitor processes (optional)  
✅ **APM** - Application Performance Monitoring (optional)  

---

## Quick Start

### 1. Enable Datadog Agent

```yaml
# values.yaml
datadog:
  enabled: true
  apiKey: "your-datadog-api-key"
```

### 2. Deploy with API Key

```bash
helm upgrade --install test-devops ./helm/test-devops \
  --namespace test-devops \
  --set datadog.apiKey=<YOUR_DATADOG_API_KEY>
```

---

## Configuration

### Basic Configuration

```yaml
datadog:
  enabled: true              # Enable/disable Datadog Agent
  apiKey: ""                # Datadog API Key
  site: "datadoghq.com"     # Datadog site (datadoghq.com, datadoghq.eu, etc.)
```

### DogStatsD

```yaml
datadog:
  agent:
    dogstatsd:
      enabled: true          # Enable DogStatsD
      port: 8125            # DogStatsD port
      useHostPort: true     # Use host port for DogStatsD
      nonLocalTraffic: true # Accept metrics from pods
```

### APM (Application Performance Monitoring)

```yaml
datadog:
  agent:
    apm:
      enabled: true         # Enable APM
      port: 8126           # APM port
```

### Log Collection

```yaml
datadog:
  agent:
    logs:
      enabled: true                  # Enable log collection
      containerCollectAll: true      # Collect from all containers
```

### Process Monitoring

```yaml
datadog:
  agent:
    processAgent:
      enabled: true         # Enable process monitoring
```

---

## Deployment Examples

### Example 1: Basic (DogStatsD only)

```bash
helm upgrade --install test-devops ./helm/test-devops \
  --namespace test-devops \
  --set datadog.enabled=true \
  --set datadog.apiKey=<YOUR_KEY>
```

### Example 2: With APM

```bash
helm upgrade --install test-devops ./helm/test-devops \
  --namespace test-devops \
  --set datadog.enabled=true \
  --set datadog.apiKey=<YOUR_KEY> \
  --set datadog.agent.apm.enabled=true
```

### Example 3: Full Monitoring

```bash
helm upgrade --install test-devops ./helm/test-devops \
  --namespace test-devops \
  --set datadog.enabled=true \
  --set datadog.apiKey=<YOUR_KEY> \
  --set datadog.agent.apm.enabled=true \
  --set datadog.agent.processAgent.enabled=true
```

### Example 4: Without Datadog (Local Testing)

```bash
helm upgrade --install test-devops ./helm/test-devops \
  --namespace test-devops \
  --set datadog.enabled=false
```

---

## Verify Deployment

### Check Datadog Agent Pods

```bash
kubectl get pods -n test-devops -l app=datadog-agent
```

Expected output:
```
NAME                                      READY   STATUS    RESTARTS   AGE
test-devops-test-devops-datadog-agent-xxx 1/1     Running   0          1m
```

### Check Agent Logs

```bash
kubectl logs -n test-devops -l app=datadog-agent --tail=50
```

### Check Agent Status

```bash
POD=$(kubectl get pods -n test-devops -l app=datadog-agent -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n test-devops $POD -- agent status
```

---

## Application Integration

Application จะส่ง metrics ผ่าน environment variables:

```yaml
env:
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP    # Auto-inject node IP
- name: DD_DOGSTATSD_PORT
  value: "8125"
```

### Example Code (Node.js)

```javascript
const StatsD = require('hot-shots');

const dogstatsd = new StatsD({
  host: process.env.DD_AGENT_HOST,
  port: process.env.DD_DOGSTATSD_PORT
});

// Send metrics
dogstatsd.increment('my_app.request_count');
dogstatsd.histogram('my_app.response_time', 123);
```

---

## Metrics in Datadog

### View Metrics

1. Go to https://app.datadoghq.com
2. Navigate to **Metrics** → **Explorer**
3. Search for your metrics:
   - `test_devops.request.count`
   - `test_devops.request.duration`
   - `core.random_delay`

### View APM Traces (if enabled)

1. Go to **APM** → **Services**
2. Look for `test-devops` service

### View Logs (if enabled)

1. Go to **Logs** → **Live Tail**
2. Filter by: `kube_namespace:test-devops`

---

## Resources Created

When `datadog.enabled: true`, the following resources are created:

1. **DaemonSet** - `test-devops-test-devops-datadog-agent`
2. **ServiceAccount** - `test-devops-test-devops-datadog`
3. **ClusterRole** - `test-devops-test-devops-datadog`
4. **ClusterRoleBinding** - `test-devops-test-devops-datadog`
5. **Secret** - `test-devops-test-devops-datadog-secret`

---

## Troubleshooting

### Agent not starting

```bash
# Check pod events
kubectl describe pod -n test-devops -l app=datadog-agent

# Check logs
kubectl logs -n test-devops -l app=datadog-agent
```

### No metrics in Datadog

1. **Check API Key:**
   ```bash
   kubectl get secret -n test-devops test-devops-test-devops-datadog-secret -o yaml
   ```

2. **Check Agent Status:**
   ```bash
   POD=$(kubectl get pods -n test-devops -l app=datadog-agent -o jsonpath='{.items[0].metadata.name}')
   kubectl exec -n test-devops $POD -- agent status
   ```

3. **Verify App Environment:**
   ```bash
   kubectl exec -n test-devops <app-pod> -- env | grep DD_
   ```

4. **Test Connection:**
   ```bash
   kubectl exec -n test-devops <app-pod> -- nc -zvu $DD_AGENT_HOST 8125
   ```

### Permission Issues

```bash
# Check ServiceAccount
kubectl get sa -n test-devops

# Check ClusterRole
kubectl get clusterrole | grep datadog

# Check ClusterRoleBinding
kubectl get clusterrolebinding | grep datadog
```

---

## Security Best Practices

### Use Kubernetes Secrets

Instead of passing API key via `--set`:

```bash
# Create secret
kubectl create secret generic datadog-api-key \
  --from-literal=api-key=<YOUR_KEY> \
  --namespace test-devops

# Update chart to use existing secret
# (requires chart modification)
```

### Limit Permissions

Review RBAC permissions in `datadog-rbac.yaml` and adjust as needed.

---

## Resource Requirements

### Default Resources

```yaml
resources:
  limits:
    cpu: 200m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 256Mi
```

### Adjust for Your Environment

```bash
# Higher resources for production
helm upgrade test-devops ./helm/test-devops \
  --set datadog.agent.resources.limits.cpu=500m \
  --set datadog.agent.resources.limits.memory=1Gi
```

---

## Uninstall

Datadog Agent will be removed when you uninstall the chart:

```bash
helm uninstall test-devops -n test-devops
```

Note: ClusterRole and ClusterRoleBinding will also be removed.

---

## References

- [Datadog Kubernetes Documentation](https://docs.datadoghq.com/agent/kubernetes/)
- [DogStatsD Documentation](https://docs.datadoghq.com/developers/dogstatsd/)
- [Datadog APM](https://docs.datadoghq.com/tracing/)

---

**For more information, see the main [README.md](README.md)**

