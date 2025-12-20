# Azure AKS DevOps Platform

### Overview

This repository demonstrates a **production-grade Kubernetes deployment** on Azure using:
- **Azure Kubernetes Service (AKS)**
- **Azure DevOps CI/CD**
- **Terraform** for infrastructure
- **Helm** for application deployment
- **Azure Workload Identity**
- **Azure Key Vault** via Secrets Store CSI Driver
- **Security scanning** using `tfsec` and `Trivy`

### Key Features

- ✅ End-to-end IaC with **Terraform** (AKS, ACR, identity, networking).
- ✅ Secure container builds with minimal `.NET runtime` images.
- ✅ **Azure Workload Identity:** Eliminate client secrets and managed identity bindings.
- ✅ Key Vault integration with the **CSI driver**—secrets are never stored in Kubernetes.
- ✅ Helm-based deployments with environment separation.
- ✅ Comprehensive security scanning (Terraform + container images).
- ✅ Production-ready **RBAC** and network controls.

---

## Architecture and Flow

### High-Level CI/CD Flow:
```plaintext
┌────────────┐
│ Developer  │
└─────┬──────┘
      │
      ▼
┌────────────────────────┐
│ Azure DevOps Pipeline  │
│ - Terraform Init       │
│ - Terraform Plan       │
│ - Terraform Apply      │
│ - Docker Build         │
│ - Trivy Scan           │
│ - Docker Push (ACR)    │
│ - Helm Upgrade         │
└─────┬──────────────────┘
      ▼
┌───────────────────────────────────────────────┐
│ Azure Kubernetes Service (AKS)               │
│                                               │
│ ┌─────────── platform-api Deployment ─────────┐
│ │ Workload Identity enabled                   │
│ │ Secrets mounted via CSI driver:            │
│ │ /mnt/secrets (read-only)                    │
└─┴───────────────┬─────────────────────────────┘
                  ▼
  Azure Key Vault ↔ Workload Identity ↔ CSI Secrets
```

### Features of Workload Identity:
- No long-lived **secrets**—least privilege enforced.
- Secrets accessed at runtime via Azure Key Vault.

---

## Identity & Security Model

### **Workload Identity Highlights**:
- **Each application** uses a dedicated Kubernetes `ServiceAccount`.
- ServiceAccount is **federated with Azure AD Identity**.
- **Short-lived tokens** are generated at runtime.
- Access control via **Azure RBAC**, no credentials required.

**Federated Identity Subject Format**:
```
system:serviceaccount:<namespace>:<serviceaccount>
```

**Example:**
```
system:serviceaccount:platform-prod:platform-api-sa
```

### Comparison: Traditional vs Modern Security:
| Aspect                  | Traditional Approach  | This Platform       |
|-------------------------|-----------------------|---------------------|
| **Client Secrets**      | ✅ Required           | ❌ None             |
| **Secrets in Kubernetes** | ✅ Required        | ❌ None             |
| **Static Credentials**  | ✅ Required           | ❌ None             |
| **Token Rotation**      | ❌ Manual            | ✅ Automatic        |
| **Least Privilege**     | ❌ Partial           | ✅ Fully Enforced   |

---

## Container Security

- Use [multi-stage Docker builds](https://docs.docker.com/develop/develop-images/multistage-build/).
- Runtime image: `mcr.microsoft.com/dotnet/aspnet:8.0`.
  - No interactive utilities/debug tooling.
  - Minimized attack surface (e.g., no `curl` or package managers).
- **Trivy scan** is enforced in CI pipeline.
- Result: **Zero known vulnerabilities at build time.**

---

## CI/CD Pipeline Stages

### 1. Infrastructure (Terraform)
- Configure AKS clusters.
- Create Azure Container Registry.
- Set up Workload Identity and networking.

### 2. Build & Scan
- Build container images.
- Run `Trivy` for vulnerability scans.
  - **Pipeline fails** on HIGH/CRITICAL findings.

### 3. Deployment
- Use `Helm` to upgrade or install charts.
- Handle:
  - Namespace-scoped deployments.
  - Controlled rollouts with readiness checks.

---

## Helm Chart Highlights

- Optional creation of **ServiceAccount** with workload identity annotations.
- Support for CSI SecretProviderClass integration.
- Environment-specific configuration.

```yaml
serviceAccount:
  create: true
  name: platform-api-sa
  annotations:
    azure.workload.identity/client-id: <your-client-id>
```

---

## Secrets Handling

- Secrets are retrieved **dynamically on pod startup** via CSI.
- Mounted as **read-only** using the Azure Key Vault provider.
- **No Kubernetes Secrets** are created.
- Access is strictly controlled via **Azure RBAC**.

```plaintext
/mnt/secrets/PlatformApi--Greeting
```

---

## Operational Lessons Learned

1. Debug minimal images with **debug pods**.
2. Follow Helm ownership rules for resource upgrades.
3. **Trace failures** in Workload Identity to:
   - ServiceAccount / namespace mismatches.
   - Azure AD Client ID errors.

---

## Why This Project Matters

This platform demonstrates:
- Real-world experience in **Azure DevOps + AKS**.
- A deep understanding of **identity-based security**.
- Solutions to production-grade challenges (e.g., Terraform + Key Vault).
- A comprehensive, **security-first cloud architecture**.

---

## Future Enhancements

- Add ingress support with **private endpoints**.
- Centralized monitoring using **Azure Monitor & Prometheus**.
- Implement **blue/green deployments**.
- Enforce governance policies using **Azure Policy / Gatekeeper**.