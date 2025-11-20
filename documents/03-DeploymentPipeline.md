# Deployment Pipeline

Deployment pipelines automate the process of deploying applications to various environments, ensuring consistency,
reliability, and efficiency. This document outlines the key components and best practices for setting up a deployment
pipeline.

## Key Components

1. **Source Control Management (SCM)**: Use a version control system like GitHub to manage application code and
   configuration files.
2. **Continuous Integration (CI)**: Implement CI pipelines using GitHub Actions to automate code building, testing, and
   packaging.
3. **Continuous Deployment (CD)**: Use ArgoCD for GitOps-based deployments, enabling automated synchronization of
   application manifests to Kubernetes clusters.
4. **Container Registry**: Utilize GCP Artifact Registry to store and manage Docker images for multi-cloud deployments.
5. **Secrets Management**: Integrate HCP Vault for secure storage and management of application secrets and credentials.
6. **Kubernetes Clusters**: Deploy applications to GKE and EKS clusters for NON-PROD and PROD environments.
7. **Load Balancing and Security**: Use Cloudflare for global load balancing and web application firewall (WAF)
   protection.
8. **Monitoring and Logging**: Implement Datadog agents for comprehensive monitoring, logging, and tracing of
   application performance.

## Best Practices Continuous Integration

1. Push code changes to feature branches and create pull requests for review.
2. Automate testing and code quality checks in CI pipelines.
3. Use branch protection rules to enforce code reviews and approvals.
4. Tag releases and create release branches for production deployments.

## Best Practices Continuous Deployment

1. Use GitOps principles to manage application deployments through version-controlled manifests.
2. Implement progressive rollout strategies (Blue/Green, Canary) for safer deployments.
3. Monitor deployment status and set up alerts for failures or issues.
4. Regularly update and maintain deployment manifests and configurations.

## Security Considerations
1. Use HCP Vault for managing sensitive information and avoid hardcoding secrets in code or manifests.
2. Implement role-based access control (RBAC) for Kubernetes clusters and CI/CD tools.
3. Regularly audit and review access permissions and security policies.
4. Ensure compliance with industry standards and regulations for data protection.

## Monitoring and Logging
1. Set up Datadog dashboards to visualize application performance metrics and logs.
2. Implement APM and tracing to identify performance bottlenecks and issues.
3. Configure alerts for critical events and anomalies in application behavior.
4. Regularly review and analyze logs to improve application reliability and user experience.

## Conclusion
A well-structured deployment pipeline is essential for modern application development and operations. By following the
outlined components and best practices, organizations can achieve efficient, reliable, and secure deployments across
multiple environments.

## Flowchart Pipeline Overview

```mermaid
flowchart TD

%% -------- Pull Request -------- %%
subgraph PR_Flow [Pull Request Validation]
A1[Developer Creates PR \nto develop/main] --> A2[Init / Checkout Code]
A2 --> A3[Lint]
A3 --> A4[Unit Test]
A4 --> A5[SonarQube Code Scan]
A5 --> A6{Quality Gate Pass?}
A6 -->|No| A7["Block Merge ❌"]
A6 -->|Yes| A8["Approval → Merge"]
end

%% -------- Push develop/main -------- %%
subgraph CI_CD_Auto ["Auto CI + Auto CD (develop/main)"]
B1[Push to develop/main] --> B2[Init / Checkout]
B2 --> B3[Lint]
B3 --> B4[Unit Test]
B4 --> B5[SonarQube Scan + Quality Gate]
B5 --> B6{Pass?}
B6 -->|No| B7["Fail Pipeline ❌ Stop"]
B6 -->|Yes| B8[Build Docker Image]
B8 --> B9["Generate SBOM (Syft)"]
B9 --> B10[Sign Image Cosign ]
B10 --> B11[Scan Image Trivy ]
B11 --> B12{Branch?}
B12 -->|develop| B13[Update k8s/overlays/dev]
B12 -->|main| B14[Update k8s/overlays/uat]
B13 --> C1[ArgoCD Sync to DEV]
B14 --> C2[ArgoCD Sync to UAT]
end

%% -------- Push Tag -------- %%
subgraph Tag_Flow ["Release CI Only Tag (vX.Y.Z)"]
T1[Push Tag v*.*.*] --> T2[Build Image]
T2 --> T3[SBOM + Sign + Scan]
T3 --> T4[Ready for Manual Deploy]
end

%% -------- Manual Deploy -------- %%
subgraph Manual_CD [Manual Deploy GitOps]
M1[Select Tag + Select ENV] --> M2[Approval]
M2 --> M3["Update k8s/overlays/{dev/uat/prod}"]
M3 --> M4[Commit & Push]
M4 --> M5[ArgoCD Sync & Deploy]
end

%% Connections
A8 -->|Merged| B1

```


