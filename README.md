# Azure AKS DevOps Platform

Platform API – Secure AKS Deployment with Workload Identity
Overview

This repository demonstrates a production-grade Kubernetes deployment on Azure using:

Azure Kubernetes Service (AKS)

Azure DevOps CI/CD

Terraform for infrastructure

Helm for application deployment

Azure Workload Identity

Azure Key Vault via Secrets Store CSI Driver

Security scanning with tfsec & Trivy

The platform follows modern cloud-native best practices:

No long-lived secrets

Minimal container images

Identity-based access to Azure resources

Fully automated infrastructure and deployments

Key Features

✅ End-to-end IaC with Terraform (AKS, ACR, identity, networking)

✅ Secure container builds using minimal .NET runtime images

✅ Azure Workload Identity (no client secrets, no managed identity bindings)

✅ Key Vault integration using CSI driver (secrets never stored in Kubernetes)

✅ Helm-based deployments with environment separation

✅ Security scanning (Terraform + container images)

✅ Production-ready RBAC and network controls

Architecture
High-Level Flow
┌────────────┐
│ Developer  │
└─────┬──────┘
      │ Git Push
      ▼
┌──────────────────────┐
│ Azure DevOps Pipeline│
│----------------------│
│ - Terraform Init     │
│ - Terraform Plan     │
│ - Terraform Apply    │
│ - Docker Build       │
│ - Trivy Scan         │
│ - Docker Push (ACR)  │
│ - Helm Upgrade       │
└─────┬────────────────┘
      ▼
┌────────────────────────────────────────────┐
│ Azure Kubernetes Service (AKS)              │
│                                            │
│  ┌──────────────────────────────────────┐ │
│  │ platform-api Deployment               │ │
│  │--------------------------------------│ │
│  │ ServiceAccount: platform-api-sa       │ │
│  │ Workload Identity Enabled             │ │
│  │                                      │ │
│  │  /mnt/secrets (CSI Mount)             │ │
│  │        │                              │ │
│  └────────┼──────────────────────────────┘ │
│           │                                 │
│           ▼                                 │
│  Azure AD Federated Identity Credential    │
│           │                                 │
│           ▼                                 │
│  Azure Key Vault                            │
│  - Secrets retrieved at runtime            │
│  - No secrets stored in cluster            │
└────────────────────────────────────────────┘

Identity & Security Model
Workload Identity (No Secrets)

Each application uses a dedicated Kubernetes ServiceAccount

The ServiceAccount is federated with Azure Entra ID

Azure issues short-lived tokens at runtime

Key Vault access is granted via RBAC, not secrets

Federated Identity Subject Format:

system:serviceaccount:<namespace>:<serviceaccount>


Example:

system:serviceaccount:platform-prod:platform-api-sa

Why This Matters
Traditional Approach	This Platform
Client secrets	❌ None
Secrets in Kubernetes	❌ None
Static credentials	❌ None
Token rotation	✅ Automatic
Least privilege	✅ Enforced
Container Security

Uses multi-stage Docker builds

Runtime image: mcr.microsoft.com/dotnet/aspnet:8.0

No shell utilities installed

No package managers present

Trivy scan enforced in CI

Result:
✔ Zero known vulnerabilities at build time

CI/CD Pipeline Stages
1. Infrastructure (Terraform)

AKS cluster

Azure Container Registry

Networking & RBAC

Workload Identity configuration

2. Build & Scan

Docker build

Trivy vulnerability scan

Fail pipeline on HIGH/CRITICAL findings

3. Deploy

Helm upgrade --install

Namespace-scoped deployments

Controlled rollouts with readiness checks

Helm Chart Highlights

Optional ServiceAccount creation

Workload Identity annotations

CSI SecretProviderClass integration

Environment-driven configuration

Production-safe defaults

Example:

serviceAccount:
  create: true
  name: platform-api-sa
  annotations:
    azure.workload.identity/client-id: <client-id>

Secrets Handling

Secrets are retrieved at pod startup

Mounted read-only via CSI

Never exposed as Kubernetes Secrets

Access controlled by Azure RBAC

Example mount:

/mnt/secrets/PlatformApi--Greeting

Operational Lessons Learned

Minimal images require debug pods for inspection

Helm ownership rules must be respected for existing resources

Workload Identity failures always trace back to:

Subject mismatch

Namespace mismatch

Client ID mismatch

All were intentionally debugged and resolved in this project.

Why This Project Matters

This platform demonstrates:

Real-world Azure DevOps + AKS experience

Deep understanding of identity-based security

Practical handling of production failures

Security-first cloud architecture

This is not a tutorial deployment — it mirrors how secure Azure platforms are built and operated in production.

Future Enhancements

Ingress with private endpoints

Azure Monitor & Prometheus integration

Blue/green or canary deployments

Policy enforcement with Azure Policy / Gatekeeper
