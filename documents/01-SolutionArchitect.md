# Solution Architect

1. Github  Github action (CI)
- Source code management
- CI pipeline build, test, lint, security scan (SAST), build container image

2. ArgoCD (Akuity) — GitOps CD 
- Watch Git repo → auto-sync manifests
- Deploy to GKE/EKS multi-cloud
- Manage progressive rollout (Blue/Green, Canary)

3. Artifact Registry (GCP)
- Centralized Docker Image Storage
- Multi-cloud consumption (GKE + EKS)

4. HashiCorp Vault (HCP Vault — SaaS)
- JWT/OIDC auth (GitHub Actions, Kubernetes Service Account)
- Secrets management (DB credentials, API keys)
- Dynamic secrets (optional)

5. GKE + EKS (NON PROD + PROD)
- Workload clusters multi-cloud
- Each cluster installs:
- ArgoCD agent
- Vault Agent Injector (Sidecar)
- Datadog Agent (Daemon set)

6. Cloudflare Global Load Balancer + WAF
- Anycast Load Balancer (Global)
- Route to GKE/EKS multi-cloud cluster
- Zero Trust (WAF, Bot Protection, Firewall Rules)

7. Datadog Agents
- Logging (stdout)
- Metrics (autodiscovery)
- APM/Tracing
- RUM optional

Architecture Diagram:

```mermaid
flowchart LR
    subgraph SCM[GitHub Platform]
        GH[GitHub Repo]
        GHA[GitHub Actions CI]
    end

    subgraph Registry[GCP Artifact Registry]
        AR[GCP Artifact Registry]
    end

    subgraph GitOps[ArgoCD- Akuity]
        ACD[ArgoCD Controller]
    end

    subgraph Secrets[HCP Vault]
        HCP[HCP Vault - Secrets Management]
    end

    subgraph K8sMulti[Multi-Cloud Kubernetes]
        subgraph GKE[GKE Clusters]
            GKE1[NONPROD]
            GKE2[PROD]
        end
        subgraph EKS[EKS Clusters]
            EKS1[NONPROD]
            EKS2[PROD]
        end
    end

    subgraph CF[Cloudflare]
        LB[Global Load Balancer]
        WAF[WAF Policies]
    end

    subgraph DD[Datadog]
        DDAGENT[Datadog Agents]
    end

    GH --> GHA
    GHA --> AR
    GHA --> ACD

    ACD --> GKE1
    ACD --> GKE2
    ACD --> EKS1
    ACD --> EKS2

    AR --> GKE1
    AR --> GKE2
    AR --> EKS1
    AR --> EKS2

    HCP --> GKE1
    HCP --> GKE2
    HCP --> EKS1
    HCP --> EKS2

    GKE1 --> LB
    GKE2 --> LB
    EKS1 --> LB
    EKS2 --> LB

    GKE1 --> DDAGENT
    GKE2 --> DDAGENT
    EKS1 --> DDAGENT
    EKS2 --> DDAGENT

```