### Flow 1: Pull Request Pipeline (CI Only)

```mermaid
flowchart LR
    A1[Developer Creates PR \nto develop/main] --> A2[Init / Checkout Code]
    A2 --> A3[Lint]
    A3 --> A4[Unit Test]
    A4 --> A5[SonarQube Code Scan]
    A5 --> A6{Quality Gate Pass?}
    A6 -->|No| A7["Block Merge ❌"]
    A6 -->|Yes| A8["Approval → Merge"]

```

1. Developer creates a pull request (PR) to the `develop` or `main` branch.
2. CI pipeline triggers:
   - Checkout code
   - Linting
   - Unit tests
   - SonarQube code scan 
   - Quality gate check
3. If quality gate fails, block merge. If it passes, approve and merge PR.
4. Upon merge, auto CI/CD pipeline triggers.




### Flow 2: Auto CI/CD (develop → DEV, main → UAT)

```mermaid
flowchart LR
    B1[Push to develop/main] --> B2[Init / Checkout]
    B2 --> B3[Lint]
    B3 --> B4[Unit Test]
    B4 --> B5[SonarQube Scan + Quality Gate]
    B5 --> B6{Pass?}
    B6 -->|No| B7["Fail Pipeline ❌ Stop"]
    B6 -->|Yes| B8[Build Docker Image]
    B8 --> B9["Generate SBOM (Syft)"]
    B9 --> B10[Sign Image Cosign ]
    B10 --> B11[Scan Image Trivy ]
    B11 --> B12{Branch?}
    B12 -->|develop| B13[Update k8s/overlays/dev]
    B12 -->|main| B14[Update k8s/overlays/uat]
    B13 --> C1[ArgoCD Sync to DEV]
    B14 --> C2[ArgoCD Sync to UAT]
```

- Push to `develop` or `main` branch triggers auto CI/CD pipeline:
- Checkout code
- Linting
- Unit tests
- SonarQube scan + quality gate
- If quality gate fails, pipeline stops.
- If it passes:
  - Build Docker image
  - Generate SBOM (Syft)
  - Sign image (Cosign)
  - Scan image (Trivy)
  - Update k8s overlays based on branch
  - if `develop` → `k8s/overlays/dev`
  - if `main` → `k8s/overlays/uat`
  - Commit and push changes to respective overlay directory.
  - ArgoCD sync to respective environment (DEV for develop, UAT for main)

### Flow 3: Release CI Only Tag (vX.Y.Z)
```mermaid
flowchart LR
    T1[Push Tag v*.*.*] --> T2[Build Image]
    T2 --> T3[SBOM + Sign + Scan]
    T3 --> T4[Ready for Manual Deploy]
```

1. Push a tag in the format `vX.Y.Z` triggers release CI pipeline:
2. Build Docker image 
3. Generate SBOM, sign, and scan image 
4. Image is ready for manual deployment.

### Flow 4: Manual Deploy GitOps
```mermaid
flowchart LR
    M1[Select Tag + Select ENV] --> M2[Approval]
    M2 --> M3["Update k8s/overlays/{dev/uat/prod}"]
    M3 --> M4[Commit & Push]
    M4 --> M5[ArgoCD Sync & Deploy]
```
1. Select the desired tag and environment (dev, uat, prod) for deployment.
2. Obtain approval for deployment.
3. Update the corresponding k8s overlay with the selected tag.
4. Commit and push changes to the repository.
5. ArgoCD syncs and deploys the application to the selected environment.