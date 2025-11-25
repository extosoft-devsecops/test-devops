# Future improvements

## EKS (Amazon Elastic Kubernetes Service)
### Objective : Multi-Cloud.
### Estimate plan : 10-15 days (Complexity :high)
1. Provision EKS clusters for NON-PROD and PROD environments.
2. Configure VPC networking, security groups, and RBAC access controls.
3. Deploy ArgoCD agents for cluster deployment management.
4. Integrate Vault Agent Injector for secret delivery.
5. Deploy Datadog agents for metrics, logs, and distributed tracing.
6. Document EKS administrative operations and cluster maintenance procedures.

## Improve Security
### Objective : End-to-End Supply Chain Security & Compliance.
### Estimate plan : 15-20 days (Complexity :very high)
1. Adopt SLSA for supply chain security
2. Enable Cosign image signing with Sigstore
3. Compliance alignment (ISO27001, NIST SSDF, OWASP SAMM)
4. AI-based anomaly detection for security operations

## Kubenetes Vault cluster
### Objective : Centralized, High-Available Secret Management & Zero Trust Identity.
### Estimate plan : 8-12 days (Complexity :medium-high)
1. Design HA with Raft: Deploy HA cluster using Raft storage to simplify architecture.
2. AWS KMS Auto-Unseal: Configure auto-unseal via AWS KMS for operational resilience.
3. Secure Deployment: Enforce end-to-end TLS and strict Network Policies via Helm.
4. K8s Auth Integration: Enable Kubernetes Auth Method for dynamic pod authentication.
5. Disaster Recovery: Automate Raft snapshots to S3 for backup and restore.
6. Observability: Centralize metrics and audit logs in Datadog for monitoring.

## Advanced Observability
### Objective : Achieve end-to-end visibility for rapid troubleshooting (Low MTTR) and improved user experience.  
### Estimate plan : 10 - 15 Days (Complexity : High)
1. APM & Tracing: Implement distributed tracing to visualize service dependencies and latency bottlenecks.
2. Log Correlation: Inject Trace IDs to unify logs and traces for faster debugging.
3. Business Metrics: Monitor custom business KPIs (e.g., transaction rates) beyond infrastructure stats.
4. SLO/SLI Adoption: Shift alerting focus from server health to user-centric reliability targets.
5. Synthetic Monitoring: Deploy active probes to simulate user journeys and verify availability 24/7.
