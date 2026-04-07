# 🚀 **Project 4: Flux GitOps + Splunk Deployment on GKE**

![Terraform](https://img.shields.io/badge/IaC-Terraform-623CE4?logo=terraform)
![Kubernetes](https://img.shields.io/badge/Platform-Kubernetes-326CE5?logo=kubernetes)
![Flux](https://img.shields.io/badge/GitOps-FluxCD-5468FF?logo=flux)
![GKE](https://img.shields.io/badge/Cloud-Google%20Kubernetes%20Engine-4285F4?logo=googlecloud)
![Splunk](https://img.shields.io/badge/Observability-Splunk-000000?logo=splunk)
![Cert-Manager](https://img.shields.io/badge/Certificate%20Management-cert--manager-1E90FF?logo=cert-manager)
![NGINX](https://img.shields.io/badge/Networking-NGINX-009639?logo=nginx)
![GitOps](https://img.shields.io/badge/Method-GitOps-green)

---

## 📌 **Project Overview**

This project demonstrates a GitOps-based deployment pipeline using `Flux CD` to deploy Splunk on **Google Kubernetes Engine (GKE).** The underlying infrastructure is provisioned with **Terraform**, while application manifests are continuously reconciled from a GitHub repository using Flux GitOps controllers. The implementation reflects a production-style DevOps workflow that incorporates Infrastructure as Code, continuous deployment through **GitOps**, Kubernetes-based application deployment, an observability platform via **Splunk**, TLS-enabled ingress networking, automated deployment scripting, and continuous reconciliation with drift correction. The overall architecture adheres to the core GitOps principle that Git serves as the single source of truth, and the cluster continuously reconciles itself to match the desired state defined in the repository.

---

## 🎯 **Project Requirements**

The project implements the following DevOps and Platform Engineering capabilities:

### **Infrastructure**

* Terraform-based provisioning of a GKE cluster
* Modular Infrastructure as Code design
* IAM and access configuration
* Network configuration (VPC, subnets, firewall rules)
* Kubernetes StorageClasses for persistent workloads

### **GitOps Deployment**

* Flux GitRepository as the source of truth
* Flux Kustomization controller for continuous deployment
* `prune: true` enabled for automatic drift correction
* Declarative cluster state management from Git
* Ordered deployment to satisfy platform dependencies (e.g., cert-manager before application)

### **Kubernetes Application**

* Splunk deployed as a StatefulSet
* Persistent Volume Claims for durable storage
* ConfigMap-based configuration management
* Secret-based credential handling
* GitOps-managed namespace lifecycle
* ClusterIP service for internal exposure
* Self-healing via continuous reconciliation

### **Networking**

* NGINX Ingress Controller (Helm-installed)
* cert-manager for automated certificate management
* ClusterIssuer and Certificate resources
* TLS-enabled HTTPS ingress for Splunk
* Secure external access pattern via ingress

### **Automation & Validation Pipeline**

Script-driven environment lifecycle with production-style orchestration:

```text
bootstrap → deploy → reconcile → verify → collect-artifacts → teardown
```

* Structured automation scripts for each stage
* Flux reconciliation validation
* Artifact pipeline for evidence generation
* Run-scoped logs, snapshots, and reports
* Deterministic teardown and cleanup

---

## 🧠 **Interview Talk Track (Business + DevOps)**

### **Business Perspective**

Organizations require reliable, auditable, and automated deployment platforms that reduce operational risk while maintaining compliance and consistency across environments. This project demonstrates how a GitOps-driven approach enables deterministic and repeatable infrastructure and application delivery, where every change is version-controlled, traceable, and reviewable.

By using Git as the single source of truth, teams gain full auditability of changes, simplified rollback through version history, and consistent environment promotion without manual intervention. Automated reconciliation ensures that the deployed state always matches the desired state, significantly reducing configuration drift and operational errors. Additionally, the inclusion of structured validation and artifact generation provides verifiable deployment evidence, supporting compliance, troubleshooting, and operational transparency.

### **DevOps Perspective**

This project demonstrates a modern DevOps and Platform Engineering workflow that integrates Infrastructure as Code, GitOps, and Kubernetes-native operations into a cohesive delivery pipeline.

Key practices implemented include:

* Infrastructure provisioning using Terraform with modular design
* GitOps-based continuous deployment using FluxCD
* Kubernetes orchestration for stateful application workloads (Splunk)
* Declarative configuration management via Kustomize
* Automated reconciliation with drift correction (prune: true)
* Secure secret and configuration handling
* TLS-enabled ingress using cert-manager and ingress-nginx
* Script-driven lifecycle automation (deploy, reconcile, verify, teardown)
* Evidence-based validation through structured artifact generation

The system continuously compares the live cluster state against the Git repository and automatically reconciles any deviation, ensuring self-healing behavior. This approach shifts operations from imperative management to declarative control, enabling scalable, consistent, and resilient platform management.

---

## 🧪 **Lab Demo**

### What Students Learn

[Demo](https://github.com/user-attachments/assets/651f31df-8c9a-4380-bc46-57c735ceb9c4)

---

## 🏗 **Project Architecture**

```text
                ┌──────────────────────────────┐
                │          GitHub Repo         │
                │ kubernetes-projects-2026     │
                └──────────────┬───────────────┘
                               │
                               ▼
                       Flux Source Controller
                               │
                               ▼
                      Flux Kustomize Controller
                               │
                               ▼
                     Kubernetes Cluster (GKE)
                               │
              ┌────────────────┼────────────────┐
              ▼                ▼                ▼
         Namespace        StatefulSet         Service
         splunk-dev         Splunk           ClusterIP
              │
              ▼
         PersistentVolume
              │
              ▼
        Ingress + TLS
              │
              ▼
          Splunk Web UI
```

---

## 📂 **Project Structure**

```text
project-4/
├── artifacts/
|   ├── latest/
|   |   ├── checks/
|   |   |   ├── cert_manager_crds.stdout.txt
|   |   |   ├── cert_manager_pods.stdout.txt
|   |   |   ├── cluster_ingress.stdout.txt
|   |   |   ├── flux_controllers.stdout.txt
|   |   |   ├── flux_kustomization.stderr.txt
|   |   |   ├── flux_reconcile_source.stderr.txt
|   |   |   ├── git_source_describe.stdout.txt
|   |   |   ├── git_source.stdout.txt
|   |   |   ├── ingress_nginx_pods.stdout.txt
|   |   |   ├── ingress_nginx_service.stdout.txt
|   |   |   ├── kustomization.stdout.txt
|   |   |   ├── kustomizations.stdout.txt
|   |   |   ├── localhost_8091.stdout.txt
|   |   |   ├── splunk_ingress.stdout.txt
|   |   |   ├── splunk_logs.stdout.txt
|   |   |   ├── splunk_namespace.stdout.txt
|   |   |   ├── splunk_pod.stdout.txt
|   |   |   ├── splunk_resources.stdout.txt
|   |   |   ├── splunk_statefulset.stdout.txt
|   |   |   └── tls_secret.stdout.txt
|   |   ├── logs/
|   |   |   └── splunk-0.log.txt
|   |   └── snapshots/
|   |       ├── cert-manager-certificates.yaml
|   |       ├── cert-manager-clusterissuers.yaml
|   |       ├── flux-system-gitrepository.yaml
|   |       ├── flux-system-kustomization.yaml
|   |       ├── splunk-dev-all.yaml
|   |       └── splunk-dev-ingress.yaml
|   ├── manifest.json
│   ├── proof-of-project.md
│   ├── proof-resources.json
│   ├── splunk-logs.txt
│   └── summary.json
│
├── clusters/
│   └── dev/
│       └── splunk/
│           ├── kustomization.yaml
│           ├── namespace.yaml
│           ├── configmap.yaml
│           ├── secret.yaml
│           ├── pvc.yaml
│           ├── service.yaml
│           ├── statefulset.yaml
│           ├── issuer.yaml
│           └── ingress.yaml
│
├── flux/
│   ├── tls/
│   │   ├── public_ip_ingress.yaml
│   │   ├── public_ip_issuer.yaml
│   │   ├── public_ip_TLS_issuer.yaml
│   │   └── tls_kustomization.yaml
│   |  
│   └── lab_github/
│       ├── 01-gitrepository.yaml
│       └── 02-kustomization-splunk-dev.yaml
│
├── python/
│   └── collect-artifacts.py
|
├── Screenshots/
|   ├── collect-artifacts-script.jpg
|   ├── firewall-rules.jpg
|   ├── gke-cluster-nodes.jpg
|   ├── gke-cluster-overview.jpg
|   ├── gke-cluster-storage.jpg
|   ├── script0.jpg
|   ├── script1-pt1.jpg
|   ├── script1-pt2.jpg
|   ├── script1-pt3.jpg
|   ├── script2.jpg
|   ├── script3-pt1.jpg
|   ├── script3-pt2.jpg
|   ├── script4-pt1.jpg
|   ├── script4-pt2.jpg
|   ├── script4-pt3.jpg
|   ├── script5-pt1.jpg
|   ├── script5-pt2.jpg
|   ├── script5-pt3.jpg
|   ├── script6.jpg
|   ├── script7-pt1.jpg
|   ├── script7-pt2.jpg
|   ├── script7-pt3.jpg
|   ├── script7-pt4.jpg
|   ├── script7-pt5.jpg
|   ├── script8-pt1.jpg
|   ├── script8-pt2.jpg
|   ├── script8-pt3.jpg
|   ├── script8-pt4.jpg
|   ├── subnets.jpg
|   └── vm-instances.jpg
|
├── scripts/
│   ├── 1-build-infrastructure.sh
│   ├── 2-gke-credentials.sh
│   ├── 3-install-flux.sh
│   ├── 4-install-ingress-cert-manager.sh
│   ├── 5-apply-flux.sh
│   ├── 6-deploy-flux.sh
│   ├── 7-reconcile-and-verify.sh
│   └── 8-teardown.sh
|
├── terraform/
|   ├── 0-var.tf
│   ├── 1-auth.tf
|   ├── 2-vpc.tf
|   ├── 3-subnets.tf
|   ├── 4-firewall.tf
|   ├── 5-nat.tf
|   ├── 6-artifact-registry.tf
|   ├── 7-gke.tf
|   ├── 8-node.tf
|   ├── 9-runtime.tf
|   ├── 10-iam-oidc.tf
|   ├── 11a-storage-iam.tf
|   ├── 11b-storage-helm.tf
|   └── 12-outputs.tf
|
├── tfplan.out
├── .gitignore
└── README.md
```

---

## ⚙️ **Deployment Steps**

### 0️⃣ **Prerequisites**

```bash
./scripts/0-prerequisites.sh
```

![script0.jpg](/Screenshots/script0.jpg)

Verifies:

* Required tools are installed
* Environment variables are set
* Access to cloud provider is configured

---

### 1️⃣ **Build Infrastructure**

```bash
./scripts/1-build-infrastructure.sh
```

![script1-pt1.jpg](/Screenshots/script1-pt1.jpg)
![script1-pt2.jpg](/Screenshots/script1-pt2.jpg)
![script1-pt3.jpg](/Screenshots/script1-pt3.jpg)

Creates:

* GKE cluster
* Storage classes
* IAM roles

---

### 2️⃣ **Configure Kubernetes Credentials**

```bash
./scripts/2-gke-credentials.sh
```

![script2.jpg](/Screenshots/script2.jpg)

Validates cluster connectivity.

---

### 3️⃣ **Install Flux**

```bash
./scripts/3-install-flux.sh
```

![script3-pt1.jpg](/Screenshots/script3-pt1.jpg)
![script3-pt2.jpg](/Screenshots/script3-pt2.jpg)

Installs:

* source-controller
* kustomize-controller
* helm-controller
* notification-controller

---

### 4️⃣ **Install Ingress + Cert-Manager**

```bash
./scripts/4-install-ingress-cert-manager.sh
```

![script4-pt1.jpg](/Screenshots/script4-pt1.jpg)
![script4-pt2.jpg](/Screenshots/script4-pt2.jpg)
![script4-pt3.jpg](/Screenshots/script4-pt3.jpg)

Installs:

* ingress-nginx
* cert-manager
* CRDs

---

### 5️⃣ **Apply Flux Git Source**

```bash
./scripts/5-apply-flux.sh
```

![script5-pt1.jpg](/Screenshots/script5-pt1.jpg)
![script5-pt2.jpg](/Screenshots/script5-pt2.jpg)
![script5-pt3.jpg](/Screenshots/script5-pt3.jpg)

Creates:

* GitRepository
* Kustomization

---

### 6️⃣ **Deploy Splunk via GitOps**

```bash
./scripts/6-deploy-flux.sh
```

![script6.jpg](/Screenshots/script6.jpg)

Flux pulls manifests from GitHub and deploys them to the cluster.

---

### 7️⃣ **Reconcile and Verify Deployment**

```bash
kubectl -n splunk-dev port-forward svc/splunk 8091:8091
./scripts/7-reconcile-and-verify.sh
```

![script7-pt1.jpg](/Screenshots/script7-pt1.jpg)
![script7-pt2.jpg](/Screenshots/script7-pt2.jpg)
![script7-pt3.jpg](/Screenshots/script7-pt3.jpg)
![script7-pt4.jpg](/Screenshots/script7-pt4.jpg)
![script7-pt5.jpg](/Screenshots/script7-pt5.jpg)

Checks:

* Flux status
* Pods
* Services
* PVCs
* Ingress

---

## 📸 **Artifacts / Screenshots**

### **Artifacts are automatically generated using:**

```python
python/collect-artifacts.py
```

![collect-artifacts-script.jpg](/Screenshots/collect-artifacts-script.jpg)

### **Outputs:**

* [**Artifacts Checks**](/artifacts/latest/checks/)
* [**Artifacts Logs**](/artifacts/latest/logs/)
* [**Artifacts Snapshots**](/artifacts/latest/snapshots/)
* [**Artifacts Manifest (JSON)**](/artifacts/latest/manifest.json)
* [**Proof of Project (Markdown)**](/artifacts/latest/proof-of-project.md)
* [**Proof of Resources (JSON)**](/artifacts/latest/proof-resources.json)
* [**Artifacts Summary (JSON)**](/artifacts/latest/summary.json)

---

## 🧹 **Teardown**

Destroy infrastructure and remove Flux resources:

```bash
./scripts/8-teardown.sh
```

![script8-pt1.jpg](/Screenshots/script8-pt1.jpg)
![script8-pt2.jpg](/Screenshots/script8-pt2.jpg)
![script8-pt3.jpg](/Screenshots/script8-pt3.jpg)
![script8-pt4.jpg](/Screenshots/script8-pt4.jpg)

This script:

* removes Flux resources
* removes ingress + cert-manager
* destroys Terraform infrastructure

Artifacts and proof files remain preserved.

---

## 🛠 **Troubleshooting**

### **Flux cannot fetch Git repository**

```bash
kubectl -n flux-system logs deploy/source-controller
```

---

### **Kustomization fails**

```bash
kubectl -n flux-system describe kustomization splunk-dev
kubectl -n flux-system logs deploy/kustomize-controller
```

---

### **Splunk Pod CrashLoopBackOff**

```bash
kubectl -n splunk-dev logs splunk-0
```

Most common issue:

```text
SPLUNK_GENERAL_TERMS not accepted
```

Fix by setting:

```bash
SPLUNK_GENERAL_TERMS=--accept-sgt-current-at-splunk-com
SPLUNK_START_ARGS=--accept-license
```

---

### **PVC Pending**

```bash
kubectl describe pvc splunk-pvc
kubectl get storageclass
```

---

### **Ingress not accessible**

Verify:

```bash
kubectl -n ingress-nginx get svc
kubectl get ingress
```

---

## 📚 **References**

* [**Google GKE Documentation**](https://docs.cloud.google.com/kubernetes-engine/docs)
* [**Flux Documentation**](https://fluxcd.io/docs/)
* [**Terraform Documentation**](https://developer.hashicorp.com/terraform/docs)
* [**Kubernetes Documentation**](https://kubernetes.io/docs/)
* [**Splunk Documentation**](https://hub.docker.com/r/splunk/splunk)
* [**Cert Manager Documentation**](https://cert-manager.io/docs/)
* [**NGINX Ingress Controller Documentation**](https://kubernetes.github.io/ingress-nginx/)

---

## 👨‍💻 **Author**

* **T.I.Q.S. DevSecOps:** DevSecOps Engineer
* [**GitHub**](https://github.com/tiqsclass6)
* **Focus Areas:**
  * Kubernetes
  * DevSecOps
  * Terraform
  * GitOps
  * Cloud Infrastructure
  * Security Automation

---
