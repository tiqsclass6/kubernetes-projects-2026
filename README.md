# ☸️ **Kubernetes Projects 2026 - GitOps, ArgoCD, Policy, Flux, and Kong Labs**

![Project Status](https://img.shields.io/badge/Project%20Status-Active-22C55E?style=for-the-badge&logo=check-circle&logoColor=white)
![Repository](https://img.shields.io/badge/Repository-Kubernetes%20Projects%202026-0A66C2?style=for-the-badge&logo=github&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-Orchestration-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![AWS EKS](https://img.shields.io/badge/AWS%20EKS-Amazon%20EKS-FF9900?style=for-the-badge&logo=amazoneks&logoColor=white)
![Google GKE](https://img.shields.io/badge/Google%20GKE-GKE-4285F4?style=for-the-badge&logo=googlecloud&logoColor=white)
![Argo CD](https://img.shields.io/badge/GitOps-Argo%20CD-EF7B4D?style=for-the-badge&logo=argo&logoColor=white)
![Flux CD](https://img.shields.io/badge/GitOps-Flux%20CD-5468FF?style=for-the-badge&logo=flux&logoColor=white)
![OPA Gatekeeper](https://img.shields.io/badge/Policy-OPA%20Gatekeeper-7D3C98?style=for-the-badge&logo=openpolicyagent&logoColor=white)
![Kong Gateway](https://img.shields.io/badge/API%20Gateway-Kong-003459?style=for-the-badge&logo=kong&logoColor=white)
![Kubernetes RBAC](https://img.shields.io/badge/Security-RBAC-4F46E5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Helm](https://img.shields.io/badge/Packaging-Helm-0F1689?style=for-the-badge&logo=helm&logoColor=white)
![YAML](https://img.shields.io/badge/Manifests-YAML-3B82F6?style=for-the-badge&logo=yaml&logoColor=white)
![Bash](https://img.shields.io/badge/Scripting-Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Splunk](https://img.shields.io/badge/Observability-Splunk-000000?style=for-the-badge&logo=splunk&logoColor=white)
![Kubernetes Ingress](https://img.shields.io/badge/Ingress-Kubernetes%20Ingress-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![GitHub Forks](https://img.shields.io/github/forks/tiqsclass6/kubernetes-projects-2026?style=for-the-badge&logo=github&logoColor=white)
![GitHub Stars](https://img.shields.io/github/stars/tiqsclass6/kubernetes-projects-2026?style=for-the-badge&logo=github&logoColor=white)
![GitHub License](https://img.shields.io/github/license/tiqsclass6/kubernetes-projects-2026?style=for-the-badge&logo=github&logoColor=white)
![Last Updated](https://img.shields.io/badge/Last%20Updated-May%202026-8B5CF6?style=for-the-badge&logo=githubactions&logoColor=white)

---

## 📖 **Overview**

**Kubernetes Projects 2026** is a multi-branch Kubernetes platform engineering repository focused on **GitOps**, **security policy enforcement**, **Kubernetes ingress**, and **infrastructure automation**.

The repository is organized into dedicated project branches. Each branch represents a standalone Kubernetes lab with its own Terraform, manifests, scripts, screenshots, and documentation.

It brings together five major deliverables:

- **Project 2:** Argo CD GitOps Security Lab with Splunk multi-environment deployment
- **Project 3:** OPA Gatekeeper + Argo CD Kubernetes policy enforcement
- **Project 4:** Flux GitOps + Splunk deployment on Google Kubernetes Engine
- **Project 5:** Kong Ingress Controller with a basic Hello App on Elastic Kubernetes Service (EKS)
- **Project 6:** Kong Ingress Controller with API key authentication and rate limiting on EKS

Together, these branches demonstrate repeatable infrastructure provisioning, declarative Kubernetes operations, GitOps deployment, RBAC security, policy-as-code, ingress control, API gateway patterns, and operational validation.

---

## 📚 **References**

### **Repository**

- [**Kubernetes Projects 2026 - Main Repository**](https://github.com/tiqsclass6/kubernetes-projects-2026)
- [**All Branches**](https://github.com/tiqsclass6/kubernetes-projects-2026/branches/all)

### **Branch References**

- [**Project 2 — Argo CD GitOps Security Lab**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-2)  
  Based on: Argo CD, AppProjects, RBAC policies, Splunk workloads, Kubernetes namespaces, Terraform-managed AWS EKS infrastructure, and Bash automation.

- [**Project 3 — OPA Gatekeeper + Argo CD Policy Enforcement**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-3)  
  Based on: OPA Gatekeeper, Rego, Kubernetes admission control, Argo CD, environment namespace locking, service port enforcement, Splunk deployments, and automated validation scripts.

- [**Project 4 — Flux GitOps + Splunk on GKE**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-4)  
  Based on: Google Kubernetes Engine, Terraform, Flux CD, GitRepository, Kustomization reconciliation, Kustomize overlays, cert-manager, NGINX Ingress, TLS, Splunk StatefulSet, and evidence artifacts.

- [**Project 5 — Kong Ingress Hello App on EKS**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-5)  
  Based on: AWS EKS, Terraform, Helm, Kong Ingress Controller, Kubernetes Service, Ingress routing, LoadBalancer exposure, and Hello App validation.

- [**Project 6 — Kong Security Plugins on EKS**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-6)  
  Based on: AWS EKS, Terraform, Helm, Kong Gateway, KongPlugin resources, KongConsumer, Kubernetes Secrets, API key authentication, rate limiting, NGINX test workload, and deploy/teardown automation.

### **Supporting Documentation**

- **Kubernetes Concepts** — [Kubernetes Docs](https://kubernetes.io/docs/concepts/)
- **Terraform Documentation** — [Terraform Docs](https://developer.hashicorp.com/terraform/docs)
- **Helm Charts** — [Helm Docs](https://helm.sh/docs/)
- **AWS EKS** — [Amazon EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html)
- **Google Kubernetes Engine** — [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- **Argo CD** — [Argo CD Docs](https://argo-cd.readthedocs.io/)
- **Flux CD** — [Flux Docs](https://fluxcd.io/flux/)
- **OPA Gatekeeper** — [Gatekeeper Docs](https://open-policy-agent.github.io/gatekeeper/website/docs/)
- **Rego Policy Language** — [OPA Rego Docs](https://www.openpolicyagent.org/docs/latest/policy-language/)
- **Kong Ingress Controller** — [Kong Kubernetes Ingress Controller Docs](https://docs.konghq.com/kubernetes-ingress-controller/)
- **Kong Gateway** — [Kong Gateway Docs](https://docs.konghq.com/gateway/)
- **cert-manager** — [cert-manager Docs](https://cert-manager.io/docs/)
- **NGINX Ingress Controller** — [Ingress-NGINX Docs](https://kubernetes.github.io/ingress-nginx/)
- **Splunk** — [Splunk Documentation](https://docs.splunk.com/Documentation)

---

## 🧠 **Project Objective**

Deliver a **secure, automated, GitOps-driven Kubernetes portfolio repository** capable of:

- Provisioning Kubernetes infrastructure using Terraform
- Deploying workloads to AWS EKS and Google Kubernetes Engine
- Managing applications through Argo CD and Flux CD
- Enforcing RBAC and environment isolation across Kubernetes namespaces
- Applying policy-as-code controls through OPA Gatekeeper and Rego
- Exposing services through Kong Ingress Controller and AWS LoadBalancer services
- Demonstrating API gateway controls such as authentication and rate limiting
- Generating screenshots, logs, test outputs, and artifacts for proof-of-work submissions
- Practicing clean teardown workflows to avoid orphaned cloud resources and unnecessary cost

---

## 🔗 **Branches**

| **Branch**                                                                           | **Project**                 | **Platform**             | **Main Tools**                              | **Focus**                                |
| ------------------------------------------------------------------------------------ | --------------------------- | ------------------------ | ------------------------------------------- | ---------------------------------------- |
| [`project-2`](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-2) | Argo CD GitOps Security Lab | AWS EKS                  | Terraform, Argo CD, Kubernetes, Bash        | RBAC, AppProjects, environment isolation |
| [`project-3`](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-3) | OPA Gatekeeper + Argo CD    | AWS EKS                  | Terraform, Argo CD, Gatekeeper, Rego        | Admission control and policy enforcement |
| [`project-4`](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-4) | Flux GitOps + Splunk on GKE | GCP GKE                  | Terraform, Flux CD, Kustomize, cert-manager | GitOps reconciliation and TLS ingress    |
| [`project-5`](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-5) | Kong Ingress Hello App      | AWS EKS                  | Terraform, Helm, Kong, Kubernetes           | Basic ingress gateway routing            |
| [`project-6`](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-6) | Kong Auth + Rate Limiting   | AWS EKS                  | Terraform, Helm, KongPlugin, KongConsumer   | API key authentication and rate limiting |

---

## 🔐 [**Branch Project 2 — Argo CD GitOps Security Lab**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-2)

![project-2-diagram.png](/diagrams/project-2-diagram.png)

**Goal:** Deploy a secure multi-environment Splunk GitOps platform using **Argo CD**, **RBAC**, and **AWS EKS**.

**Highlights:**

- Terraform provisions the AWS EKS cluster and supporting infrastructure
- Argo CD manages Splunk applications across `splunk-dev`, `splunk-test`, and `splunk-prod`
- AppProjects isolate each environment
- RBAC policies restrict user access by role
- Automation scripts deploy, configure RBAC, create users, validate, and tear down the lab
- Evidence screenshots document Terraform, Argo CD, user access, application trees, and validation checks

**Primary skills demonstrated:**

- GitOps deployment lifecycle
- Kubernetes namespace isolation
- Argo CD AppProjects
- Argo CD RBAC
- Terraform EKS provisioning
- Bash-driven operational automation

---

## 🛡️ [**Branch Project 3 — OPA Gatekeeper + Argo CD Policy Enforcement**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-3)

![project-3-diagram.png](/diagrams/project-3-diagram.png)

**Goal:** Integrate **OPA Gatekeeper** with **Argo CD** to enforce Kubernetes security and deployment governance policies at admission time.

**Highlights:**

- Gatekeeper enforces Argo CD namespace placement rules
- Rego policies validate Splunk service ports by environment
- ConstraintTemplates and Constraints define policy-as-code controls
- Negative test manifests prove that invalid configurations are denied
- Argo CD deploys Splunk applications into controlled namespaces
- Validation artifacts include resource inventory and command outputs

**Primary skills demonstrated:**

- Kubernetes admission control
- OPA Gatekeeper
- Rego policy development
- DevSecOps governance
- GitOps security controls
- Runtime policy enforcement

---

## 🌊 [**Branch Project 4 — Flux GitOps + Splunk Deployment on GKE**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-4)

![project-4-diagram.png](/diagrams/project-4-diagram.png)

**Goal:** Deploy Splunk to **Google Kubernetes Engine** using **Flux CD**, **Kustomize**, **Terraform**, and GitOps reconciliation.

**Highlights:**

- Terraform provisions GKE infrastructure
- Flux GitRepository acts as the source of truth
- Flux Kustomization continuously reconciles the desired cluster state
- Splunk runs as a StatefulSet with persistent storage
- NGINX Ingress and cert-manager provide TLS-enabled external access
- Artifact collection captures logs, snapshots, reports, and validation outputs
- Teardown scripts support deterministic cleanup

**Primary skills demonstrated:**

- Flux CD GitOps workflow
- GKE infrastructure provisioning
- Kustomize-based application layout
- Stateful Kubernetes workloads
- TLS ingress with cert-manager
- Drift correction and reconciliation

---

## 🦍 [**Branch Project 5 — Kong Ingress Hello App on EKS**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-5)

![project-5-diagram.png](/diagrams/project-5-diagram.png)

**Goal:** Deploy a simple Kubernetes Hello App and expose it externally through **Kong Ingress Controller** on **AWS EKS**.

**Highlights:**

- Terraform provisions EKS, networking, IAM, storage, and Kubernetes providers
- Helm installs Kong Ingress Controller
- Kubernetes manifests deploy the Hello App, Service, and Ingress
- Kong Gateway provides centralized HTTP routing
- Validation includes successful `/hello` routing and failure testing for invalid paths
- Cost-awareness notes identify EKS, LoadBalancer, NAT Gateway, EBS, and CloudWatch cost areas

**Primary skills demonstrated:**

- Kong Ingress Controller deployment
- Gateway-based service exposure
- Kubernetes Service and Ingress design
- AWS LoadBalancer integration
- Terraform + Helm platform automation
- Operational troubleshooting and cleanup

---

## 🔑 [**Branch Project 6 — Kong API Key Auth + Rate Limiting on EKS**](https://github.com/tiqsclass6/kubernetes-projects-2026/tree/project-6)

![project-6-diagram.png](/diagrams/project-6-diagram.png)

**Goal:** Extend Kong Ingress on EKS with API gateway security controls using **key-auth**, **KongConsumer**, Kubernetes Secrets, and **rate limiting**.

**Highlights:**

- Terraform provisions AWS VPC, EKS, node groups, IAM/OIDC, EBS CSI, and Kong platform resources
- Helm installs Kong Ingress Controller
- `deploy.sh` applies KongPlugin resources, API key Secret, KongConsumer, and Ingress routes
- `/hello` is protected with API key authentication
- `/hello-ratelimit` validates Kong rate limiting behavior
- Testing confirms expected `401`, `200`, and `429` responses
- `teardown.sh` removes Kubernetes resources before manual Terraform destroy

**Primary skills demonstrated:**

- Kong Gateway plugin configuration
- API key authentication
- Rate limiting
- Kubernetes Secret + KongConsumer pattern
- Ingress-based API security
- Repeatable deployment and teardown automation

---

## 🧩 **Repository Architecture Summary**

```text
kubernetes-projects-2026/
├── project-2
│   ├── Terraform-managed AWS EKS foundation
│   ├── Argo CD GitOps applications
│   ├── RBAC policies
│   ├── Splunk dev/test/prod workloads
│   └── deployment, RBAC, validation, and teardown scripts
│
├── project-3
│   ├── Terraform-managed AWS EKS foundation
│   ├── Argo CD applications
│   ├── OPA Gatekeeper ConstraintTemplates
│   ├── Rego policy constraints
│   ├── Splunk policy validation workloads
│   └── automated policy test and artifact scripts
│
├── project-4
│   ├── Terraform-managed GKE infrastructure
│   ├── Flux GitOps source and Kustomization resources
│   ├── Splunk StatefulSet workload
│   ├── cert-manager and NGINX Ingress resources
│   └── artifact collection and teardown automation
│
├── project-5
│   ├── Terraform-managed AWS EKS foundation
│   ├── Helm-managed Kong Ingress Controller
│   ├── Hello App Deployment and Service
│   ├── Kong Ingress route
│   └── Kong teardown and validation workflow
│
└── project-6
    ├── Terraform-managed AWS EKS foundation
    ├── Helm-managed Kong Ingress Controller
    ├── KongPlugin key-auth and rate-limiting resources
    ├── KongConsumer and API key Secret
    ├── secured /hello and /hello-ratelimit routes
    └── deploy and teardown scripts
```

---

## 🧪 **Common Validation Commands**

```bash
# Confirm Kubernetes access
kubectl cluster-info
kubectl get nodes

# Confirm namespaces
kubectl get ns

# Confirm workloads across all namespaces
kubectl get pods -A
kubectl get svc -A
kubectl get ingress -A

# Confirm Argo CD resources when applicable
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl get appprojects -n argocd

# Confirm Flux resources when applicable
kubectl get pods -n flux-system
flux get sources git
flux get kustomizations

# Confirm Gatekeeper resources when applicable
kubectl get pods -n gatekeeper-system
kubectl get constrainttemplates
kubectl get constraints

# Confirm Kong resources when applicable
kubectl get pods -n kong
kubectl get svc -n kong
kubectl get kongplugins -A
kubectl get kongconsumers -A
```

---

## 🛠 **Troubleshooting**

| **Issue**                                      | **Common Cause**                                                 | **Resolution**                                                                   |
| ---------------------------------------------- | ---------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `LoadBalancer pending`                         | AWS or GKE load balancer still provisioning                      | Wait several minutes, then run `kubectl get svc -A`                              |
| `ImagePullBackOff`                             | Invalid image name, missing registry auth, or image pull failure | Run `kubectl describe pod <pod> -n <namespace>` and verify image path            |
| `CrashLoopBackOff`                             | Application startup failure or bad configuration                 | Run `kubectl logs <pod> -n <namespace>` and inspect events                       |
| Argo CD app stuck `OutOfSync`                  | Manifest drift or missing dependency                             | Sync the app, inspect `kubectl describe application`, and validate manifests     |
| Argo CD RBAC not applying                      | ConfigMap not reloaded or policy syntax issue                    | Restart Argo CD server and validate `argocd-rbac-cm`                             |
| Gatekeeper policy not denying invalid resource | ConstraintTemplate or Constraint not installed correctly         | Check `kubectl get constrainttemplates` and `kubectl describe constraint <name>` |
| Flux reconciliation failing                    | GitRepository or Kustomization path error                        | Run `flux get sources git`, `flux get kustomizations`, and `flux reconcile`      |
| TLS certificate not ready                      | cert-manager issuer, DNS, or ingress mismatch                    | Run `kubectl describe certificate -A` and inspect cert-manager logs              |
| Kong route returns `404`                       | Ingress rule path or service name mismatch                       | Check `kubectl get ingress -A` and verify service backend names                  |
| Kong route returns `401`                       | Missing or incorrect API key                                     | Send the correct API key header expected by the KongPlugin configuration         |
| Kong route returns `429`                       | Rate limit triggered successfully                                | Wait for the rate-limit window to reset or adjust plugin limits                  |
| Namespace stuck `Terminating`                  | Finalizers blocking deletion                                     | Inspect finalizers and remove only after confirming cleanup safety               |
| Terraform destroy blocked                      | Kubernetes resources or cloud load balancers still exist         | Run branch-specific teardown script before `terraform destroy`                   |
| Orphaned cloud resources                       | LoadBalancer, NAT Gateway, or EBS volume left behind             | Check AWS/GCP console and CLI for leftover resources before closing the lab      |

---

## 🧾 **Suggested Branch Workflow**

```bash
# Clone the repository
git clone https://github.com/tiqsclass6/kubernetes-projects-2026.git
cd kubernetes-projects-2026

# List remote branches
git branch -r

# Check out a specific project branch
git checkout project-2
git checkout project-3
git checkout project-4
git checkout project-5
git checkout project-6
```

Each branch contains its own README, project structure, scripts, manifests, and validation evidence. Follow the branch-specific documentation before running Terraform or Kubernetes commands.

---

## 🧹 **Teardown and Cost Control**

These labs create real cloud infrastructure. Always tear down Kubernetes resources before destroying Terraform-managed infrastructure.

Recommended cleanup pattern:

```bash
# Run the branch-specific teardown script first
./scripts/teardown.sh
# or use the exact script name documented in the branch README

# Then destroy infrastructure
terraform destroy
```

For AWS-based branches, also check for leftover resources:

```bash
aws elb describe-load-balancers --region us-east-1
aws ec2 describe-nat-gateways --region us-east-1
aws ec2 describe-volumes --filters Name=status,Values=available --region us-east-1
```

For GKE-based branches, verify cluster and load balancer cleanup:

```bash
gcloud container clusters list
gcloud compute forwarding-rules list
gcloud compute addresses list
gcloud compute disks list
```

---

## ✅ **Skills Demonstrated**

| **Category**                 | **Skills**                                                                             |
| ---------------------------- | -------------------------------------------------------------------------------------- |
| **Infrastructure as Code**   | Terraform, modular cloud provisioning, remote-state-ready structure                    |
| **Kubernetes**               | Deployments, Services, Ingress, StatefulSets, namespaces, secrets, ConfigMaps          |
| **GitOps**                   | Argo CD, Flux CD, GitRepository, Kustomization, AppProjects                            |
| **Security**                 | RBAC, OPA Gatekeeper, Rego, admission control, Kong key-auth                           |
| **Networking**               | Ingress routing, LoadBalancer services, TLS ingress, gateway patterns                  |
| **Platform Engineering**     | Repeatable build scripts, validation scripts, teardown automation, artifact collection |
| **Observability / Evidence** | Screenshots, logs, resource snapshots, validation outputs, project demos               |
| **Cloud Platforms**          | AWS EKS, Google Kubernetes Engine, IAM, VPC networking, managed node groups            |

---

## 👥 **Author**

| **Field**        | **Value**                                                                              |
| ---------------- | -------------------------------------------------------------------------------------- |
| **Author**       | `T.I.Q.S.`                                                                             |
| **Group Leader** | `John Sweeney`                                                                         |
| **Group Name**   | `The Brotherhood of jerMutants - Wolfpack`                                             |
| **Version**      | `v1.4`                                                                                 |
| **Date**         | `May 31, 2026`                                                                         |
| **GitHub**       | [**tiqsclass6**](https://github.com/tiqsclass6)                                        |
| **Repository**   | [**kubernetes-projects-2026**](https://github.com/tiqsclass6/kubernetes-projects-2026) |

> “Declare it in Git. Reconcile it in Kubernetes. Secure it before it ships.” ☸️
